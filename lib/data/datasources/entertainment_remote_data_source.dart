import '../models/dto/entertainment_dto.dart';
import '../models/entity/entertainment_entity.dart';
import '../models/entity/pagination_entity.dart';
import '../services/api_client.dart';
import '../services/api_utils.dart';

class EntertainmentRemoteDataSource {
  const EntertainmentRemoteDataSource(this._client);

  final ApiClient _client;

  Future<PaginatedResponse<EntertainmentEntity>> fetchEntertainment(
    EntertainmentQueryDto? query,
  ) async {
    final response = await _client.get(
      'entertainment',
      queryParameters: query?.toQueryParameters(),
    );
    final map = ensureMap(response, errorMessage: 'Invalid entertainment response');
    return PaginatedResponse<EntertainmentEntity>.fromJson(
      map,
      EntertainmentEntity.fromJson,
    );
  }

  Future<EntertainmentEntity> fetchDetail(int id) async {
    final response = await _client.get('entertainment/$id');
    final map = ensureMap(response, errorMessage: 'Invalid entertainment detail response');
    return EntertainmentEntity.fromJson(map);
  }

  Future<EntertainmentEntity> createEntertainment(
    EntertainmentPayloadDto payload,
  ) async {
    final response = await _client.post('entertainment', body: payload.toJson());
    final map = ensureMap(response, errorMessage: 'Invalid creation response');
    return EntertainmentEntity.fromJson(map);
  }

  Future<EntertainmentEntity> updateEntertainment(
    int id,
    EntertainmentUpdateDto payload,
  ) async {
    final response = await _client.patch('entertainment/$id', body: payload.toJson());
    final map = ensureMap(response, errorMessage: 'Invalid update response');
    return EntertainmentEntity.fromJson(map);
  }

  Future<void> deleteEntertainment(int id) async {
    await _client.delete('entertainment/$id');
  }
}
