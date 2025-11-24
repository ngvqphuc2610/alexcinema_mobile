import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  ParseIntPipe,
  Patch,
  Post,
  Query,
  Request,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { UsersService, UserPaginationParams } from './users.service';
import { UpdateUserDto } from './dto/update-user.dto';
import { ChangePasswordDto } from './dto/change-password.dto';
import { Enable2faDto } from './dto/enable-2fa.dto';
import { Disable2faDto } from './dto/disable-2fa.dto';

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) { }

  @UseGuards(JwtAuthGuard)
  @Get('me')
  getProfile(@Request() req: any) {
    return req.user;
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @Get()
  findAll(
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('search') search?: string,
  ) {
    const pagination: UserPaginationParams = {
      page: this.toNumber(page),
      limit: this.toNumber(limit),
      search: search?.trim() || undefined,
    };
    return this.usersService.findAll(pagination);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.usersService.findOne(id);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @Patch(':id/password')
  updatePassword(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: ChangePasswordDto,
  ) {
    return this.usersService.updatePassword(id, dto.newPassword);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @Patch(':id')
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateUserDto,
  ) {
    return this.usersService.update(id, dto);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @Delete(':id')
  remove(@Param('id', ParseIntPipe) id: number) {
    return this.usersService.remove(id);
  }

  @UseGuards(JwtAuthGuard)
  @Post('me/2fa/setup')
  setup2FA(@Request() req: any) {
    return this.usersService.setup2FA(req.user.id_users);
  }

  @UseGuards(JwtAuthGuard)
  @Post('me/2fa/enable')
  enable2FA(@Request() req: any, @Body() dto: Enable2faDto) {
    return this.usersService.enable2FA(req.user.id_users, dto.token);
  }

  @UseGuards(JwtAuthGuard)
  @Post('me/2fa/disable')
  disable2FA(@Request() req: any, @Body() dto: Disable2faDto) {
    return this.usersService.disable2FA(req.user.id_users, dto.token);
  }

  @UseGuards(JwtAuthGuard)
  @Get('me/2fa/backup-codes')
  getBackupCodes(@Request() req: any) {
    return this.usersService.getBackupCodes(req.user.id_users);
  }

  @UseGuards(JwtAuthGuard)
  @Post('me/2fa/backup-codes/regenerate')
  regenerateBackupCodes(@Request() req: any) {
    return this.usersService.regenerateBackupCodes(req.user.id_users);
  }

  private toNumber(value?: string): number | undefined {
    if (value === undefined) {
      return undefined;
    }
    const parsed = parseInt(value, 10);
    return Number.isNaN(parsed) ? undefined : parsed;
  }
}
