import { Module } from '@nestjs/common';
import { TypeProductService } from './type_product.service';
import { TypeProductController } from './type_product.controller';

@Module({
  controllers: [TypeProductController],
  providers: [TypeProductService],
  exports: [TypeProductService],
})
export class TypeProductModule {}
