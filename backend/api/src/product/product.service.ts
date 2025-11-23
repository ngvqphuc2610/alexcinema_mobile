import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';

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

  async findAllFlat() {
    const products = await this.prisma.product.findMany({
      orderBy: { product_name: 'asc' },
    });
    return products.map((product) => this.toEntity(product));
  }

  async findOne(id: number) {
    const product = await this.prisma.product.findUnique({
      where: { id_product: id },
    });
    if (!product) {
      throw new NotFoundException('Product not found');
    }
    return this.toEntity(product);
  }

  async create(dto: CreateProductDto) {
    const created = await this.prisma.product.create({
      data: {
        id_typeproduct: dto.idTypeProduct,
        product_name: dto.name.trim(),
        description: dto.description,
        price: dto.price,
        image: dto.image,
        status: dto.status,
        quantity: dto.quantity,
      },
    });
    return this.toEntity(created);
  }

  async update(id: number, dto: UpdateProductDto) {
    await this.ensureExists(id);
    const updated = await this.prisma.product.update({
      where: { id_product: id },
      data: {
        id_typeproduct: dto.idTypeProduct ?? undefined,
        product_name: dto.name?.trim(),
        description: dto.description,
        price: dto.price,
        image: dto.image,
        status: dto.status,
        quantity: dto.quantity,
      },
    });
    return this.toEntity(updated);
  }

  async remove(id: number) {
    await this.ensureExists(id);
    await this.prisma.product.delete({ where: { id_product: id } });
    return { success: true };
  }

  private async ensureExists(id: number) {
    const exists = await this.prisma.product.findUnique({
      where: { id_product: id },
      select: { id_product: true },
    });
    if (!exists) {
      throw new NotFoundException('Product not found');
    }
  }

  private toEntity(product: any) {
    return {
      id: product.id_product,
      typeId: product.id_typeproduct,
      name: product.product_name,
      description: product.description,
      price: product.price,
      image: product.image,
      status: product.status,
      quantity: product.quantity,
    };
  }
}
