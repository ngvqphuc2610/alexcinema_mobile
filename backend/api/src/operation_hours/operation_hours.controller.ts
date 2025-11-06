import { Controller } from '@nestjs/common';
import { OperationHoursService } from './operation_hours.service';

@Controller('operation-hours')
export class OperationHoursController {
  constructor(private readonly operationHoursService: OperationHoursService) {}
}
