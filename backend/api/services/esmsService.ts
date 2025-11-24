import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import axios from 'axios';

interface EsmsConfig {
  apiKey: string;
  secretKey: string;
  brandName?: string;
  smsType: number;
  sandbox: number;
}

interface SendSmsParams {
  phone: string;
  content: string;
  smsType?: number;
  isUnicode?: boolean;
}

interface SendOtpSmsParams {
  phone: string;
  otp: string;
  ttlMinutes?: number;
  appHash?: string;
  transactionId?: string;
}

interface EsmsResponse {
  CodeResult: string;
  CountRegenerate?: number;
  SMSID?: string;
  RefId?: string;
  ErrorMessage?: string;
  smsId?: string;
}

interface SmsReport {
  Status: string;
  ErrorCode?: string;
  ErrorMessage?: string;
  ReceiveTime?: string;
  SentTime?: string;
}

@Injectable()
export class EsmsService {
  private readonly logger = new Logger(EsmsService.name);
  private readonly config: EsmsConfig;
  private readonly sendEndpoint: string;
  private readonly reportEndpoint: string;

  constructor(private readonly configService: ConfigService) {
    this.sendEndpoint =
      this.configService.get('ESMS_SEND_ENDPOINT') ||
      'https://rest.esms.vn/MainService.svc/json/SendMultipleMessage_V4_post_json/';

    this.reportEndpoint =
      this.configService.get('ESMS_REPORT_ENDPOINT') ||
      'https://rest.esms.vn/MainService.svc/json/GetReport_V4_post_json/';

    this.config = {
      apiKey: this.configService.get('ESMS_API_KEY', ''),
      secretKey: this.configService.get('ESMS_API_SECRET_KEY', ''),
      brandName: this.configService.get('ESMS_BRAND_NAME'),
      smsType: Number.parseInt(this.configService.get('ESMS_SMS_TYPE', '2'), 10),
      sandbox: this.configService.get('ESMS_SANDBOX') === '1' ? 1 : 0,
    };
  }

  private ensureConfig(): void {
    if (!this.config.apiKey || !this.config.secretKey) {
      throw new Error('ESMS_API_KEY hoặc ESMS_SECRET_KEY chưa được cấu hình');
    }

    if (!this.config.brandName && (this.config.smsType === 2 || this.config.smsType === 4)) {
      throw new Error(`ESMS_BRAND_NAME bắt buộc khi SmsType = ${this.config.smsType}`);
    }
  }

  normalizePhone(phone: string): string {
    if (!phone) return '';
    let sanitized = String(phone).trim();

    if (sanitized.startsWith('+')) {
      sanitized = sanitized.slice(1);
    }

    sanitized = sanitized.replace(/[\s\-\.]/g, '');

    if (sanitized.startsWith('0')) {
      sanitized = `84${sanitized.slice(1)}`;
    }

    this.logger.debug(`Normalized phone: ${phone} -> ${sanitized}`);
    return sanitized;
  }

  private buildOtpMessage(
    otp: string,
    options: { ttlMinutes?: number; appHash?: string } = {},
  ): string {
    const { ttlMinutes = 5, appHash } = options;
    const lines = [`Ma OTP cua ban la: ${otp}`];
    lines.push(`Het han trong ${ttlMinutes} phut.`);

    if (appHash) {
      lines.push(appHash);
    }

    const message = lines.join('\n');
    this.logger.debug('OTP Message:', message);
    return message;
  }

  async sendSms(params: SendSmsParams): Promise<EsmsResponse> {
    this.ensureConfig();

    if (!params.phone) {
      throw new Error('Thiếu số điện thoại khi gửi SMS');
    }
    if (!params.content) {
      throw new Error('Thiếu nội dung SMS');
    }

    const finalSmsType = params.smsType ?? this.config.smsType ?? 8;
    const payload: any = {
      ApiKey: this.config.apiKey,
      SecretKey: this.config.secretKey,
      Phone: this.normalizePhone(params.phone),
      Content: params.content,
      SmsType: finalSmsType,
      IsUnicode: params.isUnicode ? 1 : 0,
    };

    if ((finalSmsType === 2 || finalSmsType === 4) && this.config.brandName) {
      payload.BrandName = this.config.brandName;
    }

    if (this.config.sandbox === 1) {
      payload.Sandbox = 1;
    }

    this.logger.log('Sending SMS with params:', {
      Phone: payload.Phone,
      ContentLength: payload.Content.length,
      SmsType: payload.SmsType,
      BrandName: payload.BrandName || '(none)',
      IsUnicode: payload.IsUnicode,
      Sandbox: payload.Sandbox || 0,
    });

    try {
      const response = await axios.post(this.sendEndpoint, payload, {
        timeout: 15000,
        headers: {
          'Content-Type': 'application/json',
        },
      });

      const data: EsmsResponse = response.data ?? {};
      this.logger.log('eSMS Response:', {
        CodeResult: data.CodeResult,
        CountRegenerate: data.CountRegenerate,
        SMSID: data.SMSID,
        ErrorMessage: data.ErrorMessage,
      });

      if (`${data.CodeResult}` !== '100') {
        const errorMessages: Record<string, string> = {
          '101': 'Thiếu ApiKey hoặc SecretKey',
          '102': 'ApiKey hoặc SecretKey không đúng',
          '103': 'Tài khoản không đủ tiền',
          '104': 'BrandName không tồn tại hoặc chưa được duyệt',
          '118': 'Số điện thoại không hợp lệ',
          '119': 'Loại tin nhắn (SmsType) không hợp lệ',
          '131': 'Tin nhắn chứa nội dung vi phạm',
        };

        const errorMsg =
          errorMessages[data.CodeResult] || data.ErrorMessage || 'Unknown error';
        const error: any = new Error(`eSMS error [${data.CodeResult}]: ${errorMsg}`);
        error.response = data;
        throw error;
      }

      const smsId = data.SMSID || data.RefId;
      this.logger.log(`SMS sent successfully. SMSID: ${smsId}`);

      return { ...data, smsId };
    } catch (error: any) {
      if (error.response?.data) {
        this.logger.error('eSMS API error:', error.response.data);
      } else if (error.request) {
        this.logger.error('No response from eSMS:', error.message);
      } else {
        this.logger.error('Request setup error:', error.message);
      }
      throw error;
    }
  }

  async sendOtpSms(params: SendOtpSmsParams): Promise<EsmsResponse> {
    const { phone, otp, ttlMinutes = 5, appHash, transactionId } = params;
    const content = this.buildOtpMessage(otp, { ttlMinutes, appHash });

    const result = await this.sendSms({
      phone,
      content,
      smsType: 8,
      isUnicode: false,
    });

    if (transactionId) {
      this.logger.debug(`Transaction ID: ${transactionId}`);
    }

    return result;
  }

  async getSmsSendReport(smsId: string): Promise<SmsReport | null> {
    this.ensureConfig();

    if (!smsId) {
      throw new Error('Thiếu SMSID khi kiểm tra report');
    }

    const cleanSmsId = String(smsId).trim();
    const payload = {
      ApiKey: this.config.apiKey,
      SecretKey: this.config.secretKey,
      SMSID: cleanSmsId,
    };

    this.logger.debug(`Checking report for SMSID: ${cleanSmsId}`);

    try {
      const response = await axios.post(this.reportEndpoint, payload, {
        timeout: 10000,
        headers: {
          'Content-Type': 'application/json',
        },
      });

      const data: any = response.data ?? {};

      this.logger.debug('GetReport Raw Response:', data);

      if (`${data.CodeResult}` !== '100') {
        this.logger.error(
          `GetReport error: CodeResult=${data.CodeResult}, Message=${data.ErrorMessage}`,
        );
        return null;
      }

      const report: SmsReport = data.Data?.[0] ?? {};

      const statusMessages: Record<string, string> = {
        '0': 'Chưa gửi',
        '1': 'Đã gửi thành công',
        '2': 'Gửi thất bại',
        '3': 'Đang gửi',
      };

      this.logger.log(`SMS Report for ${cleanSmsId}:`, {
        Status: `${report.Status} - ${statusMessages[report.Status] || 'Unknown'}`,
        ErrorCode: report.ErrorCode || 'N/A',
        ErrorMessage: report.ErrorMessage || 'N/A',
        ReceiveTime: report.ReceiveTime || 'N/A',
        SentTime: report.SentTime || 'N/A',
      });

      return report;
    } catch (error: any) {
      if (error.response?.status === 404) {
        this.logger.error(
          'GetReport 404: Endpoint không tồn tại hoặc SMSID chưa có trong hệ thống. Thử lại sau 30-60s.',
        );
      } else if (error.response?.data) {
        this.logger.error('GetReport error response:', error.response.data);
      } else {
        this.logger.error('GetReport request error:', error.message);
      }
      return null;
    }
  }
}