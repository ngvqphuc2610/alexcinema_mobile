import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  ParseIntPipe,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { GenreMoviesService, GenreMoviesQueryParams } from './genre_movies.service';
import { CreateGenreMovieDto } from './dto/create-genre-movie.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';

@Controller('genre-movies')
export class GenreMoviesController {
  constructor(private readonly genreMoviesService: GenreMoviesService) {}

  @Get()
  findAll(
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('genreId') genreId?: string,
    @Query('movieId') movieId?: string,
  ) {
    const params: GenreMoviesQueryParams = {
      page: this.toNumber(page),
      limit: this.toNumber(limit),
      genreId: this.toNumber(genreId),
      movieId: this.toNumber(movieId),
    };
    return this.genreMoviesService.findAll(params);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @Post()
  create(@Body() dto: CreateGenreMovieDto) {
    return this.genreMoviesService.create(dto);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('admin')
  @Delete(':genreId/:movieId')
  remove(
    @Param('genreId', ParseIntPipe) genreId: number,
    @Param('movieId', ParseIntPipe) movieId: number,
  ) {
    return this.genreMoviesService.remove(genreId, movieId);
  }

  private toNumber(value?: string): number | undefined {
    if (!value) {
      return undefined;
    }
    const parsed = Number(value);
    return Number.isNaN(parsed) ? undefined : parsed;
  }
}
