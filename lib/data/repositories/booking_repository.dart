import '../datasources/booking_remote_data_source.dart';
import '../models/dto/booking_dto.dart';

class BookingRepository {
  const BookingRepository(this._remoteDataSource);

  final BookingRemoteDataSource _remoteDataSource;

  Future<BookingResponseDto> createBooking(CreateBookingDto dto) {
    return _remoteDataSource.createBooking(dto);
  }
}
