import { Module } from '@nestjs/common';
import { DetailBookingService } from './detail_booking.service';
import { DetailBookingController } from './detail_booking.controller';

@Module({
  controllers: [DetailBookingController],
  providers: [DetailBookingService],
  exports: [DetailBookingService],
})
export class DetailBookingModule {}
