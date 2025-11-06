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
import { ScreenService, ScreenQueryParams } from './screen.service';
import { CreateScreenDto } from './dto/create-screen.dto';
import { UpdateScreenDto } from './dto/update-screen.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';

@Controller('screens')
export class ScreenController {
  constructor(private readonly screenService: ScreenService) {}

  @Get()
  findAll(
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('cinemaId') cinemaId?: string,
    @Query('screenTypeId') screenTypeId?: string,
    @Query('status') status?: string,
    @Query('search') search?: string,
    @Query('minCapacity') minCapacity?: string,
  ) {
    const params: ScreenQueryParams = {
      page: this.toNumber(page),
      limit: this.toNumber(limit),
      cinemaId: this.toNumber(cinemaId),
      screenTypeId: this.toNumber(screenTypeId),
      status: status?.trim() || undefined,
      search: search?.trim() || undefined,
      minCapacity: this.toNumber(minCapacity),
    };
    return this.screenService.findAll(params);
  }

  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.screenService.findOne(id);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @Post()
  create(@Body() dto: CreateScreenDto) {
    return this.screenService.create(dto);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @Patch(':id')
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateScreenDto,
  ) {
    return this.screenService.update(id, dto);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @Delete(':id')
  remove(@Param('id', ParseIntPipe) id: number) {
    return this.screenService.remove(id);
  }

  private toNumber(value?: string): number | undefined {
    if (value === undefined || value === null || value === '') {
      return undefined;
    }
    const parsed = Number(value);
    return Number.isNaN(parsed) ? undefined : parsed;
  }
}
