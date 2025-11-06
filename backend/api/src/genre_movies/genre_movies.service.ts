import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CreateGenreMovieDto } from './dto/create-genre-movie.dto';

export interface GenreMoviesQueryParams {
  page?: number;
  limit?: number;
  genreId?: number;
  movieId?: number;
}

@Injectable()
export class GenreMoviesService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: CreateGenreMovieDto) {
    const compositeKey = {
      id_genre: dto.genreId,
      id_movie: dto.movieId,
    };

    const existing = await this.prisma.genre_movies.findUnique({
      where: { id_genre_id_movie: compositeKey },
    });
    if (existing) {
      throw new ConflictException('Genre already linked to this movie');
    }

    const data: Prisma.genre_moviesUncheckedCreateInput = compositeKey;
    return this.prisma.genre_movies.create({
      data,
      include: {
        genre: true,
        movie: true,
      },
    });
  }

  async findAll(params: GenreMoviesQueryParams = {}) {
    const page = Math.max(1, params.page ?? 1);
    const limit = Math.min(100, Math.max(1, params.limit ?? 20));

    const where: Prisma.genre_moviesWhereInput = {
      id_genre: params.genreId ?? undefined,
      id_movie: params.movieId ?? undefined,
    };

    const [items, total] = await this.prisma.$transaction([
      this.prisma.genre_movies.findMany({
        where,
        skip: (page - 1) * limit,
        take: limit,
        orderBy: [{ id_genre: 'asc' }, { id_movie: 'asc' }],
        include: {
          genre: true,
          movie: true,
        },
      }),
      this.prisma.genre_movies.count({ where }),
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

  async remove(genreId: number, movieId: number) {
    await this.ensureExists(genreId, movieId);
    return this.prisma.genre_movies.delete({
      where: { id_genre_id_movie: { id_genre: genreId, id_movie: movieId } },
    });
  }

  private async ensureExists(genreId: number, movieId: number) {
    const exists = await this.prisma.genre_movies.findUnique({
      where: { id_genre_id_movie: { id_genre: genreId, id_movie: movieId } },
      select: { id_genre: true },
    });
    if (!exists) {
      throw new NotFoundException('Genre/movie relation not found');
    }
  }
}
