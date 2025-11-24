import { IsNotEmpty, IsString, Length, Matches } from 'class-validator';

export class Verify2faDto {
  @IsNotEmpty({ message: 'Tên đăng nhập hoặc email không được để trống' })
  @IsString()
  usernameOrEmail: string;

  @IsNotEmpty({ message: 'Mã 2FA/backup không được để trống' })
  @IsString()
  @Length(6, 32, { message: 'Mã 2FA/backup phải có ít nhất 6 ký tự' })
  @Matches(/^[0-9A-Z-]+$/i, { message: 'Mã chỉ chấp nhận chữ, số, dấu gạch' })
  token: string;

  @IsNotEmpty({ message: 'Session token không được để trống' })
  @IsString()
  sessionToken: string;
}
