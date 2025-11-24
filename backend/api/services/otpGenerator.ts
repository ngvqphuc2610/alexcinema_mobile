import { Injectable } from '@nestjs/common';
import * as crypto from 'crypto';

@Injectable()
export class OtpGeneratorService {
  private readonly DEFAULT_LENGTH = 6;

  generateNumericOtp(length: number = this.DEFAULT_LENGTH): string {
    if (length < 4 || length > 10) {
      throw new Error('Độ dài OTP phải từ 4 đến 10 ký tự');
    }

    const max = 10 ** length;
    const otp = crypto.randomInt(0, max).toString().padStart(length, '0');
    return otp;
  }

  hashOtp(otp: string, salt: string): string {
    if (!otp || !salt) {
      throw new Error('Thiếu OTP hoặc salt để hash');
    }

    return crypto.createHash('sha256').update(`${otp}:${salt}`).digest('hex');
  }

  verifyOtp(otp: string, salt: string, hashed: string): boolean {
    if (!hashed) return false;
    try {
      const candidate = this.hashOtp(otp, salt);
      const bufCandidate = Buffer.from(candidate, 'hex');
      const bufStored = Buffer.from(hashed, 'hex');
      if (bufCandidate.length !== bufStored.length) {
        return false;
      }
      return crypto.timingSafeEqual(bufCandidate, bufStored);
    } catch (error) {
      return false;
    }
  }
}