import { IsEmail, IsOptional, IsString, Length, MinLength } from 'class-validator';

export class RegisterDto {
  @IsString()
  @Length(4, 50)
  username!: string;

  @IsEmail()
  email!: string;

  @IsString()
  @MinLength(6)
  password!: string;

  @IsString()
  @Length(2, 100)
  fullName!: string;

  @IsOptional()
  @IsString()
  @Length(0, 20)
  phoneNumber?: string;
}
