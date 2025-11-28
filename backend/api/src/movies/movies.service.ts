import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { MovieStatus, Prisma } from '@prisma/client';
import { EventEmitter2 } from '@nestjs/event-emitter';
import { PrismaService } from '../prisma/prisma.service';
import { CreateMovieDto } from './dto/create-movie.dto';
import { UpdateMovieDto } from './dto/update-movie.dto';

export interface MoviePaginationParams {
  page?: number;
  limit?: number;
  status?: MovieStatus;
  search?: string;
}

@Injectable()
export class MoviesService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly eventEmitter: EventEmitter2,
  ) { }

  async create(dto: CreateMovieDto) {
    const data: Prisma.moviesCreateInput = this.toCreateInput(dto);
    const movie = await this.prisma.movies.create({ data });

    // Emit event for RAG re-indexing
    this.eventEmitter.emit('movie.created', { id: movie.id_movie });

    return movie;
  }

  async findAll(params: MoviePaginationParams = {}) {
    const page = Math.max(1, params.page ?? 1);
    const limit = Math.min(100, Math.max(1, params.limit ?? 20));
    const where: Prisma.moviesWhereInput = {
      status: params.status ?? undefined,
      title: params.search
        ? { contains: params.search }
        : undefined,
    };

    const [items, total] = await this.prisma.$transaction([
      this.prisma.movies.findMany({
        where,
        skip: (page - 1) * limit,
        take: limit,
        orderBy: { release_date: 'desc' },
      }),
      this.prisma.movies.count({ where }),
    ]);

    return {
      items,
      meta: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async findOne(id: number) {
    const movie = await this.prisma.movies.findUnique({
      where: { id_movie: id },
    });
    if (!movie) {
      throw new NotFoundException('Movie not found');
    }
    return movie;
  }

  async update(id: number, dto: UpdateMovieDto) {
    await this.ensureExists(id);
    const data: Prisma.moviesUpdateInput = this.toUpdateInput(dto);
    const movie = await this.prisma.movies.update({
      where: { id_movie: id },
      data,
    });

    // Emit event for RAG re-indexing
    this.eventEmitter.emit('movie.updated', { id: movie.id_movie });

    return movie;
  }

  async remove(id: number) {
    await this.ensureExists(id);

    // Check if movie has showtimes with bookings
    const showtimesWithBookings = await this.prisma.showtimes.count({
      where: {
        id_movie: id,
        bookings: {
          some: {},
        },
      },
    });

    if (showtimesWithBookings > 0) {
      throw new BadRequestException(
        `Cannot delete movie. It has ${showtimesWithBookings} showtime(s) with existing bookings. Please delete bookings first.`,
      );
    }

    const movie = await this.prisma.movies.delete({ where: { id_movie: id } });

    // Emit event for RAG re-indexing
    this.eventEmitter.emit('movie.deleted', { id });

    return movie;
  }

  private async ensureExists(id: number) {
    const exists = await this.prisma.movies.findUnique({
      where: { id_movie: id },
      select: { id_movie: true },
    });
    if (!exists) {
      throw new NotFoundException('Movie not found');
    }
  }

  private toCreateInput(dto: CreateMovieDto): Prisma.moviesCreateInput {
    return {
      title: dto.title.trim(),
      original_title: dto.originalTitle?.trim(),
      director: dto.director?.trim(),
      actors: dto.actors,
      duration: dto.duration,
      release_date: new Date(dto.releaseDate),
      end_date: dto.endDate ? new Date(dto.endDate) : undefined,
      language: dto.language?.trim(),
      subtitle: dto.subtitle?.trim(),
      country: dto.country?.trim(),
      description: dto.description,
      poster_image: dto.posterImage,
      banner_image: dto.bannerImage,
      trailer_url: dto.trailerUrl,
      age_restriction: dto.ageRestriction,
      status: dto.status,
    };
  }

  private toUpdateInput(dto: UpdateMovieDto): Prisma.moviesUpdateInput {
    return {
      title: dto.title ? dto.title.trim() : undefined,
      original_title: dto.originalTitle ? dto.originalTitle.trim() : undefined,
      director: dto.director ? dto.director.trim() : undefined,
      actors: dto.actors,
      duration: dto.duration,
      release_date: dto.releaseDate ? new Date(dto.releaseDate) : undefined,
      end_date: dto.endDate ? new Date(dto.endDate) : undefined,
      language: dto.language ? dto.language.trim() : undefined,
      subtitle: dto.subtitle ? dto.subtitle.trim() : undefined,
      country: dto.country ? dto.country.trim() : undefined,
      description: dto.description,
      poster_image: dto.posterImage,
      banner_image: dto.bannerImage,
      trailer_url: dto.trailerUrl,
      age_restriction: dto.ageRestriction,
      status: dto.status,
    };
  }
}


