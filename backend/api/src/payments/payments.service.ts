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
import { CreateVNPayOrderDto } from './dto/create-vnpay-order.dto';
import { VNPayCallbackDto } from './dto/vnpay-callback.dto';
import { CreateMoMoOrderDto } from './dto/create-momo-order.dto';
import { MoMoCallbackDto } from './dto/momo-callback.dto';

interface ZaloConfig {
  appId: number;
  key1: string;
  key2: string;
  endpoint: string;
  callbackUrl: string;
  redirectUrl?: string;
}

interface VNPayConfig {
  tmnCode: string;
  hashSecret: string;
  url: string;
  returnUrl: string;
  apiUrl?: string;
}

interface MoMoConfig {
  partnerCode: string;
  accessKey: string;
  secretKey: string;
  endpoint: string;
  returnUrl: string;
  notifyUrl: string;
}

@Injectable()
export class PaymentsService {
  private readonly logger = new Logger(PaymentsService.name);

  // Track sent emails to prevent duplicates (bookingId -> timestamp)
  private readonly emailSentCache = new Map<number, number>();
  private readonly EMAIL_CACHE_TTL = 5 * 60 * 1000; // 5 minutes

  constructor(
    private readonly prisma: PrismaService,
    private readonly configService: ConfigService,
    private readonly paymentMethodsService: PaymentMethodsService,
    private readonly mailService: MailService,
  ) {
    // Clean up cache periodically
    setInterval(() => this.cleanupEmailCache(), 60 * 1000); // Every 1 minute
  }

  private cleanupEmailCache() {
    const now = Date.now();
    for (const [bookingId, timestamp] of this.emailSentCache.entries()) {
      if (now - timestamp > this.EMAIL_CACHE_TTL) {
        this.emailSentCache.delete(bookingId);
      }
    }
  }

  async getAllPayments(params: {
    page?: number;
    limit?: number;
    status?: string;
    bookingCode?: string;
    transactionId?: string;
    methodCode?: string;
  }) {
    const page = params.page ?? 1;
    const limit = params.limit ?? 20;
    const skip = (page - 1) * limit;

    const where: any = {};

    if (params.status) {
      // Map API status to database status
      if (params.status === 'success') {
        where.status = 'completed';
      } else {
        where.status = params.status;
      }
    }

    if (params.transactionId) {
      where.transaction_id = { contains: params.transactionId };
    }

    if (params.methodCode) {
      where.payment_method = params.methodCode;
    }

    if (params.bookingCode) {
      where.booking = {
        booking_code: { contains: params.bookingCode },
      };
    }

    const [items, total] = await Promise.all([
      this.prisma.payments.findMany({
        where,
        include: {
          booking: true,
          method: true,
        },
        orderBy: { payment_date: 'desc' },
        skip,
        take: limit,
      }),
      this.prisma.payments.count({ where }),
    ]);

    // Map database status to API status
    const mappedItems = items.map((item) => ({
      ...item,
      status: item.status === 'completed' ? 'success' : item.status,
    }));

    return {
      items: mappedItems,
      meta: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

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
      // Note: ZaloPay sandbox doesn't support redirect_url, it uses deep link from AndroidManifest
      mac,
    };

    this.logger.log(`Creating ZaloPay order for transaction: ${appTransId}`);
    this.logger.log(`Full payload: ${JSON.stringify(payload, null, 2)}`);

    const response = await axios.post(`${endpoint}/v2/create`, payload, {
      headers: { 'Content-Type': 'application/json' },
    });

    const data = response.data ?? {};
    this.logger.log(`ZaloPay response: ${JSON.stringify(data, null, 2)}`);

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
          data: {
            payment_status: status === 'success' ? 'paid' : 'unpaid',
            booking_status: status === 'success' ? 'confirmed' : 'pending',
          },
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

    // Map database status to API status for consistency
    // Database: 'pending', 'completed', 'refunded'
    // API: 'pending', 'success', 'failed'
    let apiStatus = payment.status;
    if (payment.status === 'completed') {
      apiStatus = 'success';
    }

    return {
      transactionId: payment.transaction_id,
      status: apiStatus,
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
    // Check if email already sent recently (within 5 minutes)
    const lastSent = this.emailSentCache.get(bookingId);
    const now = Date.now();

    if (lastSent && (now - lastSent) < this.EMAIL_CACHE_TTL) {
      this.logger.warn(
        `⏭️ Skipping duplicate email for booking ${bookingId} (sent ${Math.round((now - lastSent) / 1000)}s ago)`
      );
      return;
    }

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

    // ← SỬA: Thêm type assertion hoặc optional chaining
    const recipient =
      booking.user?.email ??
      booking.member?.user?.email ??
      (booking as any).guest_email; // Type assertion

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

    // Mark email as sent
    this.emailSentCache.set(bookingId, now);
    this.logger.log(`📬 Email sent and cached for booking ${bookingId}`);
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

  // ==================== VNPay Methods ====================

  async createVNPayOrder(dto: CreateVNPayOrderDto) {
    const { tmnCode, hashSecret, url, returnUrl } = this.getVNPayConfig();
    const booking = await this.prisma.bookings.findUnique({
      where: { id_booking: dto.bookingId },
    });

    if (!booking) {
      throw new NotFoundException('Booking not found');
    }

    if (booking.payment_status === 'paid') {
      throw new BadRequestException('Booking has already been paid');
    }

    const method = await this.paymentMethodsService.ensureVNPayMethod();
    const amount = dto.amount ?? Number(booking.total_amount);

    if (!Number.isFinite(amount) || amount <= 0) {
      throw new BadRequestException('Invalid amount for payment');
    }

    const vnpTxnRef = this.buildAppTransId(booking.id_booking);
    const createDate = this.formatVNPayDate(new Date());
    const locale = dto.locale ?? 'vn';
    const currCode = 'VND';
    const orderInfo = dto.description ?? `Thanh toan ve xem phim #${booking.booking_code ?? booking.id_booking}`;

    // VNPay requires amount in smallest unit (VND has no decimal, so multiply by 100)
    const vnpAmount = Math.round(amount * 100);

    const vnpParams: Record<string, string> = {
      vnp_Version: '2.1.0',
      vnp_Command: 'pay',
      vnp_TmnCode: tmnCode,
      vnp_Amount: String(vnpAmount),
      vnp_CreateDate: createDate,
      vnp_CurrCode: currCode,
      vnp_IpAddr: '127.0.0.1', // Should be replaced with actual IP in production
      vnp_Locale: locale,
      vnp_OrderInfo: orderInfo,
      vnp_OrderType: 'other',
      vnp_ReturnUrl: returnUrl,
      vnp_TxnRef: vnpTxnRef,
    };

    if (dto.bankCode) {
      vnpParams.vnp_BankCode = dto.bankCode;
    }

    // Sort params and create secure hash
    const sortedParams = this.sortVNPayParams(vnpParams);
    const signData = new URLSearchParams(sortedParams).toString();
    const secureHash = crypto
      .createHmac('sha512', hashSecret)
      .update(Buffer.from(signData, 'utf-8'))
      .digest('hex');

    this.logger.log(`VNPay Sign Data: ${signData}`);
    this.logger.log(`VNPay Hash Secret (first 10 chars): ${hashSecret.substring(0, 10)}...`);
    this.logger.log(`VNPay Generated Hash: ${secureHash}`);

    const paymentUrl = `${url}?${signData}&vnp_SecureHash=${secureHash}`;

    this.logger.log(`Creating VNPay order for transaction: ${vnpTxnRef}`);
    this.logger.log(`Payment URL: ${paymentUrl}`);

    const paymentPayload: Prisma.paymentsCreateInput = {
      booking: { connect: { id_booking: booking.id_booking } },
      method: { connect: { id_payment_method: method.id_payment_method } },
      payment_method: method.method_code,
      amount: new Prisma.Decimal(amount),
      status: 'pending',
      transaction_id: vnpTxnRef,
      provider_code: method.method_code,
      provider_order_id: vnpTxnRef,
      payment_details: JSON.stringify({ vnpParams }),
    };

    await this.prisma.$transaction([
      this.prisma.payments.upsert({
        where: { transaction_id: vnpTxnRef },
        create: paymentPayload,
        update: paymentPayload,
      }),
      this.prisma.bookings.update({
        where: { id_booking: booking.id_booking },
        data: { payment_status: 'unpaid' },
      }),
    ]);

    return {
      txnRef: vnpTxnRef,
      paymentUrl,
      amount,
    };
  }

  async handleVNPayCallback(dto: VNPayCallbackDto) {
    const { hashSecret } = this.getVNPayConfig();
    const secureHash = dto.vnp_SecureHash;
    const { vnp_SecureHash, vnp_SecureHashType, ...params } = dto;

    this.logger.log(`VNPay Callback received for: ${dto.vnp_TxnRef}`);
    this.logger.log(`VNPay Callback params: ${JSON.stringify(params, null, 2)}`);

    // Verify secure hash
    const sortedParams = this.sortVNPayParams(params as any);
    const signData = new URLSearchParams(sortedParams).toString();
    const checkHash = crypto
      .createHmac('sha512', hashSecret)
      .update(Buffer.from(signData, 'utf-8'))
      .digest('hex');

    this.logger.log(`VNPay Callback Sign Data: ${signData}`);
    this.logger.log(`VNPay Received Hash: ${secureHash}`);
    this.logger.log(`VNPay Computed Hash: ${checkHash}`);

    if (secureHash !== checkHash) {
      this.logger.warn('VNPay callback hash mismatch');
      this.logger.warn(`Expected: ${checkHash}`);
      this.logger.warn(`Received: ${secureHash}`);
      return { RspCode: '97', Message: 'Invalid Signature' };
    }

    const vnpTxnRef = dto.vnp_TxnRef;
    const responseCode = dto.vnp_ResponseCode;
    const transactionStatus = dto.vnp_TransactionStatus;
    const amount = Number(dto.vnp_Amount) / 100; // Convert back from smallest unit

    // Map VNPay response codes to database-allowed status values
    // Database constraint only allows: 'pending', 'completed', 'refunded'
    const isSuccess = responseCode === '00' && transactionStatus === '00';
    const status = isSuccess ? 'completed' : 'pending'; // Use 'pending' for failed to avoid constraint violation

    const method = await this.paymentMethodsService.ensureVNPayMethod();

    let bookingIdForEmail: number | null = null;

    await this.prisma.$transaction(async (tx) => {
      const existing = await tx.payments.findUnique({
        where: { transaction_id: vnpTxnRef },
      });

      if (!existing) {
        this.logger.warn(`Payment not found for VNPay callback: ${vnpTxnRef}`);
        return;
      }

      await tx.payments.update({
        where: { transaction_id: vnpTxnRef },
        data: {
          status,
          provider_trans_id: dto.vnp_TransactionNo,
          provider_return_code: responseCode,
          provider_return_message: `Bank: ${dto.vnp_BankCode}`,
          provider_payload: dto as any,
          payment_details: JSON.stringify(dto),
        },
      });

      if (existing.id_booking && status === 'completed') {
        await tx.bookings.update({
          where: { id_booking: existing.id_booking },
          data: {
            payment_status: 'paid',
            booking_status: 'confirmed',
          },
        });
        bookingIdForEmail = existing.id_booking;
      }
    });

    // Send email after successful payment
    if (isSuccess && bookingIdForEmail) {
      await this.sendTicketEmail(bookingIdForEmail, {
        transactionId: vnpTxnRef,
        paymentMethod: method.method_name,
        amount: amount,
        paymentStatus: 'completed',
      });
    }

    return { RspCode: '00', Message: 'Confirm Success' };
  }

  private getVNPayConfig(): VNPayConfig {
    const tmnCode = this.configService.get<string>('VNP_TMN_CODE') ?? '';
    const hashSecret = this.configService.get<string>('VNP_HASH_SECRET') ?? '';
    const url = this.configService.get<string>('VNP_URL') ?? 'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html';
    const returnUrl =
      this.configService.get<string>('VNP_RETURN_URL') ??
      `${this.configService.get<string>('API_URL') ?? ''}/payments/vnpay/return`;

    if (!tmnCode || !hashSecret) {
      throw new BadRequestException('Missing VNPay configuration (TMN Code / Hash Secret)');
    }

    return { tmnCode, hashSecret, url, returnUrl };
  }

  private sortVNPayParams(params: Record<string, string>): Record<string, string> {
    const sorted: Record<string, string> = {};
    Object.keys(params)
      .sort()
      .forEach((key) => {
        const val = params[key];
        if (val !== null && val !== undefined && val !== '') {
          sorted[key] = val;
        }
      });
    return sorted;
  }

  private formatVNPayDate(date: Date): string {
    const pad = (n: number) => String(n).padStart(2, '0');
    const year = date.getFullYear();
    const month = pad(date.getMonth() + 1);
    const day = pad(date.getDate());
    const hours = pad(date.getHours());
    const minutes = pad(date.getMinutes());
    const seconds = pad(date.getSeconds());
    return `${year}${month}${day}${hours}${minutes}${seconds}`;
  }

  // ==================== MoMo Methods ====================

  async createMoMoOrder(dto: CreateMoMoOrderDto) {
    const { partnerCode, accessKey, secretKey, endpoint, returnUrl, notifyUrl } = this.getMoMoConfig();
    const booking = await this.prisma.bookings.findUnique({
      where: { id_booking: dto.bookingId },
    });

    if (!booking) {
      throw new NotFoundException('Booking not found');
    }

    if (booking.payment_status === 'paid') {
      throw new BadRequestException('Booking has already been paid');
    }

    const method = await this.paymentMethodsService.ensureMoMoMethod();
    const amount = dto.amount ?? Number(booking.total_amount);

    if (!Number.isFinite(amount) || amount <= 0) {
      throw new BadRequestException('Invalid amount for payment');
    }

    const orderId = this.buildAppTransId(booking.id_booking);
    const requestId = orderId;
    const orderInfo = dto.orderInfo ?? `Thanh toan ve xem phim #${booking.booking_code ?? booking.id_booking}`;
    const requestType = 'captureWallet';
    const extraData = Buffer.from(JSON.stringify({ bookingId: booking.id_booking })).toString('base64');

    // Create signature
    const rawSignature = `accessKey=${accessKey}&amount=${amount}&extraData=${extraData}&ipnUrl=${notifyUrl}&orderId=${orderId}&orderInfo=${orderInfo}&partnerCode=${partnerCode}&redirectUrl=${returnUrl}&requestId=${requestId}&requestType=${requestType}`;
    const signature = crypto.createHmac('sha256', secretKey).update(rawSignature).digest('hex');

    const payload = {
      partnerCode,
      partnerName: 'Alex Cinema',
      storeId: 'AlexCinema',
      requestId,
      amount,
      orderId,
      orderInfo,
      redirectUrl: returnUrl,
      ipnUrl: notifyUrl,
      lang: 'vi',
      extraData,
      requestType,
      signature,
    };

    this.logger.log(`Creating MoMo order for transaction: ${orderId}`);
    this.logger.log(`MoMo Signature: ${signature}`);

    const response = await axios.post(`${endpoint}/v2/gateway/api/create`, payload, {
      headers: { 'Content-Type': 'application/json' },
    });

    const data = response.data ?? {};
    this.logger.log(`MoMo response: ${JSON.stringify(data, null, 2)}`);

    if (data.resultCode !== 0) {
      throw new BadRequestException(
        `MoMo error: ${data.message ?? 'Unknown error'}`,
      );
    }

    const paymentPayload: Prisma.paymentsCreateInput = {
      booking: { connect: { id_booking: booking.id_booking } },
      method: { connect: { id_payment_method: method.id_payment_method } },
      payment_method: method.method_code,
      amount: new Prisma.Decimal(amount),
      status: 'pending',
      transaction_id: orderId,
      provider_code: method.method_code,
      provider_order_id: orderId,
      provider_return_code: String(data.resultCode ?? ''),
      provider_return_message: data.message ?? null,
      provider_payload: data,
      payment_details: JSON.stringify({ momoParams: payload }),
    };

    await this.prisma.$transaction([
      this.prisma.payments.upsert({
        where: { transaction_id: orderId },
        create: paymentPayload,
        update: paymentPayload,
      }),
      this.prisma.bookings.update({
        where: { id_booking: booking.id_booking },
        data: { payment_status: 'unpaid' },
      }),
    ]);

    return {
      orderId,
      payUrl: data.payUrl,
      deeplink: data.deeplink,
      qrCodeUrl: data.qrCodeUrl,
      amount,
    };
  }

  async handleMoMoCallback(dto: MoMoCallbackDto) {
    const { secretKey } = this.getMoMoConfig();
    const signature = dto.signature;

    this.logger.log(`MoMo Callback received for: ${dto.orderId}`);
    this.logger.log(`MoMo Callback params: ${JSON.stringify(dto, null, 2)}`);

    // Verify signature
    const rawSignature = `accessKey=${this.getMoMoConfig().accessKey}&amount=${dto.amount}&extraData=${dto.extraData ?? ''}&message=${dto.message}&orderId=${dto.orderId}&orderInfo=${dto.orderInfo}&orderType=${dto.orderType}&partnerCode=${dto.partnerCode}&payType=${dto.payType}&requestId=${dto.requestId}&responseTime=${dto.responseTime}&resultCode=${dto.resultCode}&transId=${dto.transId}`;
    const checkSignature = crypto.createHmac('sha256', secretKey).update(rawSignature).digest('hex');

    this.logger.log(`MoMo Received Signature: ${signature}`);
    this.logger.log(`MoMo Computed Signature: ${checkSignature}`);

    if (signature !== checkSignature) {
      this.logger.warn('MoMo callback signature mismatch');
      this.logger.warn(`Expected: ${checkSignature}`);
      this.logger.warn(`Received: ${signature}`);
      return { resultCode: 97, message: 'Invalid Signature' };
    }

    const orderId = dto.orderId;
    const resultCode = dto.resultCode;
    const amount = Number(dto.amount);

    // resultCode '0' means success
    const isSuccess = resultCode === '0';
    const status = isSuccess ? 'completed' : 'pending';

    const method = await this.paymentMethodsService.ensureMoMoMethod();

    await this.prisma.$transaction(async (tx) => {
      const existing = await tx.payments.findUnique({
        where: { transaction_id: orderId },
      });

      if (!existing) {
        this.logger.warn(`Payment not found for MoMo callback: ${orderId}`);
        return;
      }

      await tx.payments.update({
        where: { transaction_id: orderId },
        data: {
          status,
          provider_trans_id: dto.transId,
          provider_return_code: resultCode,
          provider_return_message: dto.message,
          provider_payload: dto as any,
          payment_details: JSON.stringify(dto),
          payment_date: new Date(),
        },
      });

      if (existing.id_booking && status === 'completed') {
        await tx.bookings.update({
          where: { id_booking: existing.id_booking },
          data: {
            payment_status: 'paid',
            booking_status: 'confirmed',
          },
        });
      }
    });

    // Send email after successful payment
    const existing = await this.prisma.payments.findUnique({
      where: { transaction_id: orderId },
    });

    if (isSuccess && existing?.id_booking) {
      await this.sendTicketEmail(existing.id_booking, {
        transactionId: orderId,
        paymentMethod: method.method_name,
        amount: amount,
        paymentStatus: 'completed',
      });
    }

    return { resultCode: 0, message: 'Confirm Success' };
  }

  private getMoMoConfig(): MoMoConfig {
    const partnerCode = this.configService.get<string>('MOMO_PARTNER_CODE') ?? '';
    const accessKey = this.configService.get<string>('MOMO_ACCESS_KEY') ?? '';
    const secretKey = this.configService.get<string>('MOMO_SECRET_KEY') ?? '';
    const endpoint = this.configService.get<string>('MOMO_ENDPOINT') ?? 'https://test-payment.momo.vn';
    const returnUrl =
      this.configService.get<string>('MOMO_RETURN_URL') ??
      `${this.configService.get<string>('API_URL') ?? ''}/payments/momo/return`;
    const notifyUrl =
      this.configService.get<string>('MOMO_NOTIFY_URL') ??
      `${this.configService.get<string>('API_URL') ?? ''}/payments/momo/callback`;

    if (!partnerCode || !accessKey || !secretKey) {
      throw new BadRequestException('Missing MoMo configuration (Partner Code / Access Key / Secret Key)');
    }

    return { partnerCode, accessKey, secretKey, endpoint, returnUrl, notifyUrl };
  }
}
