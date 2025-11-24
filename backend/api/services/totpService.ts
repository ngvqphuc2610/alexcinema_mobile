import { Injectable } from '@nestjs/common';
import * as crypto from 'crypto';
import { authenticator } from 'otplib';
import { createDigest, createRandomBytes } from '@otplib/plugin-crypto';
import * as qrcode from 'qrcode';

authenticator.options = {
  crypto: {
    createDigest,
    createRandomBytes,
  },
};

const AES_ALGORITHM = 'aes-256-gcm';
const AES_IV_LENGTH = 12;

@Injectable()
export class TotpService {
  private getAesKey(): Buffer {
    const base64Key = process.env.TOTP_SECRET_KEY;
    if (!base64Key) {
      throw new Error('TOTP_SECRET_KEY chưa được cấu hình (base64 của 32 bytes)');
    }
    const key = Buffer.from(base64Key, 'base64');
    if (key.length !== 32) {
      throw new Error('TOTP_SECRET_KEY phải là base64 của 32 bytes (AES-256-GCM)');
    }
    return key;
  }

  encryptSecret(secret: string): string {
    const key = this.getAesKey();
    const iv = crypto.randomBytes(AES_IV_LENGTH);
    const cipher = crypto.createCipheriv(AES_ALGORITHM, key, iv);
    const encrypted = Buffer.concat([cipher.update(secret, 'utf8'), cipher.final()]);
    const authTag = cipher.getAuthTag();
    return Buffer.concat([iv, authTag, encrypted]).toString('base64');
  }

  private normaliseEncryptedPayload(payload: any): string {
    if (!payload) {
      throw new Error('Missing encrypted TOTP payload');
    }
    if (Buffer.isBuffer(payload)) {
      return payload.toString('utf8');
    }
    if (payload instanceof Uint8Array) {
      return Buffer.from(payload).toString('utf8');
    }
    if (typeof payload === 'string') {
      return payload.trim();
    }
    return String(payload);
  }

  decryptSecret(encryptedPayload: any): string {
    const key = this.getAesKey();
    const normalised = this.normaliseEncryptedPayload(encryptedPayload);
    if (!normalised) {
      throw new Error('Encrypted TOTP payload is empty');
    }
    const buffer = Buffer.from(normalised, 'base64');
    const iv = buffer.subarray(0, AES_IV_LENGTH);
    const authTag = buffer.subarray(AES_IV_LENGTH, AES_IV_LENGTH + 16);
    const encrypted = buffer.subarray(AES_IV_LENGTH + 16);
    const decipher = crypto.createDecipheriv(AES_ALGORITHM, key, iv);
    decipher.setAuthTag(authTag);
    const decrypted = Buffer.concat([decipher.update(encrypted), decipher.final()]);
    return decrypted.toString('utf8');
  }

  async generateTotpSetup(email: string): Promise<{
    secret: string;
    otpauthUrl: string;
    qrCode: string;
  }> {
    if (!email) {
      throw new Error('Cần truyền email để tạo TOTP');
    }
    const issuer = process.env.TOTP_ISSUER || 'AlexCinema';
    const secret = authenticator.generateSecret();
    const otpauthUrl = authenticator.keyuri(email, issuer, secret);
    const qrDataUrl = await qrcode.toDataURL(otpauthUrl, { errorCorrectionLevel: 'M' });

    return {
      secret,
      otpauthUrl,
      qrCode: qrDataUrl,
    };
  }

  verifyTotpToken(secret: string, token: string): boolean {
    if (!secret || !token) return false;
    return authenticator.check(token, secret);
  }
}