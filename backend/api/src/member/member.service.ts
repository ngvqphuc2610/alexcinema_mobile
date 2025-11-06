import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { Prisma, member } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CreateMemberDto } from './dto/create-member.dto';
import { UpdateMemberDto } from './dto/update-member.dto';

export interface MemberQueryParams {
  page?: number;
  limit?: number;
  status?: string;
  typeMemberId?: number;
  membershipId?: number;
  userId?: number;
}

@Injectable()
export class MemberService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: CreateMemberDto): Promise<member> {
    const existing = await this.prisma.member.findUnique({
      where: { id_user: dto.idUser },
    });
    if (existing) {
      throw new ConflictException('User already has a membership');
    }

    const data = this.toCreateInput(dto);
    return this.prisma.member.create({ data });
  }

  async findAll(params: MemberQueryParams = {}) {
    const page = Math.max(1, params.page ?? 1);
    const limit = Math.min(100, Math.max(1, params.limit ?? 20));

    const where: Prisma.memberWhereInput = {
      status: params.status?.trim() as any,
      id_typemember: params.typeMemberId ?? undefined,
      id_membership: params.membershipId ?? undefined,
      id_user: params.userId ?? undefined,
    };

    const [items, total] = await this.prisma.$transaction([
      this.prisma.member.findMany({
        where,
        skip: (page - 1) * limit,
        take: limit,
        orderBy: { created_at: 'desc' },
        include: {
          user: true,
          type_member: true,
          membership: true,
        },
      }),
      this.prisma.member.count({ where }),
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
    const record = await this.prisma.member.findUnique({
      where: { id_member: id },
      include: {
        user: true,
        type_member: true,
        membership: true,
      },
    });
    if (!record) {
      throw new NotFoundException('Member not found');
    }
    return record;
  }

  async findByUserId(userId: number) {
    const record = await this.prisma.member.findUnique({
      where: { id_user: userId },
      include: {
        user: true,
        type_member: true,
        membership: true,
      },
    });
    if (!record) {
      throw new NotFoundException('Member not found');
    }
    return record;
  }

  async update(id: number, dto: UpdateMemberDto) {
    await this.ensureExists(id);
    const data = this.toUpdateInput(dto);
    return this.prisma.member.update({
      where: { id_member: id },
      data,
      include: {
        user: true,
        type_member: true,
        membership: true,
      },
    });
  }

  async remove(id: number) {
    await this.ensureExists(id);
    return this.prisma.member.delete({
      where: { id_member: id },
      include: {
        user: true,
        type_member: true,
        membership: true,
      },
    });
  }

  private async ensureExists(id: number) {
    const exists = await this.prisma.member.findUnique({
      where: { id_member: id },
      select: { id_member: true },
    });
    if (!exists) {
      throw new NotFoundException('Member not found');
    }
  }

  private toCreateInput(dto: CreateMemberDto): Prisma.memberUncheckedCreateInput {
    return {
      id_user: dto.idUser,
      id_typemember: dto.idTypeMember,
      id_membership: dto.idMembership ?? undefined,
      points: dto.points ?? undefined,
      join_date: dto.joinDate ? new Date(dto.joinDate) : undefined,
      status: dto.status?.trim() as any,
    };
  }

  private toUpdateInput(dto: UpdateMemberDto): Prisma.memberUncheckedUpdateInput {
    return {
      id_user: dto.idUser ?? undefined,
      id_typemember: dto.idTypeMember ?? undefined,
      id_membership: dto.idMembership ?? undefined,
      points: dto.points ?? undefined,
      join_date: dto.joinDate ? new Date(dto.joinDate) : undefined,
      status: dto.status ? (dto.status.trim() as any) : undefined,
    };
  }
}
