import { Injectable, NotFoundException } from '@nestjs/common';
import { Prisma, users } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';

export interface UserPaginationParams {
  page?: number;
  limit?: number;
  search?: string;
}

export type UserEntity = Omit<users, 'password_hash'>;

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: CreateUserDto): Promise<UserEntity> {
    const passwordHash = await this.hashPassword(dto.password);
    const normalizedEmail = dto.email.toLowerCase();
    const username = dto.username.trim();
    const fullName = dto.fullName.trim();
    const data: Prisma.usersCreateInput = {
      username,
      email: normalizedEmail,
      password_hash: passwordHash,
      full_name: fullName,
      phone_number: dto.phoneNumber,
      date_of_birth: dto.dateOfBirth ? new Date(dto.dateOfBirth) : undefined,
      gender: dto.gender,
      address: dto.address,
      profile_image: dto.profileImage,
      role: dto.role ?? undefined,
      status: dto.status ?? undefined,
    };

    const user = await this.prisma.users.create({ data });
    return this.toUserEntity(user);
  }

  async findAll(params: UserPaginationParams = {}) {
    const page = Math.max(1, params.page ?? 1);
    const limit = Math.min(100, Math.max(1, params.limit ?? 20));
    const where: Prisma.usersWhereInput = params.search
      ? {
          OR: [
            { username: { contains: params.search } },
            { email: { contains: params.search } },
            { full_name: { contains: params.search } },
          ],
        }
      : {};

    const [items, total] = await this.prisma.$transaction([
      this.prisma.users.findMany({
        where,
        skip: (page - 1) * limit,
        take: limit,
        orderBy: { created_at: 'desc' },
      }),
      this.prisma.users.count({ where }),
    ]);

    return {
      items: items.map((item) => this.toUserEntity(item)),
      meta: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async findOne(id: number): Promise<UserEntity> {
    const user = await this.getUserOrThrow(id);
    return this.toUserEntity(user);
  }

  async findByEmail(email: string): Promise<users | null> {
    return this.prisma.users.findUnique({
      where: { email: email.toLowerCase() },
    });
  }

  async findByUsername(username: string): Promise<users | null> {
    return this.prisma.users.findUnique({
      where: { username: username.trim() },
    });
  }

  async setResetToken(
    userId: number,
    token: string,
    expiresAt: Date,
  ): Promise<void> {
    await this.prisma.users.update({
      where: { id_users: userId },
      data: {
        reset_token: token,
        reset_token_expiry: expiresAt,
      },
    });
  }

  async update(id: number, dto: UpdateUserDto): Promise<UserEntity> {
    await this.getUserOrThrow(id);

    const data: Prisma.usersUpdateInput = {
      username: dto.username ? dto.username.trim() : undefined,
      email: dto.email ? dto.email.toLowerCase() : undefined,
      full_name: dto.fullName ? dto.fullName.trim() : undefined,
      phone_number: dto.phoneNumber,
      date_of_birth: dto.dateOfBirth ? new Date(dto.dateOfBirth) : undefined,
      gender: dto.gender,
      address: dto.address,
      profile_image: dto.profileImage,
      role: dto.role ?? undefined,
      status: dto.status ?? undefined,
    };

    const user = await this.prisma.users.update({
      where: { id_users: id },
      data,
    });
    return this.toUserEntity(user);
  }

  async updatePassword(id: number, newPassword: string): Promise<UserEntity> {
    await this.getUserOrThrow(id);
    const passwordHash = await this.hashPassword(newPassword);
    const user = await this.prisma.users.update({
      where: { id_users: id },
      data: { password_hash: passwordHash },
    });
    return this.toUserEntity(user);
  }

  async remove(id: number): Promise<UserEntity> {
    await this.getUserOrThrow(id);
    const user = await this.prisma.users.delete({ where: { id_users: id } });
    return this.toUserEntity(user);
  }

  private async getUserOrThrow(id: number): Promise<users> {
    const user = await this.prisma.users.findUnique({
      where: { id_users: id },
    });
    if (!user) {
      throw new NotFoundException('User not found');
    }
    return user;
  }

  private toUserEntity(user: users): UserEntity {
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    const { password_hash, ...rest } = user;
    return rest;
  }

  private async hashPassword(password: string): Promise<string> {
    return bcrypt.hash(password, 10);
  }
}
