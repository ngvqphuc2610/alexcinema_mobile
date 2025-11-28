import '../../data/models/dto/booking_dto.dart';
import '../../data/repositories/booking_repository.dart';

class BookingService {
  const BookingService(this._repository);

  final BookingRepository _repository;

  Future<BookingResponseDto> createBooking({
    required int showtimeId,
    required double totalAmount,
    int? userId,
    List<BookingSeatDto>? seats,
    List<BookingProductDto>? products,
  }) {
    return _repository.createBooking(
      CreateBookingDto(
        idShowtime: showtimeId,
        totalAmount: totalAmount,
        idUsers: userId,
        seats: seats,
        products: products,
      ),
    );
  }
}
