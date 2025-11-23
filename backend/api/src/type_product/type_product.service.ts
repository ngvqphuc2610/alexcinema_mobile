import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateTypeProductDto } from './dto/create-type_product.dto';
import { UpdateTypeProductDto } from './dto/update-type_product.dto';

@Injectable()
export class TypeProductService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    const items = await this.prisma.type_product.findMany({
      orderBy: { type_name: 'asc' },
    });
    return items.map((item) => this.toEntity(item));
  }

  async findOne(id: number) {
    const item = await this.prisma.type_product.findUnique({
      where: { id_typeproduct: id },
    });
    if (!item) {
      throw new NotFoundException('Type product not found');
    }
    return this.toEntity(item);
  }

  async create(dto: CreateTypeProductDto) {
    const created = await this.prisma.type_product.create({
      data: {
        type_name: dto.typeName.trim(),
        description: dto.description,
      },
    });
    return this.toEntity(created);
  }

  async update(id: number, dto: UpdateTypeProductDto) {
    await this.ensureExists(id);
    const updated = await this.prisma.type_product.update({
      where: { id_typeproduct: id },
      data: {
        type_name: dto.typeName?.trim(),
        description: dto.description,
      },
    });
    return this.toEntity(updated);
  }

  async remove(id: number) {
    await this.ensureExists(id);
    await this.prisma.type_product.delete({
      where: { id_typeproduct: id },
    });
    return { success: true };
  }

  private async ensureExists(id: number) {
    const exists = await this.prisma.type_product.findUnique({
      where: { id_typeproduct: id },
      select: { id_typeproduct: true },
    });
    if (!exists) {
      throw new NotFoundException('Type product not found');
    }
  }

  private toEntity(item: any) {
    return {
      id: item.id_typeproduct,
      name: item.type_name,
      description: item.description,
    };
  }
}
