import { Module } from '@nestjs/common';
import { ServeStaticModule } from '@nestjs/serve-static';
import { join } from 'path';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { MoviesModule } from './movies/movies.module';
import { EntertainmentModule } from './entertainment/entertainment.module';
import { MemberModule } from './member/member.module';
import { MembershipModule } from './membership/membership.module';
import { PromotionsModule } from './promotions/promotions.module';
import { SeatModule } from './seat/seat.module';
import { SeatTypeModule } from './seat_type/seat_type.module';
import { SeatLocksModule } from './seat_locks/seat_locks.module';
import { ScreenModule } from './screen/screen.module';
import { ScreenTypeModule } from './screen_type/screen_type.module';
import { ShowtimesModule } from './showtimes/showtimes.module';
import { StaffModule } from './staff/staff.module';
import { TypeStaffModule } from './type_staff/type_staff.module';
import { TypeMemberModule } from './type_member/type_member.module';
import { TypeProductModule } from './type_product/type_product.module';
import { ContactModule } from './contact/contact.module';
import { GenreModule } from './genre/genre.module';
import { GenreMoviesModule } from './genre_movies/genre_movies.module';
import { CinemasModule } from './cinemas/cinemas.module';
import { BookingsModule } from './bookings/bookings.module';
import { DetailBookingModule } from './detail_booking/detail_booking.module';
import { HomepageBannersModule } from './homepage_banners/homepage_banners.module';
import { NewsModule } from './news/news.module';
import { OperationHoursModule } from './operation_hours/operation_hours.module';
import { OrderProductModule } from './order_product/order_product.module';
import { PaymentsModule } from './payments/payments.module';
import { PaymentMethodsModule } from './payment_methods/payment_methods.module';
import { ProductModule } from './product/product.module';
import { ReviewModule } from './review/review.module';
import { TicketModule } from './ticket/ticket.module';
import { TicketSeatConstraintModule } from './ticket_seat_constraint/ticket_seat_constraint.module';
import { TicketTypeModule } from './ticket_type/ticket_type.module';
import { UserLogsModule } from './user_logs/user_logs.module';
import { UploadModule } from './upload/upload.module';
import { OtpModule } from './otp/otp.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      expandVariables: true,
      envFilePath: [`.env.${process.env.NODE_ENV ?? 'development'}`, '.env'],
    }),
    ServeStaticModule.forRoot({
      rootPath: join(__dirname, '..', '..', '..', 'assets', 'upload'),
      serveRoot: '/uploads',
    }),
    PrismaModule,
    AuthModule,
    UsersModule,
    MoviesModule,
    EntertainmentModule,
    MemberModule,
    MembershipModule,
    PromotionsModule,
    SeatModule,
    SeatTypeModule,
    SeatLocksModule,
    ScreenModule,
    ScreenTypeModule,
    ShowtimesModule,
    StaffModule,
    TypeStaffModule,
    TypeMemberModule,
    TypeProductModule,
    ContactModule,
    GenreModule,
    GenreMoviesModule,
    CinemasModule,
    BookingsModule,
    DetailBookingModule,
    HomepageBannersModule,
    NewsModule,
    OperationHoursModule,
    OrderProductModule,
    PaymentsModule,
    PaymentMethodsModule,
    ProductModule,
    ReviewModule,
    TicketModule,
    TicketSeatConstraintModule,
    TicketTypeModule,
    UserLogsModule,
    UploadModule,
    OtpModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule { }
