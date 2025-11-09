import '../models/dto/cinema_dto.dart';
import '../models/entity/cinemas_entity.dart';
import '../models/entity/pagination_entity.dart';
import '../services/api_client.dart';
import '../services/api_utils.dart';

class CinemaRemoteDataSource {
  const CinemaRemoteDataSource(this._client);

  final ApiClient _client;

  Future<PaginatedResponse<CinemaEntity>> fetchCinemas(
    CinemaQueryDto? query,
  ) async {
    final response = await _client.get(
      'cinemas',
      queryParameters: query?.toQueryParameters(),
    );
    final map = ensureMap(response, errorMessage: 'Invalid cinemas response');
    return PaginatedResponse<CinemaEntity>.fromJson(
      map,
      CinemaEntity.fromJson,
    );
  }

  Future<CinemaEntity> fetchCinema(int id) async {
    final response = await _client.get('cinemas/$id');
    final map = ensureMap(response, errorMessage: 'Invalid cinema response');
    return CinemaEntity.fromJson(map);
  }

  Future<CinemaEntity> createCinema(CinemaPayloadDto payload) async {
    final response = await _client.post('cinemas', body: payload.toJson());
    final map = ensureMap(response, errorMessage: 'Invalid create cinema response');
    return CinemaEntity.fromJson(map);
  }

  Future<CinemaEntity> updateCinema(int id, CinemaUpdateDto payload) async {
    final response = await _client.patch('cinemas/$id', body: payload.toJson());
    final map = ensureMap(response, errorMessage: 'Invalid update cinema response');
    return CinemaEntity.fromJson(map);
  }

  Future<void> deleteCinema(int id) async {
    await _client.delete('cinemas/$id');
  }
}
