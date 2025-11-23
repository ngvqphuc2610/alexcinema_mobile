import {
  ConflictException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcrypt';
import { randomBytes } from 'crypto';
import { UsersService, UserEntity } from '../users/users.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { JwtPayload } from './interfaces/jwt-payload.interface';
import { ForgotPasswordDto } from './dto/forgot-password.dto';
import { MailService } from '../mail/mail.service';

export interface AuthResponse {
  accessToken: string;
  expiresIn: string;
  user: UserEntity;
}

@Injectable()
export class AuthService {
  constructor(
    private readonly usersService: UsersService,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
    private readonly mailService: MailService,
  ) {}

  async register(dto: RegisterDto): Promise<AuthResponse> {
    const normalizedEmail = dto.email.toLowerCase();
    const existingEmail = await this.usersService.findByEmail(normalizedEmail);
    if (existingEmail) {
      throw new ConflictException('Email already in use');
    }

    const existingUsername = await this.usersService.findByUsername(
      dto.username,
    );
    if (existingUsername) {
      throw new ConflictException('Username already in use');
    }

    const user = await this.usersService.create({
      username: dto.username.trim(),
      email: normalizedEmail,
      password: dto.password,
      fullName: dto.fullName.trim(),
      phoneNumber: dto.phoneNumber,
    });

    return this.buildAuthResponse(user);
  }

  async login(dto: LoginDto): Promise<AuthResponse> {
    const user = await this.validateCredentials(
      dto.usernameOrEmail,
      dto.password,
    );
    return this.buildAuthResponse(user);
  }

  async requestPasswordReset(dto: ForgotPasswordDto) {
    const username = dto.username.trim();
    const email = dto.email.trim().toLowerCase();

    const candidate = await this.usersService.findByUsername(username);
    if (!candidate || candidate.email.toLowerCase() !== email) {
      throw new UnauthorizedException(
        'Tên đăng nhập hoặc email không chính xác',
      );
    }

    const token = randomBytes(32).toString('hex');
    const ttlMinutes = Number(
      this.configService.get<string>('RESET_TOKEN_TTL_MINUTES') ?? '30',
    );
    const expiresAt = new Date(Date.now() + ttlMinutes * 60 * 1000);

    await this.usersService.setResetToken(candidate.id_users, token, expiresAt);
    await this.mailService.sendPasswordResetEmail({
      to: email,
      username: candidate.full_name || candidate.username,
      token,
      expiresInMinutes: ttlMinutes,
    });

    return {
      message: 'Yêu cầu đặt lại mật khẩu đã được gửi đến email của bạn',
      expiresAt,
    };
  }

  private async validateCredentials(
    usernameOrEmail: string,
    password: string,
  ): Promise<UserEntity> {
    const identifier = usernameOrEmail.trim();
    const candidate = identifier.includes('@')
      ? await this.usersService.findByEmail(identifier.toLowerCase())
      : await this.usersService.findByUsername(identifier);

    if (!candidate) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const passwordValid = await bcrypt.compare(
      password,
      candidate.password_hash,
    );
    if (!passwordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    const { password_hash, ...safeUser } = candidate;
    return safeUser;
  }

  private async buildAuthResponse(user: UserEntity): Promise<AuthResponse> {
    const expiresIn = this.configService.get<string>('JWT_EXPIRES_IN', '15m');
    const payload: JwtPayload = {
      sub: user.id_users,
      username: user.username,
      role: user.role ?? 'user',
    };

    const accessToken = await this.jwtService.signAsync(payload);

    return {
      accessToken,
      expiresIn,
      user,
    };
  }
}
