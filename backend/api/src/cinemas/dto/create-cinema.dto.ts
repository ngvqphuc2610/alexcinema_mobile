import { IsEmail, IsOptional, IsString, MaxLength } from 'class-validator';

export class CreateCinemaDto {
  @IsString()
  @MaxLength(100)
  cinemaName!: string;

  @IsString()
  @MaxLength(255)
  address!: string;

  @IsString()
  @MaxLength(50)
  city!: string;

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
