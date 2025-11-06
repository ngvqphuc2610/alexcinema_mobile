import { Module } from '@nestjs/common';
import { GenreMoviesService } from './genre_movies.service';
import { GenreMoviesController } from './genre_movies.controller';
import { PrismaModule } from '../prisma/prisma.module';
import { RolesGuard } from '../common/guards/roles.guard';

@Module({
  imports: [PrismaModule],
  controllers: [GenreMoviesController],
  providers: [GenreMoviesService, RolesGuard],
  exports: [GenreMoviesService],
})
export class GenreMoviesModule {}
