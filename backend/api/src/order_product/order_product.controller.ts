import { Controller } from '@nestjs/common';
import { OrderProductService } from './order_product.service';

@Controller('order-product')
export class OrderProductController {
  constructor(private readonly orderProductService: OrderProductService) {}
}
