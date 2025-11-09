import { IsEmail, IsOptional, IsString, MaxLength } from 'class-validator';

export class UpdateCinemaDto {
  @IsOptional()
  @IsString()
  @MaxLength(100)
  cinemaName?: string;

  @IsOptional()
  @IsString()
  @MaxLength(255)
  address?: string;

  @IsOptional()
  @IsString()
  @MaxLength(50)
  city?: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsString()
  @MaxLength(255)
  image?: string;

  @IsOptional()
  @IsString()
  @MaxLength(20)
  contactNumber?: string;

  @IsOptional()
  @IsEmail()
  @MaxLength(100)
  email?: string;

  @IsOptional()
  @IsString()
  status?: string;
}
