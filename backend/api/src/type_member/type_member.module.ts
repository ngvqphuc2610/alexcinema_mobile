import { Module } from '@nestjs/common';
import { TypeMemberService } from './type_member.service';
import { TypeMemberController } from './type_member.controller';

@Module({
  controllers: [TypeMemberController],
  providers: [TypeMemberService],
  exports: [TypeMemberService],
})
export class TypeMemberModule {}
