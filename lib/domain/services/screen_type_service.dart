import '../../data/models/dto/screen_type_dto.dart';
import '../../data/models/entity/screen_type_entity.dart';
import '../../data/repositories/screen_type_repository.dart';

class ScreenTypeService {
  const ScreenTypeService(this._repository);

  final ScreenTypeRepository _repository;

  Future<List<ScreenTypeEntity>> getScreenTypes(ScreenTypeQueryDto? query) {
    return _repository.getScreenTypes(query);
  }

  Future<ScreenTypeEntity> getScreenType(int id) {
    return _repository.getScreenType(id);
  }

  Future<ScreenTypeEntity> createScreenType(ScreenTypePayloadDto dto) {
    return _repository.createScreenType(dto);
  }

  Future<ScreenTypeEntity> updateScreenType(int id, ScreenTypeUpdateDto dto) {
    return _repository.updateScreenType(id, dto);
  }

  Future<void> deleteScreenType(int id) {
    return _repository.deleteScreenType(id);
  }
}
