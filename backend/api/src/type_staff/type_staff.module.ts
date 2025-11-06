import { Module } from '@nestjs/common';
import { TypeStaffService } from './type_staff.service';
import { TypeStaffController } from './type_staff.controller';
import { PrismaModule } from '../prisma/prisma.module';
import { RolesGuard } from '../common/guards/roles.guard';

@Module({
  imports: [PrismaModule],
  controllers: [TypeStaffController],
  providers: [TypeStaffService, RolesGuard],
  exports: [TypeStaffService],
})
export class TypeStaffModule {}
