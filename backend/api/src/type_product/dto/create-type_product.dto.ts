import { IsOptional, IsString, MaxLength } from 'class-validator';

export class CreateTypeProductDto {
  @IsString()
  @MaxLength(100)
  typeName!: string;

  @IsOptional()
  @IsString()
  description?: string;
}
