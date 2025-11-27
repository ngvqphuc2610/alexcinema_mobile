import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { Prisma, promotions } from '@prisma/client';
import { EventEmitter2 } from '@nestjs/event-emitter';
import { PrismaService } from '../prisma/prisma.service';
import { CreatePromotionDto } from './dto/create-promotion.dto';
import { UpdatePromotionDto } from './dto/update-promotion.dto';

export interface PromotionQueryParams {
  page?: number;
  limit?: number;
  status?: string;
  search?: string;
}

@Injectable()
export class PromotionsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly eventEmitter: EventEmitter2,
  ) { }

  async create(dto: CreatePromotionDto): Promise<promotions> {
    const existing = await this.prisma.promotions.findUnique({
      where: { promotion_code: dto.promotionCode.trim() },
    });
    if (existing) {
      throw new ConflictException('Promotion code already exists');
    }

    const data = this.toCreateInput(dto);
    const promotion = await this.prisma.promotions.create({ data });

    // Emit event for RAG re-indexing
    this.eventEmitter.emit('promotion.created', { id: promotion.id_promotions });

    return promotion;
  }

  async findAll(params: PromotionQueryParams = {}) {
    const page = Math.max(1, params.page ?? 1);
    const limit = Math.min(100, Math.max(1, params.limit ?? 20));

    const where: Prisma.promotionsWhereInput =
      params.search && params.search.trim().length > 0
        ? {
          OR: [
            { promotion_code: { contains: params.search } },
            { title: { contains: params.search } },
          ],
          status: params.status?.trim(),
        }
        : {
          status: params.status?.trim(),
        };

    const [items, total] = await this.prisma.$transaction([
      this.prisma.promotions.findMany({
        where,
        skip: (page - 1) * limit,
        take: limit,
        orderBy: { start_date: 'desc' },
      }),
      this.prisma.promotions.count({ where }),
    ]);

    return {
      items,
      meta: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async findOne(id: number) {
    const record = await this.prisma.promotions.findUnique({
      where: { id_promotions: id },
    });
    if (!record) {
      throw new NotFoundException('Promotion not found');
    }
    return record;
  }

  async update(id: number, dto: UpdatePromotionDto) {
    await this.ensureExists(id);
    if (dto.promotionCode) {
      const existing = await this.prisma.promotions.findUnique({
        where: { promotion_code: dto.promotionCode.trim() },
      });
      if (existing && existing.id_promotions !== id) {
        throw new ConflictException('Promotion code already exists');
      }
    }

    const data = this.toUpdateInput(dto);
    const promotion = await this.prisma.promotions.update({
      where: { id_promotions: id },
      data,
    });

    // Emit event for RAG re-indexing
    this.eventEmitter.emit('promotion.updated', { id: promotion.id_promotions });

    return promotion;
  }

  async remove(id: number) {
    await this.ensureExists(id);
    const promotion = await this.prisma.promotions.delete({ where: { id_promotions: id } });

    // Emit event for RAG re-indexing
    this.eventEmitter.emit('promotion.deleted', { id });

    return promotion;
  }

  private async ensureExists(id: number) {
    const exists = await this.prisma.promotions.findUnique({
      where: { id_promotions: id },
      select: { id_promotions: true },
    });
    if (!exists) {
      throw new NotFoundException('Promotion not found');
    }
  }

  private toCreateInput(dto: CreatePromotionDto): Prisma.promotionsCreateInput {
    return {
      promotion_code: dto.promotionCode.trim(),
      title: dto.title.trim(),
      description: dto.description,
      image: dto.image?.trim(),
      discount_percent: dto.discountPercent ?? undefined,
      discount_amount: dto.discountAmount ?? undefined,
      start_date: new Date(dto.startDate),
      end_date: dto.endDate ? new Date(dto.endDate) : undefined,
      min_purchase: dto.minPurchase ?? undefined,
      max_discount: dto.maxDiscount ?? undefined,
      usage_limit: dto.usageLimit ?? undefined,
      status: dto.status?.trim(),
    };
  }

  private toUpdateInput(dto: UpdatePromotionDto): Prisma.promotionsUpdateInput {
    return {
      promotion_code: dto.promotionCode ? dto.promotionCode.trim() : undefined,
      title: dto.title ? dto.title.trim() : undefined,
      description: dto.description,
      image: dto.image?.trim(),
      discount_percent: dto.discountPercent ?? undefined,
      discount_amount: dto.discountAmount ?? undefined,
      start_date: dto.startDate ? new Date(dto.startDate) : undefined,
      end_date: dto.endDate ? new Date(dto.endDate) : undefined,
      min_purchase: dto.minPurchase ?? undefined,
      max_discount: dto.maxDiscount ?? undefined,
      usage_limit: dto.usageLimit ?? undefined,
      status: dto.status ? dto.status.trim() : undefined,
    };
  }
}
