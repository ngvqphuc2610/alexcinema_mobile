import { Module } from '@nestjs/common';
import { ShowtimesService } from './showtimes.service';
import { ShowtimesController } from './showtimes.controller';
import { PrismaModule } from '../prisma/prisma.module';
import { RolesGuard } from '../common/guards/roles.guard';

@Module({
  imports: [PrismaModule],
  controllers: [ShowtimesController],
  providers: [ShowtimesService, RolesGuard],
  exports: [ShowtimesService],
})
export class ShowtimesModule {}
