import { PartialType } from '@nestjs/mapped-types';
import { IsInt, IsNumber, IsOptional, IsPositive, IsString, MaxLength } from 'class-validator';
import { CreateProductDto } from './create-product.dto';

export class UpdateProductDto extends PartialType(CreateProductDto) {
  @IsOptional()
  @IsInt()
  override idTypeProduct?: number;

  @IsOptional()
  @IsString()
  @MaxLength(255)
  override name?: string;

  @IsOptional()
  @IsString()
  override description?: string;

  @IsOptional()
  @IsNumber()
  @IsPositive()
  override price?: number;

  @IsOptional()
  @IsString()
  @MaxLength(255)
  override image?: string;

  @IsOptional()
  @IsString()
  @MaxLength(50)
  override status?: string;

  @IsOptional()
  @IsInt()
  override quantity?: number;
}
