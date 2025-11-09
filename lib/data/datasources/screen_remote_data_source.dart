import '../models/dto/screen_dto.dart';
import '../models/entity/pagination_entity.dart';
import '../models/entity/screen_entity.dart';
import '../services/api_client.dart';
import '../services/api_utils.dart';

class ScreenRemoteDataSource {
  const ScreenRemoteDataSource(this._client);

  final ApiClient _client;

  Future<PaginatedResponse<ScreenEntity>> fetchScreens(
    ScreenQueryDto? query,
  ) async {
    final response = await _client.get(
      'screens',
      queryParameters: query?.toQueryParameters(),
    );
    final map = ensureMap(response, errorMessage: 'Invalid screens response');
    return PaginatedResponse<ScreenEntity>.fromJson(
      map,
      ScreenEntity.fromJson,
    );
  }

  Future<ScreenEntity> fetchScreen(int id) async {
    final response = await _client.get('screens/$id');
    final map = ensureMap(response, errorMessage: 'Invalid screen response');
    return ScreenEntity.fromJson(map);
  }

  Future<ScreenEntity> createScreen(ScreenPayloadDto payload) async {
    final response = await _client.post('screens', body: payload.toJson());
    final map = ensureMap(response, errorMessage: 'Invalid create screen response');
    return ScreenEntity.fromJson(map);
  }

  Future<ScreenEntity> updateScreen(
    int id,
    ScreenUpdateDto payload,
  ) async {
    final response = await _client.patch('screens/$id', body: payload.toJson());
    final map = ensureMap(response, errorMessage: 'Invalid update screen response');
    return ScreenEntity.fromJson(map);
  }

  Future<void> deleteScreen(int id) async {
    await _client.delete('screens/$id');
  }
}
