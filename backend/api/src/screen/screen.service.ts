import { Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CreateScreenDto } from './dto/create-screen.dto';
import { UpdateScreenDto } from './dto/update-screen.dto';

export interface ScreenQueryParams {
  page?: number;
  limit?: number;
  cinemaId?: number;
  screenTypeId?: number;
  status?: string;
  search?: string;
  minCapacity?: number;
}

@Injectable()
export class ScreenService {
  constructor(private readonly prisma: PrismaService) { }

  async create(dto: CreateScreenDto) {
    const data: Prisma.screenUncheckedCreateInput = {
      id_cinema: dto.idCinema ?? undefined,
      screen_name: dto.screenName.trim(),
      capacity: dto.capacity,
      status: dto.status?.trim(),
      id_screentype: dto.idScreenType ?? undefined,
    };

    return this.prisma.screen.create({ data });
  }

  async findAll(params: ScreenQueryParams = {}) {
    const page = Math.max(1, params.page ?? 1);
    const limit = Math.min(100, Math.max(1, params.limit ?? 20));
    const where: Prisma.screenWhereInput = {
      id_cinema: params.cinemaId ?? undefined,
      id_screentype: params.screenTypeId ?? undefined,
      status: params.status?.trim(),
      capacity: params.minCapacity ? { gte: params.minCapacity } : undefined,
      screen_name: params.search ? { contains: params.search } : undefined,
    };

    const [items, total] = await this.prisma.$transaction([
      this.prisma.screen.findMany({
        where,
        skip: (page - 1) * limit,
        take: limit,
        orderBy: { screen_name: 'asc' },
        include: {
          cinema: true,
          screen_type: true,
        },
      }),
      this.prisma.screen.count({ where }),
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
    const record = await this.prisma.screen.findUnique({
      where: { id_screen: id },
      include: {
        cinema: true,
        screen_type: true,
      },
    });
    if (!record) {
      throw new NotFoundException('Screen not found');
    }
    return record;
  }

  async update(id: number, dto: UpdateScreenDto) {
    await this.ensureExists(id);
    const data: Prisma.screenUncheckedUpdateInput = {
      id_cinema: dto.idCinema ?? undefined,
      screen_name: dto.screenName ? dto.screenName.trim() : undefined,
      capacity: dto.capacity ?? undefined,
      status: dto.status ? dto.status.trim() : undefined,
      id_screentype: dto.idScreenType ?? undefined,
    };

    return this.prisma.screen.update({
      where: { id_screen: id },
      data,
      include: {
        cinema: true,
        screen_type: true,
      },
    });
  }

  async remove(id: number) {
    await this.ensureExists(id);
    return this.prisma.screen.delete({
      where: { id_screen: id },
      include: {
        cinema: true,
        screen_type: true,
      },
    });
  }

  private async ensureExists(id: number) {
    const exists = await this.prisma.screen.findUnique({
      where: { id_screen: id },
      select: { id_screen: true },
    });
    if (!exists) {
      throw new NotFoundException('Screen not found');
    }
  }
}
