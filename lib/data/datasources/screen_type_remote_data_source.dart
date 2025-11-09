import '../models/dto/screen_type_dto.dart';
import '../models/entity/screen_type_entity.dart';
import '../services/api_client.dart';
import '../services/api_utils.dart';

class ScreenTypeRemoteDataSource {
  const ScreenTypeRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<ScreenTypeEntity>> fetchScreenTypes(ScreenTypeQueryDto? query) async {
    final response = await _client.get(
      'screen-type',
      queryParameters: query?.toQueryParameters(),
    );
    final list = ensureList(response, errorMessage: 'Invalid screen type response');
    return list.map(ScreenTypeEntity.fromJson).toList(growable: false);
  }

  Future<ScreenTypeEntity> fetchScreenType(int id) async {
    final response = await _client.get('screen-type/$id');
    final map = ensureMap(response, errorMessage: 'Invalid screen type detail response');
    return ScreenTypeEntity.fromJson(map);
  }

  Future<ScreenTypeEntity> createScreenType(ScreenTypePayloadDto payload) async {
    final response = await _client.post('screen-type', body: payload.toJson());
    final map = ensureMap(response, errorMessage: 'Invalid create screen type response');
    return ScreenTypeEntity.fromJson(map);
  }

  Future<ScreenTypeEntity> updateScreenType(
    int id,
    ScreenTypeUpdateDto payload,
  ) async {
    final response = await _client.patch('screen-type/$id', body: payload.toJson());
    final map = ensureMap(response, errorMessage: 'Invalid update screen type response');
    return ScreenTypeEntity.fromJson(map);
  }

  Future<void> deleteScreenType(int id) async {
    await _client.delete('screen-type/$id');
  }
}
