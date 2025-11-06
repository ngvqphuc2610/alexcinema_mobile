import { Module } from '@nestjs/common';
import { ScreenTypeService } from './screen_type.service';
import { ScreenTypeController } from './screen_type.controller';

@Module({
  controllers: [ScreenTypeController],
  providers: [ScreenTypeService],
  exports: [ScreenTypeService],
})
export class ScreenTypeModule {}
