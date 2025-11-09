import '../datasources/promotion_remote_data_source.dart';
import '../models/dto/promotion_dto.dart';
import '../models/entity/pagination_entity.dart';
import '../models/entity/promotion_entity.dart';

class PromotionRepository {
  const PromotionRepository(this._remoteDataSource);

  final PromotionRemoteDataSource _remoteDataSource;

  Future<PaginatedResponse<PromotionEntity>> getPromotions(
    PromotionQueryDto? query,
  ) {
    return _remoteDataSource.fetchPromotions(query);
  }

  Future<PromotionEntity> getPromotion(int id) {
    return _remoteDataSource.fetchPromotion(id);
  }

  Future<PromotionEntity> createPromotion(PromotionPayloadDto payload) {
    return _remoteDataSource.createPromotion(payload);
  }

  Future<PromotionEntity> updatePromotion(
    int id,
    PromotionPayloadDto payload,
  ) {
    return _remoteDataSource.updatePromotion(id, payload);
  }

  Future<void> deletePromotion(int id) {
    return _remoteDataSource.deletePromotion(id);
  }
}
