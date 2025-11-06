import { Controller } from '@nestjs/common';
import { ScreenTypeService } from './screen_type.service';

@Controller('screen-type')
export class ScreenTypeController {
  constructor(private readonly screenTypeService: ScreenTypeService) {}
}
