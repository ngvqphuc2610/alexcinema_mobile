import { Controller } from '@nestjs/common';
import { TicketTypeService } from './ticket_type.service';

@Controller('ticket-type')
export class TicketTypeController {
  constructor(private readonly ticketTypeService: TicketTypeService) {}
}
