import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { Prisma, payment_methods } from '@prisma/client';

import { PrismaService } from '../prisma/prisma.service';
import { CreatePaymentMethodDto } from './dto/create-payment_method.dto';
import { UpdatePaymentMethodDto } from './dto/update-payment_method.dto';

export interface PaymentMethodQueryOptions {
  includeInactive?: boolean;
}

@Injectable()
export class PaymentMethodsService {
  constructor(private readonly prisma: PrismaService) { }

  async findAll(options: PaymentMethodQueryOptions = {}) {
    const methods = await this.prisma.payment_methods.findMany({
      where: options.includeInactive ? undefined : { is_active: true },
      orderBy: { display_order: 'asc' },
    });
    return methods.map((item) => this.toEntity(item));
  }

  async findOne(id: number) {
    const method = await this.prisma.payment_methods.findUnique({
      where: { id_payment_method: id },
    });
    if (!method) {
      throw new NotFoundException('Payment method not found');
    }
    return this.toEntity(method);
  }

  async create(dto: CreatePaymentMethodDto) {
    const code = this.normalizeCode(dto.methodCode);
    await this.ensureUniqueCode(code);

    const created = await this.prisma.payment_methods.create({
      data: this.toCreateInput(dto, code),
    });
    return this.toEntity(created);
  }

  async update(id: number, dto: UpdatePaymentMethodDto) {
    await this.ensureExists(id);
    const code = dto.methodCode ? this.normalizeCode(dto.methodCode) : undefined;
    if (code) {
      await this.ensureUniqueCode(code, id);
    }

    const updated = await this.prisma.payment_methods.update({
      where: { id_payment_method: id },
      data: this.toUpdateInput(dto, code),
    });
    return this.toEntity(updated);
  }

  async remove(id: number) {
    await this.ensureExists(id);
    await this.prisma.payment_methods.delete({
      where: { id_payment_method: id },
    });
    return { success: true };
  }

  async ensureZaloPayMethod() {
    return this.prisma.payment_methods.upsert({
      where: { method_code: 'ZALOPAY' },
      update: {
        method_name: 'ZaloPay',
        description: 'Thanh toan qua ZaloPay',
        is_active: true,
      },
      create: {
        method_code: 'ZALOPAY',
        method_name: 'ZaloPay',
        description: 'Thanh toan qua ZaloPay',
        is_active: true,
        display_order: 1,
      },
    });
  }

  async ensureVNPayMethod() {
    return this.prisma.payment_methods.upsert({
      where: { method_code: 'VNPAY' },
      update: {
        method_name: 'VNPay',
        description: 'Thanh toan qua VNPay',
        is_active: true,
      },
      create: {
        method_code: 'VNPAY',
        method_name: 'VNPay',
        description: 'Thanh toan qua VNPay',
        is_active: true,
        display_order: 2,
      },
    });
  }

  async ensureMoMoMethod() {
    return this.prisma.payment_methods.upsert({
      where: { method_code: 'MOMO' },
      update: {
        method_name: 'MoMo',
        description: 'Thanh toan qua MoMo',
        is_active: true,
      },
      create: {
        method_code: 'MOMO',
        method_name: 'MoMo',
        description: 'Thanh toan nhanh chong qua momo',
        is_active: true,
        display_order: 3,
      },
    });
  }

  private toCreateInput(
    dto: CreatePaymentMethodDto,
    code: string,
  ): Prisma.payment_methodsCreateInput {
    return {
      method_code: code,
      method_name: dto.methodName.trim(),
      description: dto.description?.trim(),
      icon_url: dto.iconUrl?.trim(),
      is_active: dto.isActive ?? true,
      processing_fee: dto.processingFee ?? undefined,
      min_amount: dto.minAmount ?? undefined,
      max_amount: dto.maxAmount ?? undefined,
      display_order: dto.displayOrder ?? undefined,
    };
  }

  private toUpdateInput(
    dto: UpdatePaymentMethodDto,
    code?: string,
  ): Prisma.payment_methodsUpdateInput {
    return {
      method_code: code,
      method_name: dto.methodName?.trim(),
      description: dto.description?.trim(),
      icon_url: dto.iconUrl?.trim(),
      is_active: dto.isActive,
      processing_fee: dto.processingFee ?? undefined,
      min_amount: dto.minAmount ?? undefined,
      max_amount: dto.maxAmount ?? undefined,
      display_order: dto.displayOrder ?? undefined,
    };
  }

  private toEntity(item: payment_methods) {
    return {
      id: item.id_payment_method,
      code: item.method_code,
      name: item.method_name,
      description: item.description,
      iconUrl: item.icon_url,
      isActive: Boolean(item.is_active),
      processingFee: this.decimalToNumber(item.processing_fee),
      minAmount: this.decimalToNumber(item.min_amount),
      maxAmount: this.decimalToNumber(item.max_amount),
      displayOrder: item.display_order ?? 0,
      createdAt: item.created_at,
      updatedAt: item.updated_at,
    };
  }

  private decimalToNumber(value?: Prisma.Decimal | null) {
    return value === null || value === undefined ? null : Number(value);
  }

  private normalizeCode(code: string) {
    return code.trim().toUpperCase();
  }

  private async ensureUniqueCode(code: string, ignoreId?: number) {
    const existing = await this.prisma.payment_methods.findUnique({
      where: { method_code: code },
    });
    if (existing && existing.id_payment_method !== ignoreId) {
      throw new ConflictException('Method code already exists');
    }
  }

  private async ensureExists(id: number) {
    const method = await this.prisma.payment_methods.findUnique({
      where: { id_payment_method: id },
    });
    if (!method) {
      throw new NotFoundException('Payment method not found');
    }
    return method;
  }
}
