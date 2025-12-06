import { Injectable, NotFoundException, Logger } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { MailService } from '../mail/mail.service';
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
  private readonly logger = new Logger(ContactService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly mailService: MailService,
  ) { }

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

    // Save to database first
    const contact = await this.prisma.contact.create({ data });

    this.logger.log(`📝 Contact #${contact.id_contact} created from ${contact.email}`);

    // Send emails asynchronously (don't block the response)
    this.sendContactEmails(contact).catch((error) => {
      this.logger.error(`Failed to send contact emails: ${error.message}`);
    });

    return contact;
  }

  private async sendContactEmails(contact: any) {
    try {
      // Send notification to admin
      await this.mailService.sendContactNotificationEmail({
        customerName: contact.name,
        customerEmail: contact.email,
        subject: contact.subject,
        message: contact.message,
        contactId: contact.id_contact,
      });

      // Send confirmation to customer
      await this.mailService.sendContactConfirmationEmail({
        to: contact.email,
        name: contact.name,
        subject: contact.subject,
      });

      this.logger.log(`✅ Contact emails sent successfully for contact #${contact.id_contact}`);
    } catch (error) {
      this.logger.error(`❌ Error sending contact emails: ${error.message}`);
      throw error;
    }
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
