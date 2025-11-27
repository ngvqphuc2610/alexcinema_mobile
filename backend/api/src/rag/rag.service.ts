import { Injectable, Logger } from '@nestjs/common';
import { QdrantService } from './qdrant.service';
import { EmbeddingsService } from './embeddings.service';

export interface RagSearchResult {
    context: string;
    sources: Array<{
        type: string;
        title: string;
        score: number;
        data: Record<string, any>;
    }>;
}

@Injectable()
export class RagService {
    private readonly logger = new Logger(RagService.name);

    constructor(
        private readonly qdrant: QdrantService,
        private readonly embeddings: EmbeddingsService,
    ) { }

    /**
     * Search for relevant context based on user query
     * @param query User's question/query
     * @param limit Maximum number of results per collection
     * @returns Augmented context and sources
     */
    async search(query: string, limit: number = 3): Promise<RagSearchResult> {
        try {
            // Generate embedding for the query
            const queryVector = await this.embeddings.generateEmbedding(query);

            // Search across all collections in parallel
            const [movieResults, showtimeResults, promotionResults, cinemaResults] = await Promise.all([
                this.qdrant.search('movies', queryVector, limit).catch(() => []),
                this.qdrant.search('showtimes', queryVector, limit).catch(() => []),
                this.qdrant.search('promotions', queryVector, limit).catch(() => []),
                this.qdrant.search('cinemas', queryVector, limit).catch(() => []),
            ]);

            // Combine and sort by score
            const allResults = [
                ...movieResults.map(r => ({ ...r, collection: 'movies' })),
                ...showtimeResults.map(r => ({ ...r, collection: 'showtimes' })),
                ...promotionResults.map(r => ({ ...r, collection: 'promotions' })),
                ...cinemaResults.map(r => ({ ...r, collection: 'cinemas' })),
            ]
                .sort((a, b) => b.score - a.score)
                .slice(0, limit * 3); // Get top results overall

            // Format context for Gemini
            const context = this.formatContext(allResults);

            // Format sources
            const sources = allResults.map(result => ({
                type: result.payload.type,
                title: result.payload.title || result.payload.movieTitle || result.payload.name || 'Unknown',
                score: result.score,
                data: result.payload,
            }));

            return { context, sources };
        } catch (error) {
            this.logger.error(`RAG search failed: ${error.message}`);
            return { context: '', sources: [] };
        }
    }

    /**
     * Format search results into context string for Gemini
     */
    private formatContext(results: any[]): string {
        if (results.length === 0) {
            return '';
        }

        const sections: string[] = [];

        // Group by type
        const movieResults = results.filter(r => r.payload.type === 'movie');
        const showtimeResults = results.filter(r => r.payload.type === 'showtime');
        const promotionResults = results.filter(r => r.payload.type === 'promotion');
        const cinemaResults = results.filter(r => r.payload.type === 'cinema');

        // Format cinemas
        if (cinemaResults.length > 0) {
            sections.push('=== THÔNG TIN RẠP CHIẾU PHIM ===');
            cinemaResults.forEach(result => {
                const cinema = result.payload;
                const operationHours = cinema.operationHours?.map(oh =>
                    `${this.getDayName(oh.dayOfWeek)}: ${oh.openTime} - ${oh.closeTime}`
                ).join(', ') || 'N/A';

                sections.push(`
Tên rạp: ${cinema.name}
Địa chỉ: ${cinema.address}
Thành phố: ${cinema.city}
Mô tả: ${cinema.description || 'N/A'}
Số điện thoại: ${cinema.contactNumber || 'N/A'}
Email: ${cinema.email || 'N/A'}
Số phòng chiếu: ${cinema.screenCount}
Loại phòng: ${cinema.screenTypes?.join(', ') || 'N/A'}
Giờ mở cửa: ${operationHours}
        `.trim());
            });
        }

        // Format movies
        if (movieResults.length > 0) {
            sections.push('\n=== THÔNG TIN PHIM ===');
            movieResults.forEach(result => {
                const movie = result.payload;
                sections.push(`
Tên phim: ${movie.title}
Thể loại: ${movie.genres || 'N/A'}
Đạo diễn: ${movie.director || 'N/A'}
Diễn viên: ${movie.actors || 'N/A'}
Mô tả: ${movie.description || 'N/A'}
Thời lượng: ${movie.duration || 'N/A'} phút
Ngôn ngữ: ${movie.language || 'N/A'}
Quốc gia: ${movie.country || 'N/A'}
        `.trim());
            });
        }

        // Format showtimes
        if (showtimeResults.length > 0) {
            sections.push('\n=== LỊCH CHIẾU ===');
            showtimeResults.forEach(result => {
                const showtime = result.payload;
                sections.push(`
Phim: ${showtime.movieTitle}
Rạp: ${showtime.cinemaName}
Địa chỉ: ${showtime.cinemaAddress}
Phòng: ${showtime.screenName}
Giờ chiếu: ${new Date(showtime.startTime).toLocaleString('vi-VN')}
Định dạng: ${showtime.format || '2D'}
Ngôn ngữ: ${showtime.language || 'N/A'}
Phụ đề: ${showtime.subtitle || 'N/A'}
Giá vé: ${parseInt(showtime.price).toLocaleString('vi-VN')} VNĐ
        `.trim());
            });
        }

        // Format promotions
        if (promotionResults.length > 0) {
            sections.push('\n=== KHUYẾN MÃI ===');
            promotionResults.forEach(result => {
                const promo = result.payload;
                sections.push(`
Tên: ${promo.title}
Mô tả: ${promo.description || 'N/A'}
Mã khuyến mãi: ${promo.promotionCode || 'N/A'}
Giảm giá: ${promo.discountPercent || 0}%
Giảm tiền: ${promo.discountAmount?.toLocaleString('vi-VN') || 0} VNĐ
Thời gian: ${new Date(promo.startDate).toLocaleDateString('vi-VN')} - ${new Date(promo.endDate).toLocaleDateString('vi-VN')}
Mua tối thiểu: ${promo.minPurchase?.toLocaleString('vi-VN') || 0} VNĐ
        `.trim());
            });
        }

        return sections.join('\n\n');
    }

    private getDayName(dayOfWeek: number): string {
        const dayNames = ['Chủ nhật', 'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7'];
        return dayNames[dayOfWeek] || 'N/A';
    }
}
