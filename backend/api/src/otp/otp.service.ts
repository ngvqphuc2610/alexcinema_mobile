import { Injectable, BadRequestException, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../prisma/prisma.service';
import { OtpGeneratorService } from '../../services/otpGenerator';
import { EsmsService } from '../../services/esmsService';

interface OtpRecord {
  phoneNumber: string;
  otpHash: string;
  salt: string;
  expiresAt: Date;
  attempts: number;
  createdAt: Date;
}

@Injectable()
export class OtpService {
  private readonly logger = new Logger(OtpService.name);
  private readonly otpStore = new Map<string, OtpRecord>();
  private readonly otpLength: number;
  private readonly otpTtlSeconds: number;
  private readonly otpResendWindow: number;
  private readonly maxAttempts: number;
  private readonly androidSmsHash: string;

  constructor(
    private readonly configService: ConfigService,
    private readonly prisma: PrismaService,
    private readonly otpGeneratorService: OtpGeneratorService,
    private readonly esmsService: EsmsService,
  ) {
    this.otpLength = Number(this.configService.get('OTP_LENGTH', '6'));
    this.otpTtlSeconds = Number(this.configService.get('OTP_TTL_SECONDS', '300'));
    this.otpResendWindow = Number(this.configService.get('OTP_RESEND_WINDOW', '60'));
    this.maxAttempts = Number(this.configService.get('OTP_MAX_ATTEMPTS', '5'));
    this.androidSmsHash = this.configService.get('ANDROID_SMS_HASH', '');
  }

  async sendOtp(phoneNumber: string): Promise<{ message: string; expiresAt: Date }> {
    const normalizedPhone = this.normalizePhone(phoneNumber);

    // Check resend window
    const existing = this.otpStore.get(normalizedPhone);
    if (existing) {
      const now = new Date();
      const timeSinceCreated = (now.getTime() - existing.createdAt.getTime()) / 1000;
      if (timeSinceCreated < this.otpResendWindow) {
        const waitTime = Math.ceil(this.otpResendWindow - timeSinceCreated);
        throw new BadRequestException(
          `Vui lòng đợi ${waitTime} giây trước khi gửi lại mã OTP`,
        );
      }
    }

    // Generate OTP
    const otp = this.otpGeneratorService.generateNumericOtp(this.otpLength);
    const salt = this.generateSalt();
    const otpHash = this.otpGeneratorService.hashOtp(otp, salt);
    const expiresAt = new Date(Date.now() + this.otpTtlSeconds * 1000);

    // Store OTP
    this.otpStore.set(normalizedPhone, {
      phoneNumber: normalizedPhone,
      otpHash,
      salt,
      expiresAt,
      attempts: 0,
      createdAt: new Date(),
    });

    // Send SMS
    try {
      const ttlMinutes = Math.ceil(this.otpTtlSeconds / 60);
      await this.esmsService.sendOtpSms({
        phone: normalizedPhone,
        otp,
        ttlMinutes,
        appHash: this.androidSmsHash || undefined,
      });

      this.logger.log(`OTP sent to ${normalizedPhone}`);
    } catch (error) {
      this.logger.error(`Failed to send OTP to ${normalizedPhone}:`, error);
      this.otpStore.delete(normalizedPhone);
      throw new BadRequestException('Không thể gửi mã OTP. Vui lòng thử lại sau.');
    }

    // Clean up expired OTPs
    this.cleanupExpiredOtps();

    return {
      message: 'Mã OTP đã được gửi đến số điện thoại của bạn',
      expiresAt,
    };
  }

  async verifyOtp(phoneNumber: string, otp: string): Promise<boolean> {
    const normalizedPhone = this.normalizePhone(phoneNumber);
    const record = this.otpStore.get(normalizedPhone);

    if (!record) {
      throw new BadRequestException('Mã OTP không tồn tại hoặc đã hết hạn');
    }

    // Check expiration
    if (new Date() > record.expiresAt) {
      this.otpStore.delete(normalizedPhone);
      throw new BadRequestException('Mã OTP đã hết hạn');
    }

    // Check max attempts
    if (record.attempts >= this.maxAttempts) {
      this.otpStore.delete(normalizedPhone);
      throw new BadRequestException('Bạn đã nhập sai quá nhiều lần. Vui lòng gửi lại mã OTP');
    }

    // Verify OTP
    const isValid = this.otpGeneratorService.verifyOtp(otp, record.salt, record.otpHash);

    if (!isValid) {
      record.attempts++;
      this.otpStore.set(normalizedPhone, record);
      const remainingAttempts = this.maxAttempts - record.attempts;
      throw new BadRequestException(`Mã OTP không đúng. Còn ${remainingAttempts} lần thử`);
    }

    // OTP is valid, remove it
    this.otpStore.delete(normalizedPhone);
    this.logger.log(`OTP verified successfully for ${normalizedPhone}`);

    return true;
  }

  private normalizePhone(phone: string): string {
    let sanitized = phone.trim().replace(/[\s\-\.]/g, '');
    if (sanitized.startsWith('+')) {
      sanitized = sanitized.slice(1);
    }
    if (sanitized.startsWith('0')) {
      sanitized = `84${sanitized.slice(1)}`;
    }
    return sanitized;
  }

  private generateSalt(): string {
    return Math.random().toString(36).substring(2, 15);
  }

  private cleanupExpiredOtps(): void {
    const now = new Date();
    for (const [phone, record] of this.otpStore.entries()) {
      if (now > record.expiresAt) {
        this.otpStore.delete(phone);
      }
    }
  }
}

