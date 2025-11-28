import { Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CreateBookingDto } from './dto/create-booking.dto';
import { UpdateBookingDto } from './dto/update-booking.dto';

export interface BookingQueryParams {
  page?: number;
  limit?: number;
  userId?: number;
  memberId?: number;
  showtimeId?: number;
  staffId?: number;
  promotionId?: number;
  paymentStatus?: string;
  bookingStatus?: string;
  bookingCode?: string;
}

@Injectable()
export class BookingsService {
  constructor(private readonly prisma: PrismaService) { }

  async create(dto: CreateBookingDto) {
    const data: Prisma.bookingsUncheckedCreateInput = {
      id_users: dto.idUsers ?? undefined,
      id_member: dto.idMember ?? undefined,
      id_showtime: dto.idShowtime ?? undefined,
      id_staff: dto.idStaff ?? undefined,
      id_promotions: dto.idPromotions ?? undefined,
      booking_date: dto.bookingDate ? new Date(dto.bookingDate) : undefined,
      total_amount: dto.totalAmount,
      payment_status: dto.paymentStatus?.trim(),
      booking_status: dto.bookingStatus?.trim(),
      booking_code: dto.bookingCode?.trim(),
      guest_email: dto.guestEmail?.trim(),
      guest_name: dto.guestName?.trim(),
      guest_phone: dto.guestPhone?.trim(),
    };

    // Create booking with seats and products in a transaction
    return this.prisma.$transaction(async (tx) => {
      // 1. Create the booking
      const booking = await tx.bookings.create({
        data,
        include: this.defaultInclude(),
      });

      // 2. Create detail_booking records for seats
      if (dto.seats && dto.seats.length > 0) {
        for (const seat of dto.seats) {
          await tx.detail_booking.create({
            data: {
              id_booking: booking.id_booking,
              id_seats: seat.idSeats,
              price: seat.price ?? 0,
            },
          });
        }
      }

      // 3. Create order_product records for products
      if (dto.products && dto.products.length > 0) {
        for (const product of dto.products) {
          await tx.order_product.create({
            data: {
              id_booking: booking.id_booking,
              id_product: product.idProduct,
              quantity: product.quantity,
              price: product.price ?? 0,
              order_status: 'pending',
            },
          });
        }
      }

      // 4. Return booking with details
      return tx.bookings.findUnique({
        where: { id_booking: booking.id_booking },
        include: this.defaultInclude(),
      });
    });
  }

  async findAll(params: BookingQueryParams = {}) {
    const page = Math.max(1, params.page ?? 1);
    const limit = Math.min(100, Math.max(1, params.limit ?? 20));

    const where: Prisma.bookingsWhereInput = {
      id_users: params.userId ?? undefined,
      id_member: params.memberId ?? undefined,
      id_showtime: params.showtimeId ?? undefined,
      id_staff: params.staffId ?? undefined,
      id_promotions: params.promotionId ?? undefined,
      payment_status: params.paymentStatus?.trim(),
      booking_status: params.bookingStatus?.trim(),
      booking_code: params.bookingCode ? { equals: params.bookingCode.trim() } : undefined,
    };

    const [items, total] = await this.prisma.$transaction([
      this.prisma.bookings.findMany({
        where,
        skip: (page - 1) * limit,
        take: limit,
        orderBy: { booking_date: 'desc' },
        include: this.defaultInclude(),
      }),
      this.prisma.bookings.count({ where }),
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
    const booking = await this.prisma.bookings.findUnique({
      where: { id_booking: id },
      include: this.defaultInclude(),
    });
    if (!booking) {
      throw new NotFoundException('Booking not found');
    }
    return booking;
  }

  async update(id: number, dto: UpdateBookingDto) {
    await this.ensureExists(id);
    const data: Prisma.bookingsUncheckedUpdateInput = {
      id_users: dto.idUsers ?? undefined,
      id_member: dto.idMember ?? undefined,
      id_showtime: dto.idShowtime ?? undefined,
      id_staff: dto.idStaff ?? undefined,
      id_promotions: dto.idPromotions ?? undefined,
      booking_date: dto.bookingDate ? new Date(dto.bookingDate) : undefined,
      total_amount: dto.totalAmount ?? undefined,
      payment_status: dto.paymentStatus ? dto.paymentStatus.trim() : undefined,
      booking_status: dto.bookingStatus ? dto.bookingStatus.trim() : undefined,
      booking_code: dto.bookingCode ? dto.bookingCode.trim() : undefined,
    };

    return this.prisma.bookings.update({
      where: { id_booking: id },
      data,
      include: this.defaultInclude(),
    });
  }

  async remove(id: number) {
    await this.ensureExists(id);
    return this.prisma.bookings.delete({
      where: { id_booking: id },
    });
  }

  private async ensureExists(id: number) {
    const exists = await this.prisma.bookings.findUnique({
      where: { id_booking: id },
      select: { id_booking: true },
    });
    if (!exists) {
      throw new NotFoundException('Booking not found');
    }
  }

  private defaultInclude(): Prisma.bookingsInclude {
    return {
      user: true,
      member: true,
      showtime: true,
      staff: true,
      promotion: true,
      payments: true,
      details: true,
    };
  }
}
