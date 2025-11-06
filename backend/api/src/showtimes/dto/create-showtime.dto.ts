import { Type } from 'class-transformer';
import {
  IsDateString,
  IsOptional,
  IsString,
  MaxLength,
  IsNumber,
  Min,
  IsInt,
} from 'class-validator';

export class CreateShowtimeDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  idMovie?: number;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  idScreen?: number;

  @IsDateString()
  showDate!: string;

  @IsString()
  @MaxLength(8)
  startTime!: string;

  @IsString()
  @MaxLength(8)
  endTime!: string;

  @IsOptional()
  @IsString()
  @MaxLength(10)
  format?: string;

  @IsOptional()
  @IsString()
  @MaxLength(50)
  language?: string;

  @IsOptional()
  @IsString()
  @MaxLength(50)
  subtitle?: string;

  @IsOptional()
  @IsString()
  status?: string;

  @Type(() => Number)
  @IsNumber()
  @Min(0)
  price!: number;
}
