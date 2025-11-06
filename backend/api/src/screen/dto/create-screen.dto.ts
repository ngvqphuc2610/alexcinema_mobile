import { Type } from 'class-transformer';
import {
  IsInt,
  IsOptional,
  IsString,
  Length,
  Min,
} from 'class-validator';

export class CreateScreenDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  idCinema?: number;

  @IsString()
  @Length(1, 50)
  screenName!: string;

  @Type(() => Number)
  @IsInt()
  @Min(1)
  capacity!: number;

  @IsOptional()
  @IsString()
  status?: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  idScreenType?: number;
}
