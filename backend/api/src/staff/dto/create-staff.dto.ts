import { IsDateString, IsEmail, IsOptional, IsString, Length, MinLength } from 'class-validator';

export class CreateStaffDto {
  @IsOptional()
  idTypeStaff?: number;

  @IsString()
  @Length(2, 100)
  staffName!: string;

  @IsEmail()
  email!: string;

  @IsString()
  @MinLength(6)
  password!: string;

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
