import { IsDateString, IsEmail, IsOptional, IsString, Length } from 'class-validator';

export class UpdateStaffDto {
  @IsOptional()
  idTypeStaff?: number;

  @IsOptional()
  @IsString()
  @Length(2, 100)
  staffName?: string;

  @IsOptional()
  @IsEmail()
  email?: string;

  @IsOptional()
  @IsString()
  @Length(0, 20)
  phoneNumber?: string;

  @IsOptional()
  @IsString()
  address?: string;

  @IsOptional()
  @IsDateString()
  dateOfBirth?: string;

  @IsOptional()
  @IsDateString()
  hireDate?: string;

  @IsOptional()
  @IsString()
  status?: string;

  @IsOptional()
  @IsString()
  profileImage?: string;
}
