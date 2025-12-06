import { Module } from '@nestjs/common';
import { SeatLocksService } from './seat_locks.service';
import { SeatLocksController } from './seat_locks.controller';
import { SeatLocksGateway } from './seat-locks.gateway';
import { PrismaModule } from '../prisma/prisma.module';
import { ScheduleModule } from '@nestjs/schedule';

@Module({
  imports: [
    PrismaModule,
    ScheduleModule.forRoot(), // Enable cron jobs
  ],
  controllers: [SeatLocksController],
  providers: [SeatLocksService, SeatLocksGateway],
  exports: [SeatLocksService],
})
export class SeatLocksModule { }
