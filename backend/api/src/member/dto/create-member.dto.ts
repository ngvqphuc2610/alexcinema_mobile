import { IsDateString, IsInt, IsOptional, IsString } from 'class-validator';

export class CreateMemberDto {
  @IsInt()
  idUser!: number;

  @IsInt()
  idTypeMember!: number;

  @IsOptional()
  @IsInt()
  idMembership?: number;

  @IsOptional()
  @IsInt()
  points?: number;

  @IsOptional()
  @IsDateString()
  joinDate?: string;

  @IsOptional()
  @IsString()
  status?: string;
}
