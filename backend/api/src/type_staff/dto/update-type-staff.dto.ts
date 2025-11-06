import { PartialType } from '@nestjs/mapped-types';
import { CreateTypeStaffDto } from './create-type-staff.dto';

export class UpdateTypeStaffDto extends PartialType(CreateTypeStaffDto) {}
