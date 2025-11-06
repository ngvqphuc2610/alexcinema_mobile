import { IsOptional, IsString, MaxLength } from 'class-validator';

export class CreateMembershipDto {
  @IsString()
  @MaxLength(50)
  code!: string;

  @IsString()
  @MaxLength(100)
  title!: string;

  @IsOptional()
  @IsString()
  @MaxLength(255)
  image?: string;

  @IsOptional()
  @IsString()
  @MaxLength(255)
  link?: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsString()
  benefits?: string;

  @IsOptional()
  @IsString()
  criteria?: string;

  @IsOptional()
  @IsString()
  status?: string;
}
