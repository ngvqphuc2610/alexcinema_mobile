import {
  ConflictException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcrypt';
import { UsersService, UserEntity } from '../users/users.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { JwtPayload } from './interfaces/jwt-payload.interface';

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
  ) {}

  async register(dto: RegisterDto): Promise<AuthResponse> {
    const normalizedEmail = dto.email.toLowerCase();
    const existingEmail = await this.usersService.findByEmail(normalizedEmail);
    if (existingEmail) {
      throw new ConflictException('Email already in use');
    }

    const existingUsername = await this.usersService.findByUsername(dto.username);
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
    const user = await this.validateCredentials(dto.usernameOrEmail, dto.password);
    return this.buildAuthResponse(user);
  }

  private async validateCredentials(
    usernameOrEmail: string,
    password: string,
  ): Promise<UserEntity> {
    const identifier = usernameOrEmail.trim();
    const candidate =
      identifier.includes('@')
        ? await this.usersService.findByEmail(identifier.toLowerCase())
        : await this.usersService.findByUsername(identifier);

    if (!candidate) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const passwordValid = await bcrypt.compare(password, candidate.password_hash);
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
      role: user.role,
    };

    const accessToken = await this.jwtService.signAsync(payload);

    return {
      accessToken,
      expiresIn,
      user,
    };
  }
}

