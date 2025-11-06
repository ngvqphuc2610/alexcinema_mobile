import { Type } from 'class-transformer';
import { IsInt } from 'class-validator';

export class CreateGenreMovieDto {
  @Type(() => Number)
  @IsInt()
  genreId!: number;

  @Type(() => Number)
  @IsInt()
  movieId!: number;
}
