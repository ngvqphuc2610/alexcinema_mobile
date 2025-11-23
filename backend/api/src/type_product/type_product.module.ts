import { Module } from '@nestjs/common';
import { TypeProductService } from './type_product.service';
import { TypeProductController } from './type_product.controller';
import { PrismaService } from '../prisma/prisma.service';

@Module({
  controllers: [TypeProductController],
  providers: [TypeProductService, PrismaService],
  exports: [TypeProductService],
})
export class TypeProductModule {}
