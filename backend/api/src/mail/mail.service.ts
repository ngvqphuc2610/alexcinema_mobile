import {
  Injectable,
  InternalServerErrorException,
  Logger,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as nodemailer from 'nodemailer';

interface PasswordResetPayload {
  to: string;
  username: string;
  token: string;
  expiresInMinutes: number;
}

@Injectable()
export class MailService {
  private readonly logger = new Logger(MailService.name);
  private readonly transporter?: nodemailer.Transporter;
  private readonly fromAddress: string;
  private readonly appUrl: string;

  constructor(private readonly configService: ConfigService) {
    const host = this.configService.get<string>('MAIL_HOST');
    const port = Number(this.configService.get<string>('MAIL_PORT') ?? '587');
    const user = this.configService.get<string>('MAIL_USER');
    const pass = this.configService.get<string>('MAIL_PASSWORD');
    const secure =
      (
        this.configService.get<string>('MAIL_SECURE') ?? 'false'
      ).toLowerCase() === 'true';

    this.fromAddress =
      this.configService.get<string>('MAIL_FROM') ??
      (user ? `${user}` : 'no-reply@example.com');
    this.appUrl =
      this.configService.get<string>('APP_URL') ?? 'http://localhost:3000';

    if (host && user && pass) {
      this.transporter = nodemailer.createTransport({
        host,
        port,
        secure,
        auth: {
          user,
          pass,
        },
      });
    } else {
      this.logger.warn(
        'Mail transport is not fully configured. Forgot password emails will fail until MAIL_HOST, MAIL_USER and MAIL_PASSWORD are provided.',
      );
    }
  }

  private ensureTransporter() {
    if (!this.transporter) {
      throw new InternalServerErrorException(
        'Mail service is not configured yet',
      );
    }
  }

  async sendPasswordResetEmail(payload: PasswordResetPayload) {
    this.ensureTransporter();

    const resetLink = this.buildResetLink(payload.token);
    const subject = 'Đặt lại mật khẩu của bạn';
    const text = [
      `Xin chào ${payload.username},`,
      '',
      'Chúng tôi nhận được yêu cầu đặt lại mật khẩu cho tài khoản của bạn.',
      `Hãy bấm vào liên kết sau (hoặc dán vào trình duyệt) để đặt lại mật khẩu: ${resetLink}`,
      '',
      `Liên kết có hiệu lực trong ${payload.expiresInMinutes} phút.`,
      '',
      'Nếu bạn không thực hiện yêu cầu này, vui lòng bỏ qua email.',
    ].join('\n');

    const html = `
      <p>Xin chào <strong>${payload.username}</strong>,</p>
      <p>Chúng tôi nhận được yêu cầu đặt lại mật khẩu cho tài khoản của bạn.</p>
      <p>Vui lòng nhấn vào nút bên dưới để đặt lại mật khẩu:</p>
      <p>
        <a href="${resetLink}" style="
          display:inline-block;
          padding:12px 24px;
          border-radius:6px;
          background-color:#5B21B6;
          color:#ffffff;
          text-decoration:none;
          font-weight:600;
        ">Đặt lại mật khẩu</a>
      </p>
      <p>Nếu bạn không thể nhấp vào nút, hãy dán liên kết sau vào trình duyệt:</p>
      <p><a href="${resetLink}">${resetLink}</a></p>
      <p>Liên kết này sẽ hết hạn sau ${payload.expiresInMinutes} phút.</p>
      <p>Nếu bạn không thực hiện yêu cầu này, hãy bỏ qua email.</p>
    `;

    await this.transporter!.sendMail({
      from: this.fromAddress,
      to: payload.to,
      subject,
      text,
      html,
    });
  }

  private buildResetLink(token: string): string {
    const normalizedBase = this.appUrl.endsWith('/')
      ? this.appUrl.slice(0, -1)
      : this.appUrl;
    return `${normalizedBase}/reset-password?token=${token}`;
  }
}
