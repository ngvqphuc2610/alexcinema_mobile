import '../../data/models/dto/entertainment_dto.dart';
import '../../data/models/entity/entertainment_entity.dart';
import '../../data/models/entity/pagination_entity.dart';
import '../../data/repositories/entertainment_repository.dart';

class EntertainmentService {
  const EntertainmentService(this._repository);

  final EntertainmentRepository _repository;

  Future<PaginatedResponse<EntertainmentEntity>> getEntertainment(
    EntertainmentQueryDto? query,
  ) {
    return _repository.getEntertainment(query);
  }

  Future<EntertainmentEntity> getEntertainmentDetail(int id) {
    return _repository.getEntertainmentDetail(id);
  }

  Future<EntertainmentEntity> createEntertainment(
    EntertainmentPayloadDto dto,
  ) {
    return _repository.createEntertainment(dto);
  }

  Future<EntertainmentEntity> updateEntertainment(
    int id,
    EntertainmentUpdateDto dto,
  ) {
    return _repository.updateEntertainment(id, dto);
  }

  Future<void> deleteEntertainment(int id) {
    return _repository.deleteEntertainment(id);
  }
}
