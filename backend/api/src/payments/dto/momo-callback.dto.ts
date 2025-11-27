import { IsOptional, IsString } from 'class-validator';

export class MoMoCallbackDto {
    @IsString()
    partnerCode: string;

    @IsString()
    orderId: string;

    @IsString()
    requestId: string;

    @IsString()
    amount: string;

    @IsString()
    orderInfo: string;

    @IsString()
    orderType: string;

    @IsString()
    transId: string;

    @IsString()
    resultCode: string;

    @IsString()
    message: string;

    @IsString()
    payType: string;

    @IsString()
    responseTime: string;

    @IsOptional()
    @IsString()
    extraData?: string;

    @IsString()
    signature: string;
}
