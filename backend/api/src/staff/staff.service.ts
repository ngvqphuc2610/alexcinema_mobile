import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { Prisma, staff } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service';
import { CreateStaffDto } from './dto/create-staff.dto';
import { UpdateStaffDto } from './dto/update-staff.dto';

export interface StaffQueryParams {
  page?: number;
  limit?: number;
  status?: string;
  typeStaffId?: number;
  search?: string;
}

export type StaffEntity = Omit<staff, 'password_hash'>;

@Injectable()
export class StaffService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: CreateStaffDto): Promise<StaffEntity> {
    const email = dto.email.toLowerCase();
    const existing = await this.prisma.staff.findUnique({ where: { email } });
    if (existing) {
      throw new ConflictException('Email already in use');
    }

    const passwordHash = await this.hashPassword(dto.password);
    const data: Prisma.staffUncheckedCreateInput = {
      id_typestaff: dto.idTypeStaff ?? undefined,
      staff_name: dto.staffName.trim(),
      email,
      password_hash: passwordHash,
      phone_number: dto.phoneNumber,
      address: dto.address,
      date_of_birth: dto.dateOfBirth ? new Date(dto.dateOfBirth) : undefined,
      hire_date: dto.hireDate ? new Date(dto.hireDate) : undefined,
      status: dto.status?.trim(),
      profile_image: dto.profileImage,
    };

    const staffMember = await this.prisma.staff.create({ data });
    return this.toStaffEntity(staffMember);
  }

  async findAll(params: StaffQueryParams = {}) {
    const page = Math.max(1, params.page ?? 1);
    const limit = Math.min(100, Math.max(1, params.limit ?? 20));

    const where: Prisma.staffWhereInput =
      params.search && params.search.trim().length > 0
        ? {
            OR: [
              { staff_name: { contains: params.search } },
              { email: { contains: params.search } },
            ],
            id_typestaff: params.typeStaffId ?? undefined,
            status: params.status?.trim(),
          }
        : {
            id_typestaff: params.typeStaffId ?? undefined,
            status: params.status?.trim(),
          };

    const [items, total] = await this.prisma.$transaction([
      this.prisma.staff.findMany({
        where,
        skip: (page - 1) * limit,
        take: limit,
        orderBy: { staff_name: 'asc' },
        include: { type_staff: true },
      }),
      this.prisma.staff.count({ where }),
    ]);

    return {
      items: items.map((item) => ({
        ...this.toStaffEntity(item),
        type_staff: item.type_staff,
      })),
      meta: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async findOne(id: number): Promise<StaffEntity & { type_staff: any | null }> {
    const staffMember = await this.prisma.staff.findUnique({
      where: { id_staff: id },
      include: { type_staff: true },
    });
    if (!staffMember) {
      throw new NotFoundException('Staff not found');
    }
    return { ...this.toStaffEntity(staffMember), type_staff: staffMember.type_staff };
  }

  async findByEmail(email: string): Promise<staff | null> {
    return this.prisma.staff.findUnique({ where: { email: email.toLowerCase() } });
  }

  async update(id: number, dto: UpdateStaffDto): Promise<StaffEntity> {
    const staffMember = await this.ensureExists(id);
    if (dto.email) {
      const email = dto.email.toLowerCase();
      if (email !== staffMember.email) {
        const existing = await this.prisma.staff.findUnique({ where: { email } });
        if (existing && existing.id_staff !== id) {
          throw new ConflictException('Email already in use');
        }
      }
    }

    const data: Prisma.staffUncheckedUpdateInput = {
      id_typestaff: dto.idTypeStaff ?? undefined,
      staff_name: dto.staffName ? dto.staffName.trim() : undefined,
      email: dto.email ? dto.email.toLowerCase() : undefined,
      phone_number: dto.phoneNumber,
      address: dto.address,
      date_of_birth: dto.dateOfBirth ? new Date(dto.dateOfBirth) : undefined,
      hire_date: dto.hireDate ? new Date(dto.hireDate) : undefined,
      status: dto.status ? dto.status.trim() : undefined,
      profile_image: dto.profileImage,
    };

    const updated = await this.prisma.staff.update({
      where: { id_staff: id },
      data,
    });
    return this.toStaffEntity(updated);
  }

  async updatePassword(id: number, newPassword: string): Promise<StaffEntity> {
    await this.ensureExists(id);
    const password_hash = await this.hashPassword(newPassword);
    const updated = await this.prisma.staff.update({
      where: { id_staff: id },
      data: { password_hash },
    });
    return this.toStaffEntity(updated);
  }

  async remove(id: number): Promise<StaffEntity> {
    await this.ensureExists(id);
    const deleted = await this.prisma.staff.delete({ where: { id_staff: id } });
    return this.toStaffEntity(deleted);
  }

  private async ensureExists(id: number): Promise<staff> {
    const staffMember = await this.prisma.staff.findUnique({ where: { id_staff: id } });
    if (!staffMember) {
      throw new NotFoundException('Staff not found');
    }
    return staffMember;
  }

  private toStaffEntity(staffMember: staff): StaffEntity {
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    const { password_hash, ...rest } = staffMember;
    return rest;
  }

  private async hashPassword(password: string): Promise<string> {
    return bcrypt.hash(password, 10);
  }
}
