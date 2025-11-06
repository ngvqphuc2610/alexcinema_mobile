import { Controller } from '@nestjs/common';
import { DetailBookingService } from './detail_booking.service';

@Controller('detail-booking')
export class DetailBookingController {
  constructor(private readonly detailBookingService: DetailBookingService) {}
}
