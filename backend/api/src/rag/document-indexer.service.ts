import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { QdrantService, QdrantPoint } from './qdrant.service';
import { EmbeddingsService } from './embeddings.service';

@Injectable()
export class DocumentIndexerService {
    private readonly logger = new Logger(DocumentIndexerService.name);

    constructor(
        private readonly prisma: PrismaService,
        private readonly qdrant: QdrantService,
        private readonly embeddings: EmbeddingsService,
    ) { }

    /**
     * Index all movies into Qdrant
     */
    async indexMovies(): Promise<number> {
        this.logger.log('Starting movie indexing...');

        const movies = await this.prisma.movies.findMany({
            select: {
                id_movie: true,
                title: true,
                description: true,
                director: true,
                actors: true,
                duration: true,
                release_date: true,
                language: true,
                age_restriction: true,
                country: true,
                genre_movies: {
                    select: {
                        genre: {
                            select: {
                                genre_name: true,
                            },
                        },
                    },
                },
            },
        });

        const points: QdrantPoint[] = [];

        for (const movie of movies) {
            // Create searchable text from movie data
            const genres = movie.genre_movies.map(gm => gm.genre.genre_name).join(', ');
            const text = this.createMovieText(movie, genres);

            // Generate embedding
            const vector = await this.embeddings.generateEmbedding(text);

            points.push({
                id: movie.id_movie,
                vector,
                payload: {
                    id: movie.id_movie,
                    title: movie.title,
                    description: movie.description,
                    genres: genres,
                    director: movie.director,
                    actors: movie.actors,
                    duration: movie.duration,
                    releaseDate: movie.release_date?.toISOString(),
                    language: movie.language,
                    ageRestriction: movie.age_restriction,
                    country: movie.country,
                    type: 'movie',
                },
            });

            // Rate limiting
            await new Promise(resolve => setTimeout(resolve, 100));
        }

        if (points.length > 0) {
            await this.qdrant.upsertPoints('movies', points);
        }

        this.logger.log(`Indexed ${points.length} movies`);
        return points.length;
    }

    /**
     * Index showtimes
     */
    async indexShowtimes(): Promise<number> {
        this.logger.log('Starting showtime indexing...');

        const showtimes = await this.prisma.showtimes.findMany({
            include: {
                movie: {
                    select: {
                        title: true,
                        genre_movies: {
                            select: {
                                genre: {
                                    select: {
                                        genre_name: true,
                                    },
                                },
                            },
                        },
                    },
                },
                screen: {
                    select: {
                        screen_name: true,
                        cinema: {
                            select: {
                                cinema_name: true,
                                address: true,
                            },
                        },
                    },
                },
            },
            where: {
                show_date: {
                    gte: new Date(),
                },
            },
            take: 1000, // Limit to recent showtimes
        });

        const points: QdrantPoint[] = [];

        for (const showtime of showtimes) {
            if (!showtime.movie || !showtime.screen || !showtime.screen.cinema) {
                continue; // Skip if data is incomplete
            }

            const genres = showtime.movie.genre_movies.map(gm => gm.genre.genre_name).join(', ');
            const text = this.createShowtimeText(showtime, genres);
            const vector = await this.embeddings.generateEmbedding(text);

            // Combine show_date and start_time to create full datetime
            const startDateTime = new Date(showtime.show_date);
            const [hours, minutes] = showtime.start_time.toTimeString().split(':');
            startDateTime.setHours(parseInt(hours), parseInt(minutes));

            const endDateTime = new Date(showtime.show_date);
            const [endHours, endMinutes] = showtime.end_time.toTimeString().split(':');
            endDateTime.setHours(parseInt(endHours), parseInt(endMinutes));

            points.push({
                id: showtime.id_showtime,
                vector,
                payload: {
                    id: showtime.id_showtime,
                    movieTitle: showtime.movie.title,
                    genres: genres,
                    cinemaName: showtime.screen.cinema.cinema_name,
                    cinemaAddress: showtime.screen.cinema.address,
                    screenName: showtime.screen.screen_name,
                    startTime: startDateTime.toISOString(),
                    endTime: endDateTime.toISOString(),
                    showDate: showtime.show_date.toISOString(),
                    format: showtime.format,
                    language: showtime.language,
                    subtitle: showtime.subtitle,
                    price: showtime.price.toNumber(),
                    type: 'showtime',
                },
            });

            await new Promise(resolve => setTimeout(resolve, 100));
        }

        if (points.length > 0) {
            await this.qdrant.upsertPoints('showtimes', points);
        }

        this.logger.log(`Indexed ${points.length} showtimes`);
        return points.length;
    }

    /**
     * Index promotions
     */
    async indexPromotions(): Promise<number> {
        this.logger.log('Starting promotion indexing...');

        const promotions = await this.prisma.promotions.findMany({
            where: {
                end_date: {
                    gte: new Date(),
                },
            },
        });

        const points: QdrantPoint[] = [];

        for (const promotion of promotions) {
            const text = this.createPromotionText(promotion);
            const vector = await this.embeddings.generateEmbedding(text);

            points.push({
                id: promotion.id_promotions,
                vector,
                payload: {
                    id: promotion.id_promotions,
                    title: promotion.title,
                    description: promotion.description,
                    promotionCode: promotion.promotion_code,
                    discountPercent: promotion.discount_percent?.toNumber(),
                    discountAmount: promotion.discount_amount?.toNumber(),
                    startDate: promotion.start_date.toISOString(),
                    endDate: promotion.end_date?.toISOString(),
                    minPurchase: promotion.min_purchase?.toNumber(),
                    maxDiscount: promotion.max_discount?.toNumber(),
                    usageLimit: promotion.usage_limit,
                    status: promotion.status,
                    type: 'promotion',
                },
            });

            await new Promise(resolve => setTimeout(resolve, 100));
        }

        if (points.length > 0) {
            await this.qdrant.upsertPoints('promotions', points);
        }

        this.logger.log(`Indexed ${points.length} promotions`);
        return points.length;
    }

    /**
     * Index cinemas
     */
    async indexCinemas(): Promise<number> {
        this.logger.log('Starting cinema indexing...');

        const cinemas = await this.prisma.cinemas.findMany({
            include: {
                operation_hours: true,
                screens: {
                    include: {
                        screen_type: true,
                    },
                },
            },
            where: {
                status: 'active',
            },
        });

        const points: QdrantPoint[] = [];

        for (const cinema of cinemas) {
            const text = this.createCinemaText(cinema);
            const vector = await this.embeddings.generateEmbedding(text);

            points.push({
                id: cinema.id_cinema,
                vector,
                payload: {
                    id: cinema.id_cinema,
                    name: cinema.cinema_name,
                    address: cinema.address,
                    city: cinema.city,
                    description: cinema.description,
                    contactNumber: cinema.contact_number,
                    email: cinema.email,
                    screenCount: cinema.screens.length,
                    screenTypes: [...new Set(cinema.screens.map(s => s.screen_type?.type_name).filter(Boolean))],
                    operationHours: cinema.operation_hours.map(oh => ({
                        dayOfWeek: oh.day_of_week,
                        openTime: oh.opening_time?.toTimeString().substring(0, 5),
                        closeTime: oh.closing_time?.toTimeString().substring(0, 5),
                    })),
                    type: 'cinema',
                },
            });

            await new Promise(resolve => setTimeout(resolve, 100));
        }

        if (points.length > 0) {
            await this.qdrant.upsertPoints('cinemas', points);
        }

        this.logger.log(`Indexed ${points.length} cinemas`);
        return points.length;
    }

    /**
     * Index all data
     */
    async indexAll(): Promise<{ movies: number; showtimes: number; promotions: number; cinemas: number }> {
        const [movies, showtimes, promotions, cinemas] = await Promise.all([
            this.indexMovies(),
            this.indexShowtimes(),
            this.indexPromotions(),
            this.indexCinemas(),
        ]);

        return { movies, showtimes, promotions, cinemas };
    }

    // Helper methods to create searchable text
    private createMovieText(movie: any, genres: string): string {
        return `
      Tên phim: ${movie.title}
      Mô tả: ${movie.description || ''}
      Thể loại: ${genres || ''}
      Đạo diễn: ${movie.director || ''}
      Diễn viên: ${movie.actors || ''}
      Thời lượng: ${movie.duration || ''} phút
      Ngôn ngữ: ${movie.language || ''}
      Quốc gia: ${movie.country || ''}
      Độ tuổi: ${movie.age_restriction || ''}
    `.trim();
    }

    private createShowtimeText(showtime: any, genres: string): string {
        const date = new Date(showtime.show_date);
        const startTime = showtime.start_time.toTimeString().substring(0, 5);
        return `
      Phim: ${showtime.movie.title}
      Thể loại: ${genres}
      Rạp: ${showtime.screen.cinema.cinema_name}
      Địa chỉ: ${showtime.screen.cinema.address}
      Phòng: ${showtime.screen.screen_name}
      Ngày chiếu: ${date.toLocaleDateString('vi-VN')}
      Giờ chiếu: ${startTime}
      Định dạng: ${showtime.format || '2D'}
      Ngôn ngữ: ${showtime.language || ''}
      Phụ đề: ${showtime.subtitle || ''}
      Giá vé: ${showtime.price.toNumber().toLocaleString('vi-VN')} VNĐ
    `.trim();
    }

    private createPromotionText(promotion: any): string {
        return `
      Khuyến mãi: ${promotion.title}
      Mô tả: ${promotion.description || ''}
      Mã: ${promotion.promotion_code}
      Giảm giá: ${promotion.discount_percent?.toNumber() || 0}%
      Giảm tiền: ${promotion.discount_amount?.toNumber().toLocaleString('vi-VN') || 0} VNĐ
      Thời gian: ${new Date(promotion.start_date).toLocaleDateString('vi-VN')} - ${new Date(promotion.end_date).toLocaleDateString('vi-VN')}
      Mua tối thiểu: ${promotion.min_purchase?.toNumber().toLocaleString('vi-VN') || 0} VNĐ
    `.trim();
    }

    private createCinemaText(cinema: any): string {
        const dayNames = ['Chủ nhật', 'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7'];
        const operationHoursText = cinema.operation_hours
            .map(oh => `${dayNames[oh.day_of_week]}: ${oh.opening_time?.toTimeString().substring(0, 5)} - ${oh.closing_time?.toTimeString().substring(0, 5)}`)
            .join(', ');

        return `
      Rạp chiếu phim: ${cinema.cinema_name}
      Địa chỉ: ${cinema.address}
      Thành phố: ${cinema.city}
      Mô tả: ${cinema.description || ''}
      Số điện thoại: ${cinema.contact_number || ''}
      Email: ${cinema.email || ''}
      Số phòng chiếu: ${cinema.screens.length}
      Loại phòng: ${[...new Set(cinema.screens.map(s => s.screen_type?.type_name).filter(Boolean))].join(', ')}
      Giờ mở cửa: ${operationHoursText}
    `.trim();
    }
}
