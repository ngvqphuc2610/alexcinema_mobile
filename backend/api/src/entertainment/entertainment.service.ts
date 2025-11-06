import { Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CreateEntertainmentDto } from './dto/create-entertainment.dto';
import { UpdateEntertainmentDto } from './dto/update-entertainment.dto';

export interface EntertainmentQueryParams {
  page?: number;
  limit?: number;
  status?: string;
  featured?: boolean;
  search?: string;
  cinemaId?: number;
}

@Injectable()
export class EntertainmentService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: CreateEntertainmentDto) {
    const data = this.toCreateInput(dto);
    return this.prisma.entertainment.create({ data });
  }

  async findAll(params: EntertainmentQueryParams = {}) {
    const page = Math.max(1, params.page ?? 1);
    const limit = Math.min(100, Math.max(1, params.limit ?? 20));

    const where: Prisma.entertainmentWhereInput = {
      status: params.status ? params.status.trim() : undefined,
      featured: params.featured,
      id_cinema: params.cinemaId,
      title: params.search ? { contains: params.search } : undefined,
    };

    const [items, total] = await this.prisma.$transaction([
      this.prisma.entertainment.findMany({
        where,
        skip: (page - 1) * limit,
        take: limit,
        orderBy: { start_date: 'desc' },
      }),
      this.prisma.entertainment.count({ where }),
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
    const record = await this.prisma.entertainment.findUnique({
      where: { id_entertainment: id },
    });
    if (!record) {
      throw new NotFoundException('Entertainment not found');
    }
    return record;
  }

  async update(id: number, dto: UpdateEntertainmentDto) {
    await this.ensureExists(id);
    const data = this.toUpdateInput(dto);
    return this.prisma.entertainment.update({
      where: { id_entertainment: id },
      data,
    });
  }

  async remove(id: number) {
    await this.ensureExists(id);
    return this.prisma.entertainment.delete({ where: { id_entertainment: id } });
  }

  private async ensureExists(id: number) {
    const exists = await this.prisma.entertainment.findUnique({
      where: { id_entertainment: id },
      select: { id_entertainment: true },
    });
    if (!exists) {
      throw new NotFoundException('Entertainment not found');
    }
  }

  private toCreateInput(dto: CreateEntertainmentDto): Prisma.entertainmentUncheckedCreateInput {
    return {
      id_cinema: dto.idCinema ?? undefined,
      title: dto.title.trim(),
      description: dto.description,
      image_url: dto.imageUrl,
      start_date: new Date(dto.startDate),
      end_date: dto.endDate ? new Date(dto.endDate) : undefined,
      status: dto.status?.trim(),
      views_count: dto.viewsCount ?? undefined,
      featured: dto.featured ?? undefined,
      id_staff: dto.idStaff ?? undefined,
    };
  }

  private toUpdateInput(dto: UpdateEntertainmentDto): Prisma.entertainmentUncheckedUpdateInput {
    return {
      id_cinema: dto.idCinema ?? undefined,
      title: dto.title ? dto.title.trim() : undefined,
      description: dto.description,
      image_url: dto.imageUrl,
      start_date: dto.startDate ? new Date(dto.startDate) : undefined,
      end_date: dto.endDate ? new Date(dto.endDate) : undefined,
      status: dto.status ? dto.status.trim() : undefined,
      views_count: dto.viewsCount ?? undefined,
      featured: dto.featured ?? undefined,
      id_staff: dto.idStaff ?? undefined,
    };
  }
}
