import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { Prisma, membership } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CreateMembershipDto } from './dto/create-membership.dto';
import { UpdateMembershipDto } from './dto/update-membership.dto';

export interface MembershipQueryParams {
  page?: number;
  limit?: number;
  status?: string;
  search?: string;
}

@Injectable()
export class MembershipService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: CreateMembershipDto): Promise<membership> {
    const existing = await this.prisma.membership.findUnique({
      where: { code: dto.code.trim() },
    });
    if (existing) {
      throw new ConflictException('Membership code already exists');
    }

    const data = this.toCreateInput(dto);
    return this.prisma.membership.create({ data });
  }

  async findAll(params: MembershipQueryParams = {}) {
    const page = Math.max(1, params.page ?? 1);
    const limit = Math.min(100, Math.max(1, params.limit ?? 20));

    const where: Prisma.membershipWhereInput =
      params.search && params.search.trim().length > 0
        ? {
            OR: [
              { code: { contains: params.search } },
              { title: { contains: params.search } },
            ],
            status: params.status?.trim() as any,
          }
        : {
            status: params.status?.trim() as any,
          };

    const [items, total] = await this.prisma.$transaction([
      this.prisma.membership.findMany({
        where,
        skip: (page - 1) * limit,
        take: limit,
        orderBy: { title: 'asc' },
      }),
      this.prisma.membership.count({ where }),
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
    const record = await this.prisma.membership.findUnique({
      where: { id_membership: id },
    });
    if (!record) {
      throw new NotFoundException('Membership not found');
    }
    return record;
  }

  async update(id: number, dto: UpdateMembershipDto) {
    await this.ensureExists(id);
    if (dto.code) {
      const existing = await this.prisma.membership.findUnique({
        where: { code: dto.code.trim() },
      });
      if (existing && existing.id_membership !== id) {
        throw new ConflictException('Membership code already exists');
      }
    }

    const data = this.toUpdateInput(dto);
    return this.prisma.membership.update({
      where: { id_membership: id },
      data,
    });
  }

  async remove(id: number) {
    await this.ensureExists(id);
    return this.prisma.membership.delete({ where: { id_membership: id } });
  }

  private async ensureExists(id: number) {
    const exists = await this.prisma.membership.findUnique({
      where: { id_membership: id },
      select: { id_membership: true },
    });
    if (!exists) {
      throw new NotFoundException('Membership not found');
    }
  }

  private toCreateInput(dto: CreateMembershipDto): Prisma.membershipCreateInput {
    return {
      code: dto.code.trim(),
      title: dto.title.trim(),
      image: dto.image,
      link: dto.link,
      description: dto.description,
      benefits: dto.benefits,
      criteria: dto.criteria,
      status: dto.status?.trim() as any,
    };
  }

  private toUpdateInput(dto: UpdateMembershipDto): Prisma.membershipUpdateInput {
    return {
      code: dto.code ? dto.code.trim() : undefined,
      title: dto.title ? dto.title.trim() : undefined,
      image: dto.image,
      link: dto.link,
      description: dto.description,
      benefits: dto.benefits,
      criteria: dto.criteria,
      status: dto.status ? (dto.status.trim() as any) : undefined,
    };
  }
}
