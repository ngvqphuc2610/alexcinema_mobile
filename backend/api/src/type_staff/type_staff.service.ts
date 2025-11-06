import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CreateTypeStaffDto } from './dto/create-type-staff.dto';
import { UpdateTypeStaffDto } from './dto/update-type-staff.dto';

export interface TypeStaffQueryParams {
  page?: number;
  limit?: number;
  search?: string;
}

@Injectable()
export class TypeStaffService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: CreateTypeStaffDto) {
    const typeName = dto.typeName.trim();
    const existing = await this.prisma.type_staff.findUnique({
      where: { type_name: typeName },
    });
    if (existing) {
      throw new ConflictException('Staff type already exists');
    }

    const data: Prisma.type_staffCreateInput = {
      type_name: typeName,
      description: dto.description,
      permission_level: dto.permissionLevel ?? undefined,
    };

    return this.prisma.type_staff.create({ data });
  }

  async findAll(params: TypeStaffQueryParams = {}) {
    const page = Math.max(1, params.page ?? 1);
    const limit = Math.min(50, Math.max(1, params.limit ?? 20));

    const where: Prisma.type_staffWhereInput = params.search
      ? { type_name: { contains: params.search } }
      : {};

    const [items, total] = await this.prisma.$transaction([
      this.prisma.type_staff.findMany({
        where,
        skip: (page - 1) * limit,
        take: limit,
        orderBy: { permission_level: 'asc' },
      }),
      this.prisma.type_staff.count({ where }),
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
    const record = await this.prisma.type_staff.findUnique({
      where: { id_typestaff: id },
    });
    if (!record) {
      throw new NotFoundException('Staff type not found');
    }
    return record;
  }

  async update(id: number, dto: UpdateTypeStaffDto) {
    await this.ensureExists(id);
    if (dto.typeName) {
      const typeName = dto.typeName.trim();
      const existing = await this.prisma.type_staff.findUnique({
        where: { type_name: typeName },
      });
      if (existing && existing.id_typestaff !== id) {
        throw new ConflictException('Staff type already exists');
      }
    }

    const data: Prisma.type_staffUpdateInput = {
      type_name: dto.typeName ? dto.typeName.trim() : undefined,
      description: dto.description,
      permission_level: dto.permissionLevel ?? undefined,
    };

    return this.prisma.type_staff.update({
      where: { id_typestaff: id },
      data,
    });
  }

  async remove(id: number) {
    await this.ensureExists(id);
    return this.prisma.type_staff.delete({ where: { id_typestaff: id } });
  }

  private async ensureExists(id: number) {
    const exists = await this.prisma.type_staff.findUnique({
      where: { id_typestaff: id },
      select: { id_typestaff: true },
    });
    if (!exists) {
      throw new NotFoundException('Staff type not found');
    }
  }
}
