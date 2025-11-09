import '../models/dto/promotion_dto.dart';
import '../models/entity/pagination_entity.dart';
import '../models/entity/promotion_entity.dart';
import '../services/api_client.dart';
import '../services/api_utils.dart';

class PromotionRemoteDataSource {
  const PromotionRemoteDataSource(this._client);

  final ApiClient _client;

  Future<PaginatedResponse<PromotionEntity>> fetchPromotions(
    PromotionQueryDto? query,
  ) async {
    final response = await _client.get(
      'promotions',
      queryParameters: query?.toQueryParameters(),
    );
    final map = ensureMap(response, errorMessage: 'Invalid promotions response');
    return PaginatedResponse<PromotionEntity>.fromJson(
      map,
      PromotionEntity.fromJson,
    );
  }

  Future<PromotionEntity> fetchPromotion(int id) async {
    final response = await _client.get('promotions/$id');
    final map = ensureMap(response, errorMessage: 'Invalid promotion response');
    return PromotionEntity.fromJson(map);
  }

  Future<PromotionEntity> createPromotion(PromotionPayloadDto payload) async {
    final response = await _client.post('promotions', body: payload.toJson());
    final map = ensureMap(response, errorMessage: 'Invalid creation response');
    return PromotionEntity.fromJson(map);
  }

  Future<PromotionEntity> updatePromotion(
    int id,
    PromotionPayloadDto payload,
  ) async {
    final response = await _client.patch('promotions/$id', body: payload.toJson());
    final map = ensureMap(response, errorMessage: 'Invalid update response');
    return PromotionEntity.fromJson(map);
  }

  Future<void> deletePromotion(int id) async {
    await _client.delete('promotions/$id');
  }
}
