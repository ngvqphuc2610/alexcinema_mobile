import { Module } from '@nestjs/common';
import { TicketSeatConstraintService } from './ticket_seat_constraint.service';
import { TicketSeatConstraintController } from './ticket_seat_constraint.controller';

@Module({
  controllers: [TicketSeatConstraintController],
  providers: [TicketSeatConstraintService],
  exports: [TicketSeatConstraintService],
})
export class TicketSeatConstraintModule {}
