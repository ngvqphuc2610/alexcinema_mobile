import { Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CreateShowtimeDto } from './dto/create-showtime.dto';
import { UpdateShowtimeDto } from './dto/update-showtime.dto';

export interface ShowtimesQueryParams {
  page?: number;
  limit?: number;
  movieId?: number;
  screenId?: number;
  status?: string;
  format?: string;
  showDate?: string;
}

@Injectable()
export class ShowtimesService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: CreateShowtimeDto) {
    const data: Prisma.showtimesUncheckedCreateInput = {
      id_movie: dto.idMovie ?? undefined,
      id_screen: dto.idScreen ?? undefined,
      show_date: new Date(dto.showDate),
      start_time: this.toTime(dto.startTime),
      end_time: this.toTime(dto.endTime),
      format: dto.format?.trim(),
      language: dto.language?.trim(),
      subtitle: dto.subtitle?.trim(),
      status: dto.status?.trim(),
      price: dto.price,
    };

    return this.prisma.showtimes.create({ data });
  }

  async findAll(params: ShowtimesQueryParams = {}) {
    const page = Math.max(1, params.page ?? 1);
    const limit = Math.min(100, Math.max(1, params.limit ?? 20));
    const where: Prisma.showtimesWhereInput = {
      id_movie: params.movieId ?? undefined,
      id_screen: params.screenId ?? undefined,
      status: params.status?.trim(),
      format: params.format?.trim(),
      show_date: params.showDate ? new Date(params.showDate) : undefined,
    };

    const [items, total] = await this.prisma.$transaction([
      this.prisma.showtimes.findMany({
        where,
        skip: (page - 1) * limit,
        take: limit,
        orderBy: [{ show_date: 'asc' }, { start_time: 'asc' }],
        include: {
          movie: true,
          screen: true,
        },
      }),
      this.prisma.showtimes.count({ where }),
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
    const record = await this.prisma.showtimes.findUnique({
      where: { id_showtime: id },
      include: {
        movie: true,
        screen: true,
      },
    });
    if (!record) {
      throw new NotFoundException('Showtime not found');
    }
    return record;
  }

  async update(id: number, dto: UpdateShowtimeDto) {
    await this.ensureExists(id);
    const data: Prisma.showtimesUncheckedUpdateInput = {
      id_movie: dto.idMovie ?? undefined,
      id_screen: dto.idScreen ?? undefined,
      show_date: dto.showDate ? new Date(dto.showDate) : undefined,
      start_time: dto.startTime ? this.toTime(dto.startTime) : undefined,
      end_time: dto.endTime ? this.toTime(dto.endTime) : undefined,
      format: dto.format ? dto.format.trim() : undefined,
      language: dto.language ? dto.language.trim() : undefined,
      subtitle: dto.subtitle ? dto.subtitle.trim() : undefined,
      status: dto.status ? dto.status.trim() : undefined,
      price: dto.price ?? undefined,
    };

    return this.prisma.showtimes.update({
      where: { id_showtime: id },
      data,
      include: {
        movie: true,
        screen: true,
      },
    });
  }

  async remove(id: number) {
    await this.ensureExists(id);
    return this.prisma.showtimes.delete({
      where: { id_showtime: id },
    });
  }

  private async ensureExists(id: number) {
    const exists = await this.prisma.showtimes.findUnique({
      where: { id_showtime: id },
      select: { id_showtime: true },
    });
    if (!exists) {
      throw new NotFoundException('Showtime not found');
    }
  }

  private toTime(value: string): Date {
    const trimmed = value.trim();
    const normalized =
      trimmed.length === 5
        ? `${trimmed}:00`
        : trimmed.length === 8
        ? trimmed
        : `${trimmed.padEnd(5, ':0')}:00`;
    return new Date(`1970-01-01T${normalized}Z`);
  }
}
