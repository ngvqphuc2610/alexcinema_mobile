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
import { SeatService, SeatQueryParams } from './seat.service';
import { CreateSeatDto } from './dto/create-seat.dto';
import { UpdateSeatDto } from './dto/update-seat.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';

@Controller('seats')
export class SeatController {
  constructor(private readonly seatService: SeatService) {}

  @Get()
  findAll(
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('screenId') screenId?: string,
    @Query('seatTypeId') seatTypeId?: string,
    @Query('status') status?: string,
    @Query('seatRow') seatRow?: string,
    @Query('seatNumber') seatNumber?: string,
  ) {
    const params: SeatQueryParams = {
      page: this.toNumber(page),
      limit: this.toNumber(limit),
      screenId: this.toNumber(screenId),
      seatTypeId: this.toNumber(seatTypeId),
      status: status?.trim() || undefined,
      seatRow: seatRow?.trim() || undefined,
      seatNumber: this.toNumber(seatNumber),
    };
    return this.seatService.findAll(params);
  }

  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.seatService.findOne(id);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @Post()
  create(@Body() dto: CreateSeatDto) {
    return this.seatService.create(dto);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @Patch(':id')
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateSeatDto,
  ) {
    return this.seatService.update(id, dto);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @Delete(':id')
  remove(@Param('id', ParseIntPipe) id: number) {
    return this.seatService.remove(id);
  }

  private toNumber(value?: string): number | undefined {
    if (value === undefined || value === null || value === '') {
      return undefined;
    }
    const parsed = Number(value);
    return Number.isNaN(parsed) ? undefined : parsed;
  }
}
