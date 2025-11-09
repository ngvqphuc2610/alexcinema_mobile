import '../models/dto/showtime_dto.dart';
import '../models/entity/pagination_entity.dart';
import '../models/entity/showtime_entity.dart';
import '../services/api_client.dart';
import '../services/api_utils.dart';

class ShowtimeRemoteDataSource {
  const ShowtimeRemoteDataSource(this._client);

  final ApiClient _client;

  Future<PaginatedResponse<ShowtimeEntity>> fetchShowtimes(
    ShowtimeQueryDto? query,
  ) async {
    final response = await _client.get(
      'showtimes',
      queryParameters: query?.toQueryParameters(),
    );
    final map = ensureMap(response, errorMessage: 'Invalid showtimes response');
    return PaginatedResponse<ShowtimeEntity>.fromJson(
      map,
      ShowtimeEntity.fromJson,
    );
  }

  Future<ShowtimeEntity> fetchShowtime(int id) async {
    final response = await _client.get('showtimes/$id');
    final map = ensureMap(response, errorMessage: 'Invalid showtime response');
    return ShowtimeEntity.fromJson(map);
  }

  Future<ShowtimeEntity> createShowtime(ShowtimePayloadDto payload) async {
    final response = await _client.post('showtimes', body: payload.toJson());
    final map = ensureMap(response, errorMessage: 'Invalid create showtime response');
    return ShowtimeEntity.fromJson(map);
  }

  Future<ShowtimeEntity> updateShowtime(
    int id,
    ShowtimeUpdateDto payload,
  ) async {
    final response = await _client.patch('showtimes/$id', body: payload.toJson());
    final map = ensureMap(response, errorMessage: 'Invalid update showtime response');
    return ShowtimeEntity.fromJson(map);
  }

  Future<void> deleteShowtime(int id) async {
    await _client.delete('showtimes/$id');
  }
}
