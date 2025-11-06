import { IsOptional, IsString, MaxLength } from 'class-validator';

export class CreateGenreDto {
  @IsString()
  @MaxLength(50)
  genreName!: string;

  @IsOptional()
  @IsString()
  @MaxLength(255)
  description?: string;
}
