import '../../data/models/dto/screen_dto.dart';
import '../../data/models/entity/pagination_entity.dart';
import '../../data/models/entity/screen_entity.dart';
import '../../data/repositories/screen_repository.dart';

class ScreenService {
  const ScreenService(this._repository);

  final ScreenRepository _repository;

  Future<PaginatedResponse<ScreenEntity>> getScreens(ScreenQueryDto? query) {
    return _repository.getScreens(query);
  }

  Future<ScreenEntity> getScreen(int id) {
    return _repository.getScreen(id);
  }

  Future<ScreenEntity> createScreen(ScreenPayloadDto dto) {
    return _repository.createScreen(dto);
  }

  Future<ScreenEntity> updateScreen(int id, ScreenUpdateDto dto) {
    return _repository.updateScreen(id, dto);
  }

  Future<void> deleteScreen(int id) {
    return _repository.deleteScreen(id);
  }
}
