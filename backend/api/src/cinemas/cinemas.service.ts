import { Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CreateCinemaDto } from './dto/create-cinema.dto';
import { UpdateCinemaDto } from './dto/update-cinema.dto';

export interface CinemaQueryParams {
  page?: number;
  limit?: number;
  city?: string;
  status?: string;
  search?: string;
}

@Injectable()
export class CinemasService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: CreateCinemaDto) {
    const data: Prisma.cinemasUncheckedCreateInput = {
      cinema_name: dto.cinemaName.trim(),
      address: dto.address.trim(),
      city: dto.city.trim(),
      description: dto.description,
      image: dto.image,
      contact_number: dto.contactNumber,
      email: dto.email ? dto.email.toLowerCase() : undefined,
      status: dto.status ? dto.status.trim() : undefined,
    };

    return this.prisma.cinemas.create({ data });
  }

  async findAll(params: CinemaQueryParams = {}) {
    const page = Math.max(1, params.page ?? 1);
    const limit = Math.min(100, Math.max(1, params.limit ?? 20));
    const where: Prisma.cinemasWhereInput = {
      city: params.city ? params.city : undefined,
      status: params.status?.trim(),
      OR: params.search
        ? [
            { cinema_name: { contains: params.search } },
            { address: { contains: params.search } },
          ]
        : undefined,
    };

    const [items, total] = await this.prisma.$transaction([
      this.prisma.cinemas.findMany({
        where,
        skip: (page - 1) * limit,
        take: limit,
        orderBy: { cinema_name: 'asc' },
        include: {
          _count: {
            select: { screens: true, operation_hours: true },
          },
        },
      }),
      this.prisma.cinemas.count({ where }),
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
    const cinema = await this.prisma.cinemas.findUnique({
      where: { id_cinema: id },
      include: {
        operation_hours: true,
        screens: true,
        _count: {
          select: { screens: true, operation_hours: true },
        },
      },
    });
    if (!cinema) {
      throw new NotFoundException('Cinema not found');
    }
    return cinema;
  }

  async update(id: number, dto: UpdateCinemaDto) {
    await this.ensureExists(id);
    const data: Prisma.cinemasUncheckedUpdateInput = {
      cinema_name: dto.cinemaName ? dto.cinemaName.trim() : undefined,
      address: dto.address ? dto.address.trim() : undefined,
      city: dto.city ? dto.city.trim() : undefined,
      description: dto.description,
      image: dto.image,
      contact_number: dto.contactNumber,
      email: dto.email ? dto.email.toLowerCase() : undefined,
      status: dto.status ? dto.status.trim() : undefined,
    };

    return this.prisma.cinemas.update({
      where: { id_cinema: id },
      data,
    });
  }

  async remove(id: number) {
    await this.ensureExists(id);
    return this.prisma.cinemas.delete({ where: { id_cinema: id } });
  }

  private async ensureExists(id: number) {
    const exists = await this.prisma.cinemas.findUnique({
      where: { id_cinema: id },
      select: { id_cinema: true },
    });
    if (!exists) {
      throw new NotFoundException('Cinema not found');
    }
  }
}
