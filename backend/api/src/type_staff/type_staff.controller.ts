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
  UseGuards,
} from '@nestjs/common';
import { TypeStaffService, TypeStaffQueryParams } from './type_staff.service';
import { CreateTypeStaffDto } from './dto/create-type-staff.dto';
import { UpdateTypeStaffDto } from './dto/update-type-staff.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';

@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('admin')
@Controller('type-staff')
export class TypeStaffController {
  constructor(private readonly typeStaffService: TypeStaffService) {}

  @Get()
  findAll(
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('search') search?: string,
  ) {
    const params: TypeStaffQueryParams = {
      page: this.toNumber(page),
      limit: this.toNumber(limit),
      search: search?.trim() || undefined,
    };
    return this.typeStaffService.findAll(params);
  }

  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.typeStaffService.findOne(id);
  }

  @Post()
  create(@Body() dto: CreateTypeStaffDto) {
    return this.typeStaffService.create(dto);
  }

  @Patch(':id')
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateTypeStaffDto,
  ) {
    return this.typeStaffService.update(id, dto);
  }

  @Delete(':id')
  remove(@Param('id', ParseIntPipe) id: number) {
    return this.typeStaffService.remove(id);
  }

  private toNumber(value?: string): number | undefined {
    if (value === undefined || value === null || value === '') {
      return undefined;
    }
    const parsed = Number(value);
    return Number.isNaN(parsed) ? undefined : parsed;
  }
}
