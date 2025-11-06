import { Controller } from '@nestjs/common';
import { TypeProductService } from './type_product.service';

@Controller('type-product')
export class TypeProductController {
  constructor(private readonly typeProductService: TypeProductService) {}
}
