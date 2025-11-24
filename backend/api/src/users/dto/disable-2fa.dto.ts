import { IsNotEmpty, IsString, Length } from 'class-validator';

export class Disable2faDto {
  @IsNotEmpty({ message: 'Mã xác thực không được để trống' })
  @IsString()
  @Length(6, 6, { message: 'Mã xác thực phải có 6 ký tự' })
  token: string;
}

