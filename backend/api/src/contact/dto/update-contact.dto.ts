import { IsDateString, IsInt, IsOptional, IsString, Length } from 'class-validator';

export class UpdateContactDto {
  @IsOptional()
  @IsInt()
  idStaff?: number;

  @IsOptional()
  @IsString()
  @Length(2, 255)
  subject?: string;

  @IsOptional()
  @IsString()
  message?: string;

  @IsOptional()
  @IsString()
  status?: string;

  @IsOptional()
  @IsString()
  reply?: string;

  @IsOptional()
  @IsDateString()
  replyDate?: string;
}
