import {
  Body,
  Controller,
  Get,
  Post,
  Request,
  UseGuards,
} from '@nestjs/common';
import { AuthService } from './auth.service';
import { RegisterDto } from './dto/register.dto';
import { RegisterWithOtpDto } from './dto/register-with-otp.dto';
import { LoginDto } from './dto/login.dto';
import { Verify2faDto } from './dto/verify-2fa.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { ForgotPasswordDto } from './dto/forgot-password.dto';
import { UserEntity } from '../users/users.service';
import { OtpService } from '../otp/otp.service';

@Controller('auth')
export class AuthController {
  constructor(
    private readonly authService: AuthService,
    private readonly otpService: OtpService,
  ) { }

  @Post('register')
  register(@Body() dto: RegisterDto) {
    return this.authService.register(dto);
  }

  @Post('register-with-otp')
  async registerWithOtp(@Body() dto: RegisterWithOtpDto) {
    // Verify OTP first
    await this.otpService.verifyOtp(dto.phoneNumber, dto.otp);

    // If OTP is valid, proceed with registration
    return this.authService.register(dto);
  }

  @Post('login')
  login(@Body() dto: LoginDto) {
    return this.authService.login(dto);
  }

  @Post('verify-2fa')
  verify2FA(@Body() dto: Verify2faDto) {
    return this.authService.verify2FA(dto.usernameOrEmail, dto.token, dto.sessionToken);
  }

  @Post('forgot-password')
  forgotPassword(@Body() dto: ForgotPasswordDto) {
    return this.authService.requestPasswordReset(dto);
  }

  @UseGuards(JwtAuthGuard)
  @Get('me')
  me(@Request() req: { user: UserEntity }) {
    return req.user;
  }
}
