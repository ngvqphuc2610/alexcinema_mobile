import { Type } from 'class-transformer';
import {
  IsInt,
  IsOptional,
  IsString,
  Length,
  Min,
} from 'class-validator';

export class CreateSeatDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  idScreen?: number;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  idSeatType?: number;

  @IsString()
  @Length(1, 2)
  seatRow!: string;

  @Type(() => Number)
  @IsInt()
  @Min(1)
  seatNumber!: number;

  @IsOptional()
  @IsString()
  status?: string;
}
