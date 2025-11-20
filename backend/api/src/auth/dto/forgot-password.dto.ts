import { IsEmail, IsNotEmpty, IsString, Length } from 'class-validator';

export class ForgotPasswordDto {
  @IsString()
  @IsNotEmpty()
  @Length(3, 50)
  username!: string;

  @IsEmail()
  email!: string;
}
