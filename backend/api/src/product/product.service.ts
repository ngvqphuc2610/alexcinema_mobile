import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class ProductService {
  constructor(private readonly prisma: PrismaService) {}

  async findGroupedProducts() {
    const categories = await this.prisma.type_product.findMany({
      orderBy: { type_name: 'asc' },
      include: {
        products: {
          orderBy: { product_name: 'asc' },
        },
      },
    });

    return categories.map((category) => ({
      id: category.id_typeproduct,
      name: category.type_name,
      description: category.description,
      products: category.products.map((product) => ({
        id: product.id_product,
        typeId: product.id_typeproduct,
        name: product.product_name,
        description: product.description,
        price: product.price,
        image: product.image,
        status: product.status,
        quantity: product.quantity,
      })),
    }));
  }
}
