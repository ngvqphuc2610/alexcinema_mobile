import { Controller } from '@nestjs/common';
import { TicketSeatConstraintService } from './ticket_seat_constraint.service';

@Controller('ticket-seat-constraint')
export class TicketSeatConstraintController {
  constructor(private readonly ticketSeatConstraintService: TicketSeatConstraintService) {}
}
