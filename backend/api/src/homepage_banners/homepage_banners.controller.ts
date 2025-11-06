import { Controller } from '@nestjs/common';
import { HomepageBannersService } from './homepage_banners.service';

@Controller('homepage-banners')
export class HomepageBannersController {
  constructor(private readonly homepageBannersService: HomepageBannersService) {}
}
