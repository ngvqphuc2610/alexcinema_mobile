import { Controller } from '@nestjs/common';
import { SeatTypeService } from './seat_type.service';

@Controller('seat-type')
export class SeatTypeController {
  constructor(private readonly seatTypeService: SeatTypeService) {}
}
