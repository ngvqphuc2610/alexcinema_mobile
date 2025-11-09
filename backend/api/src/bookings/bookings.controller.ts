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
import { BookingsService, BookingQueryParams } from './bookings.service';
import { CreateBookingDto } from './dto/create-booking.dto';
import { UpdateBookingDto } from './dto/update-booking.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';

@Controller('bookings')
export class BookingsController {
  constructor(private readonly bookingsService: BookingsService) {}

  @Post()
  create(@Body() dto: CreateBookingDto) {
    return this.bookingsService.create(dto);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @Get()
  findAll(
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('userId') userId?: string,
    @Query('memberId') memberId?: string,
    @Query('showtimeId') showtimeId?: string,
    @Query('staffId') staffId?: string,
    @Query('promotionId') promotionId?: string,
    @Query('paymentStatus') paymentStatus?: string,
    @Query('bookingStatus') bookingStatus?: string,
    @Query('bookingCode') bookingCode?: string,
  ) {
    const params: BookingQueryParams = {
      page: this.toNumber(page),
      limit: this.toNumber(limit),
      userId: this.toNumber(userId),
      memberId: this.toNumber(memberId),
      showtimeId: this.toNumber(showtimeId),
      staffId: this.toNumber(staffId),
      promotionId: this.toNumber(promotionId),
      paymentStatus: paymentStatus?.trim(),
      bookingStatus: bookingStatus?.trim(),
      bookingCode: bookingCode?.trim(),
    };
    return this.bookingsService.findAll(params);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.bookingsService.findOne(id);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @Patch(':id')
  update(@Param('id', ParseIntPipe) id: number, @Body() dto: UpdateBookingDto) {
    return this.bookingsService.update(id, dto);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @Delete(':id')
  remove(@Param('id', ParseIntPipe) id: number) {
    return this.bookingsService.remove(id);
  }

  private toNumber(value?: string): number | undefined {
    if (!value) {
      return undefined;
    }
    const parsed = Number(value);
    return Number.isNaN(parsed) ? undefined : parsed;
  }
}
