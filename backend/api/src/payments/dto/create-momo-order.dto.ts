import { IsInt, IsNumber, IsOptional, IsString } from 'class-validator';

export class CreateMoMoOrderDto {
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
    orderInfo?: string;
}
