import { IsString, MinLength } from 'class-validator';

export class ChangeStaffPasswordDto {
  @IsString()
  @MinLength(6)
  newPassword!: string;
}
