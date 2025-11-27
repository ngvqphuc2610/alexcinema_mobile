import { IsInt, IsNumber, IsOptional, IsString } from 'class-validator';

export class CreateVNPayOrderDto {
    @IsInt()
    bookingId: number;

    @IsOptional()
    @IsNumber()
    amount?: number;

    @IsOptional()
    @IsString()
    description?: string;

    @IsOptional()
    @IsString()
    bankCode?: string; // Optional: NCB, VISA, MASTERCARD, etc.

    @IsOptional()
    @IsString()
    locale?: string; // vn or en
}
