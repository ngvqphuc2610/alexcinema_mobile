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
import { EntertainmentService, EntertainmentQueryParams } from './entertainment.service';
import { CreateEntertainmentDto } from './dto/create-entertainment.dto';
import { UpdateEntertainmentDto } from './dto/update-entertainment.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';

@Controller('entertainment')
export class EntertainmentController {
  constructor(private readonly entertainmentService: EntertainmentService) {}

  @Get()
  findAll(
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('status') status?: string,
    @Query('featured') featured?: string,
    @Query('search') search?: string,
    @Query('cinemaId') cinemaId?: string,
  ) {
    const params: EntertainmentQueryParams = {
      page: this.toNumber(page),
      limit: this.toNumber(limit),
      status: status?.trim() || undefined,
      featured: this.toBoolean(featured),
      search: search?.trim() || undefined,
      cinemaId: this.toNumber(cinemaId),
    };
    return this.entertainmentService.findAll(params);
  }

  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.entertainmentService.findOne(id);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @Post()
  create(@Body() dto: CreateEntertainmentDto) {
    return this.entertainmentService.create(dto);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @Patch(':id')
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateEntertainmentDto,
  ) {
    return this.entertainmentService.update(id, dto);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @Delete(':id')
  remove(@Param('id', ParseIntPipe) id: number) {
    return this.entertainmentService.remove(id);
  }

  private toNumber(value?: string): number | undefined {
    if (value === undefined || value === null || value === '') {
      return undefined;
    }
    const parsed = Number(value);
    return Number.isNaN(parsed) ? undefined : parsed;
  }

  private toBoolean(value?: string): boolean | undefined {
    if (value === undefined || value === null || value === '') {
      return undefined;
    }
    const normalized = value.toLowerCase();
    if (normalized === 'true') return true;
    if (normalized === 'false') return false;
    return undefined;
  }
}
