import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { OtpController } from './otp.controller';
import { OtpService } from './otp.service';
import { PrismaModule } from '../prisma/prisma.module';
import { OtpGeneratorService } from '../../services/otpGenerator';
import { EsmsService } from '../../services/esmsService';

@Module({
  imports: [ConfigModule, PrismaModule],
  controllers: [OtpController],
  providers: [OtpService, OtpGeneratorService, EsmsService],
  exports: [OtpService],
})
export class OtpModule {}

