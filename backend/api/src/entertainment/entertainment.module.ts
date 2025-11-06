import { Module } from '@nestjs/common';
import { EntertainmentService } from './entertainment.service';
import { EntertainmentController } from './entertainment.controller';
import { PrismaModule } from '../prisma/prisma.module';
import { RolesGuard } from '../common/guards/roles.guard';

@Module({
  imports: [PrismaModule],
  controllers: [EntertainmentController],
  providers: [EntertainmentService, RolesGuard],
  exports: [EntertainmentService],
})
export class EntertainmentModule {}
