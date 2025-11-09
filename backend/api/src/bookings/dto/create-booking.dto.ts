import { Type } from 'class-transformer';
import { IsDateString, IsInt, IsNumber, IsOptional, IsString, MaxLength, Min } from 'class-validator';

export class CreateBookingDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  idUsers?: number;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  idMember?: number;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  idShowtime?: number;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  idStaff?: number;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  idPromotions?: number;

  @IsOptional()
  @IsDateString()
  bookingDate?: string;

  @Type(() => Number)
  @IsNumber()
  @Min(0)
  totalAmount!: number;

  @IsOptional()
  @IsString()
  paymentStatus?: string;

  @IsOptional()
  @IsString()
  bookingStatus?: string;

  @IsOptional()
  @IsString()
  @MaxLength(20)
  bookingCode?: string;
}
