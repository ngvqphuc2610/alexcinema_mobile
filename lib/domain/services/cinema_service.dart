import '../../data/models/dto/cinema_dto.dart';
import '../../data/models/entity/cinemas_entity.dart';
import '../../data/models/entity/pagination_entity.dart';
import '../../data/repositories/cinema_repository.dart';

class CinemaService {
  const CinemaService(this._repository);

  final CinemaRepository _repository;

  Future<PaginatedResponse<CinemaEntity>> getCinemas(CinemaQueryDto? query) {
    return _repository.getCinemas(query);
  }

  Future<CinemaEntity> getCinema(int id) {
    return _repository.getCinema(id);
  }

  Future<CinemaEntity> createCinema(CinemaPayloadDto dto) {
    return _repository.createCinema(dto);
  }

  Future<CinemaEntity> updateCinema(int id, CinemaUpdateDto dto) {
    return _repository.updateCinema(id, dto);
  }

  Future<void> deleteCinema(int id) {
    return _repository.deleteCinema(id);
  }
}
