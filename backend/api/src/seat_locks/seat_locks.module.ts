import { Module } from '@nestjs/common';
import { SeatLocksService } from './seat_locks.service';
import { SeatLocksController } from './seat_locks.controller';

@Module({
  controllers: [SeatLocksController],
  providers: [SeatLocksService],
  exports: [SeatLocksService],
})
export class SeatLocksModule {}
