import { IsNotEmpty, IsString } from 'class-validator';

export class ZaloPayCallbackDto {
  @IsString()
  @IsNotEmpty()
  data!: string;

  @IsString()
  @IsNotEmpty()
  mac!: string;
}
