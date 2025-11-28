import '../models/entity/pagination_entity.dart';
import '../models/entity/seat_entity.dart';
import 'api_client.dart';

class SeatService {
  final ApiClient _apiClient;

  SeatService(this._apiClient);

  /// Fetch seats for a specific screen
  Future<List<SeatEntity>> getSeatsForScreen(int screenId) async {
    try {
      final response = await _apiClient.get(
        '/seats',
        queryParameters: {
          'screenId': screenId,
          'limit': 500, // Get all seats for the screen
        },
      );

      final pagination = PaginatedResponse<SeatEntity>.fromJson(
        response as Map<String, dynamic>,
        (json) => SeatEntity.fromJson(json),
      );

      return pagination.items;
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch booked seats for a specific showtime
  Future<Set<int>> getBookedSeatsForShowtime(int showtimeId) async {
    try {
      // This endpoint should return seat IDs that are booked or locked for this showtime
      final response = await _apiClient.get(
        '/showtimes/$showtimeId/booked-seats',
      );

      print('🎫 Booked seats response for showtime $showtimeId: $response');

      if (response == null) {
        print('⚠️ Response is null');
        return {};
      }

      if (response is! List) {
        print('⚠️ Response is not a List, type: ${response.runtimeType}');
        return {};
      }

      final List<dynamic> seatIds = response as List<dynamic>;
      final bookedSeatIds = seatIds.map((id) => id as int).toSet();

      print('✅ Booked seat IDs: $bookedSeatIds');

      return bookedSeatIds;
    } catch (e, stackTrace) {
      // If endpoint doesn't exist or error, return empty set
      print('❌ Error fetching booked seats: $e');
      print('Stack trace: $stackTrace');
      return {};
    }
  }
}
