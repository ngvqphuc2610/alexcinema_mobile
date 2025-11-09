import '../../data/models/dto/showtime_dto.dart';
import '../../data/models/entity/pagination_entity.dart';
import '../../data/models/entity/showtime_entity.dart';
import '../../data/repositories/showtime_repository.dart';

class ShowtimeService {
  const ShowtimeService(this._repository);

  final ShowtimeRepository _repository;

  Future<PaginatedResponse<ShowtimeEntity>> getShowtimes(
    ShowtimeQueryDto? query,
  ) {
    return _repository.getShowtimes(query);
  }

  Future<ShowtimeEntity> getShowtime(int id) {
    return _repository.getShowtime(id);
  }

  Future<ShowtimeEntity> createShowtime(ShowtimePayloadDto dto) {
    return _repository.createShowtime(dto);
  }

  Future<ShowtimeEntity> updateShowtime(int id, ShowtimeUpdateDto dto) {
    return _repository.updateShowtime(id, dto);
  }

  Future<void> deleteShowtime(int id) {
    return _repository.deleteShowtime(id);
  }
}
