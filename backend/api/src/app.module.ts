import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from './prisma/prisma.module';
import { UsersModule } from './users/users.module';
import { AuthModule } from './auth/auth.module';
import { MoviesModule } from './movies/movies.module';
import { EntertainmentModule } from './entertainment/entertainment.module';
import { MemberModule } from './member/member.module';
import { MembershipModule } from './membership/membership.module';
import { PromotionsModule } from './promotions/promotions.module';
import { SeatModule } from './seat/seat.module';
import { ScreenModule } from './screen/screen.module';
import { ShowtimesModule } from './showtimes/showtimes.module';
import { StaffModule } from './staff/staff.module';
import { TypeStaffModule } from './type_staff/type_staff.module';
import { ContactModule } from './contact/contact.module';
import { GenreModule } from './genre/genre.module';
import { GenreMoviesModule } from './genre_movies/genre_movies.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    PrismaModule,
    UsersModule,
    AuthModule,
    MoviesModule,
    EntertainmentModule,
    MemberModule,
    MembershipModule,
    PromotionsModule,
    SeatModule,
    ScreenModule,
    ShowtimesModule,
    StaffModule,
    TypeStaffModule,
    ContactModule,
    GenreModule,
    GenreMoviesModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
