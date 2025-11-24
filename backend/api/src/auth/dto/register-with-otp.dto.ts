import { IsNotEmpty, IsString, Length } from 'class-validator';
import { RegisterDto } from './register.dto';

export class RegisterWithOtpDto extends RegisterDto {
  @IsNotEmpty({ message: 'Số điện thoại không được để trống' })
  @IsString()
  // provide an initializer so TypeScript doesn't warn about overwriting
  // the optional base property. An empty string is fine because
  // class-validator will enforce non-empty at runtime.
  override phoneNumber: string = '';

  @IsNotEmpty({ message: 'Mã OTP không được để trống' })
  @IsString()
  @Length(6, 6, { message: 'Mã OTP phải có 6 ký tự' })
  otp: string;
}
