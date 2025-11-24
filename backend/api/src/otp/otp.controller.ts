import { Body, Controller, Post } from '@nestjs/common';
import { OtpService } from './otp.service';
import { SendOtpDto } from './dto/send-otp.dto';
import { VerifyOtpDto } from './dto/verify-otp.dto';

@Controller('otp')
export class OtpController {
  constructor(private readonly otpService: OtpService) {}

  @Post('send')
  async sendOtp(@Body() dto: SendOtpDto) {
    return this.otpService.sendOtp(dto.phoneNumber);
  }

  @Post('verify')
  async verifyOtp(@Body() dto: VerifyOtpDto) {
    const isValid = await this.otpService.verifyOtp(dto.phoneNumber, dto.otp);
    return {
      success: isValid,
      message: 'Xác thực OTP thành công',
    };
  }
}

