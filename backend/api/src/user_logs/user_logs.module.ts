import { Module } from '@nestjs/common';
import { UserLogsService } from './user_logs.service';
import { UserLogsController } from './user_logs.controller';

@Module({
  controllers: [UserLogsController],
  providers: [UserLogsService],
  exports: [UserLogsService],
})
export class UserLogsModule {}
