import '../models/dto/booking_dto.dart';
import '../services/api_client.dart';
import '../services/api_utils.dart';

abstract class BookingRemoteDataSource {
  Future<BookingResponseDto> createBooking(CreateBookingDto dto);
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  const BookingRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<BookingResponseDto> createBooking(CreateBookingDto dto) async {
    try {
      final response = await _client.post('bookings', body: dto.toJson());
      final data = ensureMap(response);
      print('Booking API response: $data'); // Debug log
      return BookingResponseDto.fromJson(data);
    } catch (e) {
      print('Error creating booking: $e');
      rethrow;
    }
  }
}
