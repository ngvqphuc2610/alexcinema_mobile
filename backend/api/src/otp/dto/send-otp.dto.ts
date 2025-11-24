import { IsNotEmpty, IsPhoneNumber, IsString } from 'class-validator';

export class SendOtpDto {
  @IsNotEmpty({ message: 'Số điện thoại không được để trống' })
  @IsString()
  phoneNumber: string;
}

