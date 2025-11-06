import { Controller } from '@nestjs/common';
import { SeatLocksService } from './seat_locks.service';

@Controller('seat-locks')
export class SeatLocksController {
  constructor(private readonly seatLocksService: SeatLocksService) {}
}
