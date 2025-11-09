import '../../data/models/dto/promotion_dto.dart';
import '../../data/models/entity/pagination_entity.dart';
import '../../data/models/entity/promotion_entity.dart';
import '../../data/repositories/promotion_repository.dart';

class PromotionService {
  const PromotionService(this._repository);

  final PromotionRepository _repository;

  Future<PaginatedResponse<PromotionEntity>> getPromotions(
    PromotionQueryDto? query,
  ) {
    return _repository.getPromotions(query);
  }

  Future<PromotionEntity> getPromotion(int id) {
    return _repository.getPromotion(id);
  }

  Future<PromotionEntity> createPromotion(PromotionPayloadDto dto) {
    return _repository.createPromotion(dto);
  }

  Future<PromotionEntity> updatePromotion(
    int id,
    PromotionPayloadDto dto,
  ) {
    return _repository.updatePromotion(id, dto);
  }

  Future<void> deletePromotion(int id) {
    return _repository.deletePromotion(id);
  }
}
