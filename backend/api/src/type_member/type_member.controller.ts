import { Controller } from '@nestjs/common';
import { TypeMemberService } from './type_member.service';

@Controller('type-member')
export class TypeMemberController {
  constructor(private readonly typeMemberService: TypeMemberService) {}
}
