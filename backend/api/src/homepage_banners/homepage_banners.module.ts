import { Module } from '@nestjs/common';
import { HomepageBannersService } from './homepage_banners.service';
import { HomepageBannersController } from './homepage_banners.controller';

@Module({
  controllers: [HomepageBannersController],
  providers: [HomepageBannersService],
  exports: [HomepageBannersService],
})
export class HomepageBannersModule {}
