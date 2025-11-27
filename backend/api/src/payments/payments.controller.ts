import { Body, Controller, Get, HttpCode, HttpStatus, Param, Post } from '@nestjs/common';

import { CreateZaloPayOrderDto } from './dto/create-zalopay-order.dto';
import { ZaloPayCallbackDto } from './dto/zalopay-callback.dto';
import { PaymentsService } from './payments.service';

@Controller('payments')
export class PaymentsController {
  constructor(private readonly paymentsService: PaymentsService) {}

  @Post('zalopay/order')
  createZaloPayOrder(@Body() dto: CreateZaloPayOrderDto) {
    return this.paymentsService.createZaloPayOrder(dto);
  }

  @Post('zalopay/callback')
  @HttpCode(HttpStatus.OK)
  handleZaloPayCallback(@Body() dto: ZaloPayCallbackDto) {
    return this.paymentsService.handleZaloPayCallback(dto);
  }

  @Get('status/:transactionId')
  getPaymentStatus(@Param('transactionId') transactionId: string) {
    return this.paymentsService.getPaymentStatus(transactionId);
  }
}
