import { Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CreateContactDto } from './dto/create-contact.dto';
import { UpdateContactDto } from './dto/update-contact.dto';

export interface ContactQueryParams {
  page?: number;
  limit?: number;
  status?: string;
  staffId?: number;
  search?: string;
}

@Injectable()
export class ContactService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: CreateContactDto) {
    const data: Prisma.contactUncheckedCreateInput = {
      name: dto.name.trim(),
      email: dto.email.toLowerCase(),
      subject: dto.subject.trim(),
      message: dto.message,
      id_staff: dto.idStaff ?? undefined,
      status: dto.status?.trim(),
      reply: dto.reply,
    };
    return this.prisma.contact.create({ data });
  }

  async findAll(params: ContactQueryParams = {}) {
    const page = Math.max(1, params.page ?? 1);
    const limit = Math.min(100, Math.max(1, params.limit ?? 20));

    const where: Prisma.contactWhereInput =
      params.search && params.search.trim().length > 0
        ? {
            OR: [
              { name: { contains: params.search } },
              { email: { contains: params.search } },
              { subject: { contains: params.search } },
            ],
            status: params.status?.trim(),
            id_staff: params.staffId ?? undefined,
          }
        : {
            status: params.status?.trim(),
            id_staff: params.staffId ?? undefined,
          };

    const [items, total] = await this.prisma.$transaction([
      this.prisma.contact.findMany({
        where,
        skip: (page - 1) * limit,
        take: limit,
        orderBy: { contact_date: 'desc' },
        include: { staff: true },
      }),
      this.prisma.contact.count({ where }),
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
    const contact = await this.prisma.contact.findUnique({
      where: { id_contact: id },
      include: { staff: true },
    });
    if (!contact) {
      throw new NotFoundException('Contact not found');
    }
    return contact;
  }

  async update(id: number, dto: UpdateContactDto) {
    await this.ensureExists(id);
    const data: Prisma.contactUncheckedUpdateInput = {
      id_staff: dto.idStaff ?? undefined,
      subject: dto.subject ? dto.subject.trim() : undefined,
      message: dto.message ?? undefined,
      status: dto.status ? dto.status.trim() : undefined,
      reply: dto.reply ?? undefined,
      reply_date: dto.replyDate ? new Date(dto.replyDate) : undefined,
    };
    return this.prisma.contact.update({
      where: { id_contact: id },
      data,
      include: { staff: true },
    });
  }

  async remove(id: number) {
    await this.ensureExists(id);
    return this.prisma.contact.delete({ where: { id_contact: id } });
  }

  private async ensureExists(id: number) {
    const exists = await this.prisma.contact.findUnique({
      where: { id_contact: id },
      select: { id_contact: true },
    });
    if (!exists) {
      throw new NotFoundException('Contact not found');
    }
  }
}
