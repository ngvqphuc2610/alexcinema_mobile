import { IsInt, IsOptional, IsString, MaxLength, Min } from 'class-validator';

export class CreateTypeStaffDto {
  @IsString()
  @MaxLength(50)
  typeName!: string;

  @IsOptional()
  @IsString()
  @MaxLength(255)
  description?: string;

  @IsOptional()
  @IsInt()
  @Min(1)
  permissionLevel?: number;
}
