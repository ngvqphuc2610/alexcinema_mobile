import {
  IsDateString,
  IsEnum,
  IsInt,
  IsOptional,
  IsPositive,
  IsString,
  MaxLength,
} from 'class-validator';
import { MovieStatus } from '@prisma/client';

export class CreateMovieDto {
  @IsString()
  @MaxLength(255)
  title!: string;

  @IsOptional()
  @IsString()
  @MaxLength(255)
  originalTitle?: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  director?: string;

  @IsOptional()
  @IsString()
  actors?: string;

  @IsInt()
  @IsPositive()
  duration!: number;

  @IsDateString()
  releaseDate!: string;

  @IsOptional()
  @IsDateString()
  endDate?: string;

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
  @MaxLength(50)
  country?: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsString()
  @MaxLength(255)
  posterImage?: string;

  @IsOptional()
  @IsString()
  @MaxLength(255)
  bannerImage?: string;

  @IsOptional()
  @IsString()
  @MaxLength(255)
  trailerUrl?: string;

  @IsOptional()
  @IsString()
  @MaxLength(10)
  ageRestriction?: string;

  @IsOptional()
  @IsEnum(MovieStatus)
  status?: MovieStatus;
}
