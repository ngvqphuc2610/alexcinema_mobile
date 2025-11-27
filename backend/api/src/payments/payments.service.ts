import { BadRequestException, Injectable, Logger, NotFoundException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import axios from 'axios';
import * as crypto from 'crypto';
import { Prisma } from '@prisma/client';

import { PrismaService } from '../prisma/prisma.service';
import { PaymentMethodsService } from '../payment_methods/payment_methods.service';
import { MailService } from '../mail/mail.service';
import { CreateZaloPayOrderDto } from './dto/create-zalopay-order.dto';
import { ZaloPayCallbackDto } from './dto/zalopay-callback.dto';

interface ZaloConfig {
  appId: number;
  key1: string;
  key2: string;
  endpoint: string;
  callbackUrl: string;
  redirectUrl?: string;
}

@Injectable()
export class PaymentsService {
  private readonly logger = new Logger(PaymentsService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly configService: ConfigService,
    private readonly paymentMethodsService: PaymentMethodsService,
    private readonly mailService: MailService,
  ) { }

  async createZaloPayOrder(dto: CreateZaloPayOrderDto) {
    const { appId, key1, endpoint, callbackUrl, redirectUrl } = this.getZaloConfig();
    const booking = await this.prisma.bookings.findUnique({
      where: { id_booking: dto.bookingId },
    });

    if (!booking) {
      throw new NotFoundException('Booking not found');
    }

    if (booking.payment_status === 'paid') {
      throw new BadRequestException('Booking has already been paid');
    }

    const method = await this.paymentMethodsService.ensureZaloPayMethod();
    const amount = dto.amount ?? Number(booking.total_amount);

    if (!Number.isFinite(amount) || amount <= 0) {
      throw new BadRequestException('Invalid amount for payment');
    }

    const appTransId = this.buildAppTransId(booking.id_booking);
    const appUser = `booking_${booking.id_booking}`;
    const appTime = Date.now();
    const embedData = JSON.stringify({
      bookingId: booking.id_booking,
      redirecturl: redirectUrl,
      callbackurl: callbackUrl,
    });
    const item = '[]';

    const dataMac = `${appId}|${appTransId}|${appUser}|${amount}|${appTime}|${embedData}|${item}`;
    const mac = crypto.createHmac('sha256', key1).update(dataMac).digest('hex');

    const payload = {
      app_id: appId,
      app_user: appUser,
      app_trans_id: appTransId,
      app_time: appTime,
      amount,
      description: dto.description ?? `Thanh toan ve xem phim #${booking.booking_code ?? booking.id_booking}`,
      item,
      embed_data: embedData,
      callback_url: callbackUrl,
      mac,
    };

    const response = await axios.post(`${endpoint}/v2/create`, payload, {
      headers: { 'Content-Type': 'application/json' },
    });

    const data = response.data ?? {};
    if (data.return_code !== 1) {
      throw new BadRequestException(
        `ZaloPay error: ${data.return_message ?? 'Unknown error'}`,
      );
    }

    const paymentPayload: Prisma.paymentsCreateInput = {
      booking: { connect: { id_booking: booking.id_booking } },
      method: { connect: { id_payment_method: method.id_payment_method } },
      payment_method: method.method_code,
      amount: new Prisma.Decimal(amount),
      status: 'pending',
      transaction_id: appTransId,
      provider_code: method.method_code,
      provider_order_id: appTransId,
      provider_return_code: String(data.return_code ?? ''),
      provider_return_message: data.return_message ?? data.sub_return_message ?? null,
      provider_payload: data,
      zp_app_trans_id: appTransId,
      zp_trans_token: data.zp_trans_token ?? null,
      zp_order_url: data.order_url ?? null,
      zp_pay_url: data.order_url ?? data.qr_code ?? null,
      zp_return_code: data.return_code ?? null,
      zp_return_message: data.return_message ?? null,
      zp_sub_message: data.sub_return_message ?? null,
      payment_details: JSON.stringify(data),
    };

    await this.prisma.$transaction([
      this.prisma.payments.upsert({
        where: { transaction_id: appTransId },
        create: paymentPayload,
        update: paymentPayload,
      }),
      this.prisma.bookings.update({
        where: { id_booking: booking.id_booking },
        data: { payment_status: 'unpaid' }, // Changed from 'pending' to 'unpaid'
      }),
    ]);

    return {
      appTransId,
      zpTransToken: data.zp_trans_token,
      orderUrl: data.order_url,
      payUrl: data.order_url ?? data.qr_code,
      amount,
      returnMessage: data.return_message,
    };
  }

  async handleZaloPayCallback(dto: ZaloPayCallbackDto) {
    const { key2 } = this.getZaloConfig();
    const mac = crypto.createHmac('sha256', key2).update(dto.data).digest('hex');

    if (mac !== dto.mac) {
      this.logger.warn('ZaloPay callback MAC mismatch');
      return { return_code: -1, return_message: 'mac not equal' };
    }

    let payload: any;
    try {
      payload = JSON.parse(dto.data);
    } catch (error) {
      this.logger.error('Cannot parse callback data', error as Error);
      return { return_code: -1, return_message: 'invalid data' };
    }

    const appTransId: string | undefined = payload.app_trans_id;
    if (!appTransId) {
      return { return_code: -1, return_message: 'missing app_trans_id' };
    }

    const status = payload.return_code === 1 ? 'success' : 'failed';
    const bookingId = Number(
      this.safeParseEmbed(payload.embeddata)?.bookingId ??
      this.safeParseEmbed(payload.embed_data)?.bookingId,
    );

    const method = await this.paymentMethodsService.ensureZaloPayMethod();

    await this.prisma.$transaction(async (tx) => {
      const existing = await tx.payments.findUnique({
        where: { transaction_id: appTransId },
      });

      if (!existing) {
        await tx.payments.create({
          data: {
            booking: bookingId ? { connect: { id_booking: bookingId } } : undefined,
            method: { connect: { id_payment_method: method.id_payment_method } },
            payment_method: method.method_code,
            amount: new Prisma.Decimal(payload.amount ?? 0),
            status: 'pending',
            transaction_id: appTransId,
            provider_code: method.method_code,
            provider_order_id: appTransId,
            provider_payload: payload,
            zp_app_trans_id: appTransId,
          },
        });
      }

      await tx.payments.update({
        where: { transaction_id: appTransId },
        data: {
          status,
          booking: bookingId ? { connect: { id_booking: bookingId } } : undefined,
          provider_trans_id: payload.zp_trans_id ?? null,
          provider_return_code: payload.return_code ? String(payload.return_code) : null,
          provider_return_message: payload.return_message ?? payload.desc ?? null,
          provider_payload: payload,
          zp_trans_id: payload.zp_trans_id ?? null,
          zp_return_code: payload.return_code ?? null,
          zp_return_message: payload.return_message ?? payload.desc ?? null,
          zp_sub_message: payload.sub_return_message ?? payload.sub_desc ?? null,
          payment_details: dto.data,
          payment_date: new Date(),
        },
      });

      if (bookingId) {
        await tx.bookings.update({
          where: { id_booking: bookingId },
          data: { payment_status: status === 'success' ? 'paid' : 'unpaid' }, // Changed 'failed' to 'unpaid'
        });
      }
    });

    if (status === 'success' && bookingId) {
      await this.sendTicketEmail(bookingId, {
        transactionId: appTransId,
        paymentMethod: method.method_name,
        amount: Number(payload.amount ?? 0),
        paymentStatus: status,
      });
    }

    return { return_code: 1, return_message: 'success' };
  }

  async getPaymentStatus(transactionId: string) {
    if (!transactionId?.trim()) {
      throw new BadRequestException('transactionId is required');
    }

    const payment = await this.prisma.payments.findUnique({
      where: { transaction_id: transactionId.trim() },
      include: {
        booking: true,
      },
    });

    if (!payment) {
      throw new NotFoundException('Payment not found');
    }

    return {
      transactionId: payment.transaction_id,
      status: payment.status,
      bookingId: payment.id_booking,
      bookingCode: payment.booking?.booking_code,
      bookingStatus: payment.booking?.booking_status,
      paymentStatus: payment.booking?.payment_status,
      amount: payment.amount ? Number(payment.amount) : null,
      updatedAt: payment.payment_date ?? null,
    };
  }

  private async sendTicketEmail(
    bookingId: number,
    options: { amount: number; transactionId: string; paymentMethod?: string; paymentStatus?: string },
  ) {
    const booking = await this.prisma.bookings.findUnique({
      where: { id_booking: bookingId },
      include: {
        user: true,
        member: { include: { user: true } },
        showtime: {
          include: {
            movie: true,
            screen: { include: { cinema: true } },
          },
        },
        details: { include: { seat: true } },
      },
    });

    if (!booking) {
      this.logger.warn(`Cannot send ticket email: booking ${bookingId} not found`);
      return;
    }

    const recipient =
      booking.user?.email ??
      booking.member?.user?.email;

    if (!recipient) {
      this.logger.warn(`Cannot send ticket email: no email for booking ${bookingId}`);
      return;
    }

    const seats = booking.details
      ?.map((detail) => {
        if (!detail.seat) return undefined;
        const row = detail.seat.seat_row ?? '';
        const num = detail.seat.seat_number ?? '';
        return `${row}${num}`;
      })
      .filter((item): item is string => Boolean(item)) ?? [];

    const showtimeStart = this.formatShowtime(booking.showtime);
    const amountNumber = Number(options.amount ?? booking.total_amount ?? 0);

    await this.mailService.sendBookingTicketEmail({
      to: recipient,
      bookingCode: booking.booking_code ?? options.transactionId,
      movieTitle: booking.showtime?.movie?.title ?? 'N/A',
      cinemaName: booking.showtime?.screen?.cinema?.cinema_name ?? null,
      screenName: booking.showtime?.screen?.screen_name ?? null,
      showtimeStart,
      seats,
      amount: Number.isFinite(amountNumber) ? amountNumber : 0,
      paymentMethod: options.paymentMethod,
      paymentStatus: options.paymentStatus,
      bookingDate: booking.booking_date?.toISOString(),
    });
  }

  private buildAppTransId(bookingId: number) {
    const now = new Date();
    const day = now.getDate().toString().padStart(2, '0');
    const month = (now.getMonth() + 1).toString().padStart(2, '0');
    const year = now.getFullYear().toString().slice(-2);
    const random = Math.floor(Math.random() * 9000) + 1000;
    return `${year}${month}${day}_${bookingId}_${random}`;
  }

  private formatShowtime(showtime?: any) {
    if (!showtime) return 'N/A';
    const dateText = showtime.show_date
      ? new Date(showtime.show_date).toLocaleDateString('vi-VN')
      : '';
    const timeText = showtime.start_time
      ? new Date(showtime.start_time).toLocaleTimeString('vi-VN', {
        hour: '2-digit',
        minute: '2-digit',
      })
      : '';
    return [dateText, timeText].filter(Boolean).join(' ');
  }

  private getZaloConfig(): ZaloConfig {
    const appId = Number(this.configService.get<number>('ZP_APP_ID'));
    const key1 = this.configService.get<string>('ZP_KEY1') ?? '';
    const key2 = this.configService.get<string>('ZP_KEY2') ?? '';
    const endpoint =
      this.configService.get<string>('ZP_ENDPOINT') ??
      'https://sb-openapi.zalopay.vn';
    const callbackUrl =
      this.configService.get<string>('ZP_CALLBACK_URL') ??
      `${this.configService.get<string>('API_URL') ?? ''}/payments/zalopay/callback`;
    const redirectUrl = this.configService.get<string>('ZP_REDIRECT_URL');

    if (!appId || !key1 || !key2) {
      throw new BadRequestException('Missing ZaloPay configuration (app id / key1 / key2)');
    }

    return { appId, key1, key2, endpoint, callbackUrl, redirectUrl };
  }

  private safeParseEmbed(raw: unknown): any | undefined {
    if (typeof raw !== 'string' || raw.trim().length === 0) {
      return undefined;
    }
    try {
      return JSON.parse(raw);
    } catch {
      return undefined;
    }
  }
}
