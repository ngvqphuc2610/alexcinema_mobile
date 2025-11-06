import { IsEmail, IsInt, IsOptional, IsString, Length } from 'class-validator';

export class CreateContactDto {
  @IsString()
  @Length(2, 100)
  name!: string;

  @IsEmail()
  email!: string;

  @IsString()
  @Length(2, 255)
  subject!: string;

  @IsString()
  message!: string;

  @IsOptional()
  @IsInt()
  idStaff?: number;

  @IsOptional()
  @IsString()
  status?: string;

  @IsOptional()
  @IsString()
  reply?: string;
}
