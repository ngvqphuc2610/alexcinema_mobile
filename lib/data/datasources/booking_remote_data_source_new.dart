import '../models/dto/booking_dto.dart';
import '../services/api_client.dart';
import '../services/api_utils.dart';

class BookingRemoteDataSource {
  const BookingRemoteDataSource(this._client);

  final ApiClient _client;

  Future<BookingResponseDto> createBooking(CreateBookingDto dto) async {
    final response = await _client.post('bookings', body: dto.toJson());
    final map = ensureMap(response, errorMessage: 'Invalid booking response');
    return BookingResponseDto.fromJson(map);
  }
}
