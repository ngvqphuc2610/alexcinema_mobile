import { Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CreateSeatDto } from './dto/create-seat.dto';
import { UpdateSeatDto } from './dto/update-seat.dto';

export interface SeatQueryParams {
  page?: number;
  limit?: number;
  screenId?: number;
  seatTypeId?: number;
  status?: string;
  seatRow?: string;
  seatNumber?: number;
}

@Injectable()
export class SeatService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: CreateSeatDto) {
    const data: Prisma.seatUncheckedCreateInput = {
      id_screen: dto.idScreen ?? undefined,
      id_seattype: dto.idSeatType ?? undefined,
      seat_row: dto.seatRow.trim().toUpperCase(),
      seat_number: dto.seatNumber,
      status: dto.status?.trim(),
    };

    return this.prisma.seat.create({ data });
  }

  async findAll(params: SeatQueryParams = {}) {
    const page = Math.max(1, params.page ?? 1);
    const limit = Math.min(100, Math.max(1, params.limit ?? 20));

    const where: Prisma.seatWhereInput = {
      id_screen: params.screenId ?? undefined,
      id_seattype: params.seatTypeId ?? undefined,
      status: params.status?.trim(),
      seat_row: params.seatRow ? { contains: params.seatRow.toUpperCase() } : undefined,
      seat_number: params.seatNumber ?? undefined,
    };

    const [items, total] = await this.prisma.$transaction([
      this.prisma.seat.findMany({
        where,
        skip: (page - 1) * limit,
        take: limit,
        orderBy: [{ id_screen: 'asc' }, { seat_row: 'asc' }, { seat_number: 'asc' }],
      }),
      this.prisma.seat.count({ where }),
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
    const seat = await this.prisma.seat.findUnique({
      where: { id_seats: id },
    });
    if (!seat) {
      throw new NotFoundException('Seat not found');
    }
    return seat;
  }

  async update(id: number, dto: UpdateSeatDto) {
    await this.ensureExists(id);
    const data: Prisma.seatUncheckedUpdateInput = {
      id_screen: dto.idScreen ?? undefined,
      id_seattype: dto.idSeatType ?? undefined,
      seat_row: dto.seatRow ? dto.seatRow.trim().toUpperCase() : undefined,
      seat_number: dto.seatNumber ?? undefined,
      status: dto.status ? dto.status.trim() : undefined,
    };

    return this.prisma.seat.update({
      where: { id_seats: id },
      data,
    });
  }

  async remove(id: number) {
    await this.ensureExists(id);
    return this.prisma.seat.delete({ where: { id_seats: id } });
  }

  private async ensureExists(id: number) {
    const exists = await this.prisma.seat.findUnique({
      where: { id_seats: id },
      select: { id_seats: true },
    });
    if (!exists) {
      throw new NotFoundException('Seat not found');
    }
  }
}
