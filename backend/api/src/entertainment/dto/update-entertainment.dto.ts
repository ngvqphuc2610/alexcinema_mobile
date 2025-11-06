import { PartialType } from '@nestjs/mapped-types';
import { CreateEntertainmentDto } from './create-entertainment.dto';

export class UpdateEntertainmentDto extends PartialType(CreateEntertainmentDto) {}
