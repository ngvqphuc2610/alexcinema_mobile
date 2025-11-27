import { Body, Controller, Get, HttpCode, HttpStatus, Param, Post, Query, Res } from '@nestjs/common';
import type { Response } from 'express';

import { CreateZaloPayOrderDto } from './dto/create-zalopay-order.dto';
import { ZaloPayCallbackDto } from './dto/zalopay-callback.dto';
import { CreateVNPayOrderDto } from './dto/create-vnpay-order.dto';
import { VNPayCallbackDto } from './dto/vnpay-callback.dto';
import { CreateMoMoOrderDto } from './dto/create-momo-order.dto';
import { MoMoCallbackDto } from './dto/momo-callback.dto';
import { PaymentsService } from './payments.service';

@Controller('payments')
export class PaymentsController {
  constructor(private readonly paymentsService: PaymentsService) { }

  @Get()
  getAllPayments(
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('status') status?: string,
    @Query('bookingCode') bookingCode?: string,
    @Query('transactionId') transactionId?: string,
    @Query('methodCode') methodCode?: string,
  ) {
    return this.paymentsService.getAllPayments({
      page: page ? parseInt(page, 10) : undefined,
      limit: limit ? parseInt(limit, 10) : undefined,
      status,
      bookingCode,
      transactionId,
      methodCode,
    });
  }

  @Post('zalopay/order')
  createZaloPayOrder(@Body() dto: CreateZaloPayOrderDto) {
    return this.paymentsService.createZaloPayOrder(dto);
  }

  @Post('zalopay/callback')
  @HttpCode(HttpStatus.OK)
  handleZaloPayCallback(@Body() dto: ZaloPayCallbackDto) {
    return this.paymentsService.handleZaloPayCallback(dto);
  }

  @Get('zalopay/return')
  handleZaloPayReturn(
    @Query('apptransid') appTransId: string,
    @Query('status') status: string,
    @Query('amount') amount: string,
    @Res() res: Response,
  ) {
    // Redirect to deep link with transaction info
    const deepLink = `alexcinema://payment-result?apptransid=${appTransId || ''}&status=${status || ''}&amount=${amount || ''}`;

    // Return HTML with meta refresh for mobile app deep link
    const html = `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <meta http-equiv="refresh" content="0;url=${deepLink}">
        <title>Redirecting...</title>
      </head>
      <body>
        <p>Redirecting to app...</p>
        <script>
          window.location.href = '${deepLink}';
          setTimeout(() => {
            document.body.innerHTML = '<p>Please return to the app manually.</p>';
          }, 2000);
        </script>
      </body>
      </html>
    `;

    res.setHeader('Content-Type', 'text/html');
    res.send(html);
  }

  @Post('vnpay/order')
  createVNPayOrder(@Body() dto: CreateVNPayOrderDto) {
    return this.paymentsService.createVNPayOrder(dto);
  }

  @Get('vnpay/return')
  handleVNPayReturn(@Query() query: VNPayCallbackDto, @Res() res: Response) {
    // Process callback synchronously
    this.paymentsService.handleVNPayCallback(query);

    // Redirect to deep link
    const deepLink = `alexcinema://payment-result?txnref=${query.vnp_TxnRef || ''}&status=${query.vnp_ResponseCode || ''}&amount=${query.vnp_Amount || ''}`;

    const html = `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <meta http-equiv="refresh" content="0;url=${deepLink}">
        <title>Redirecting...</title>
      </head>
      <body>
        <p>Redirecting to app...</p>
        <script>
          window.location.href = '${deepLink}';
          setTimeout(() => {
            document.body.innerHTML = '<p>Please return to the app manually.</p>';
          }, 2000);
        </script>
      </body>
      </html>
    `;

    res.setHeader('Content-Type', 'text/html');
    res.send(html);
  }

  @Post('momo/order')
  createMoMoOrder(@Body() dto: CreateMoMoOrderDto) {
    return this.paymentsService.createMoMoOrder(dto);
  }

  @Post('momo/callback')
  handleMoMoCallback(@Body() body: MoMoCallbackDto) {
    return this.paymentsService.handleMoMoCallback(body);
  }

  @Get('momo/return')
  handleMoMoReturn(@Query() query: MoMoCallbackDto, @Res() res: Response) {
    // Process callback synchronously
    this.paymentsService.handleMoMoCallback(query);

    // Redirect to deep link
    const deepLink = `alexcinema://payment-result?orderid=${query.orderId || ''}&resultcode=${query.resultCode || ''}&amount=${query.amount || ''}`;

    const html = `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <meta http-equiv="refresh" content="0;url=${deepLink}">
        <title>Redirecting...</title>
      </head>
      <body>
        <p>Redirecting to app...</p>
        <script>
          window.location.href = '${deepLink}';
          setTimeout(() => {
            document.body.innerHTML = '<p>Please return to the app manually.</p>';
          }, 2000);
        </script>
      </body>
      </html>
    `;

    res.setHeader('Content-Type', 'text/html');
    res.send(html);
  }

  @Get('status/:transactionId')
  getPaymentStatus(@Param('transactionId') transactionId: string) {
    return this.paymentsService.getPaymentStatus(transactionId);
  }
}
