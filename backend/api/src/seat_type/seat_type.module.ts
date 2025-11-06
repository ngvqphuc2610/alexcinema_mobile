import { Module } from '@nestjs/common';
import { SeatTypeService } from './seat_type.service';
import { SeatTypeController } from './seat_type.controller';

@Module({
  controllers: [SeatTypeController],
  providers: [SeatTypeService],
  exports: [SeatTypeService],
})
export class SeatTypeModule {}
