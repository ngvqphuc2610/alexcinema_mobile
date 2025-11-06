import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CreateGenreDto } from './dto/create-genre.dto';
import { UpdateGenreDto } from './dto/update-genre.dto';

export interface GenreQueryParams {
  page?: number;
  limit?: number;
  search?: string;
}

@Injectable()
export class GenreService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: CreateGenreDto) {
    const name = dto.genreName.trim();
    const existing = await this.prisma.genre.findUnique({
      where: { genre_name: name },
    });
    if (existing) {
      throw new ConflictException('Genre already exists');
    }
    const data: Prisma.genreCreateInput = {
      genre_name: name,
      description: dto.description,
    };
    return this.prisma.genre.create({ data });
  }

  async findAll(params: GenreQueryParams = {}) {
    const page = Math.max(1, params.page ?? 1);
    const limit = Math.min(100, Math.max(1, params.limit ?? 20));
    const where: Prisma.genreWhereInput = params.search
      ? { genre_name: { contains: params.search } }
      : {};

    const [items, total] = await this.prisma.$transaction([
      this.prisma.genre.findMany({
        where,
        skip: (page - 1) * limit,
        take: limit,
        orderBy: { genre_name: 'asc' },
      }),
      this.prisma.genre.count({ where }),
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
    const genre = await this.prisma.genre.findUnique({
      where: { id_genre: id },
      include: {
        genre_movies: {
          include: { movie: true },
        },
      },
    });
    if (!genre) {
      throw new NotFoundException('Genre not found');
    }
    return genre;
  }

  async update(id: number, dto: UpdateGenreDto) {
    await this.ensureExists(id);
    if (dto.genreName) {
      const name = dto.genreName.trim();
      const existing = await this.prisma.genre.findUnique({
        where: { genre_name: name },
      });
      if (existing && existing.id_genre !== id) {
        throw new ConflictException('Genre already exists');
      }
    }

    const data: Prisma.genreUpdateInput = {
      genre_name: dto.genreName ? dto.genreName.trim() : undefined,
      description: dto.description,
    };

    return this.prisma.genre.update({
      where: { id_genre: id },
      data,
    });
  }

  async remove(id: number) {
    await this.ensureExists(id);
    return this.prisma.genre.delete({ where: { id_genre: id } });
  }

  private async ensureExists(id: number) {
    const exists = await this.prisma.genre.findUnique({
      where: { id_genre: id },
      select: { id_genre: true },
    });
    if (!exists) {
      throw new NotFoundException('Genre not found');
    }
  }
}
