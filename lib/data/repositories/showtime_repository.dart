import '../datasources/showtime_remote_data_source.dart';
import '../models/dto/showtime_dto.dart';
import '../models/entity/pagination_entity.dart';
import '../models/entity/showtime_entity.dart';

class ShowtimeRepository {
  const ShowtimeRepository(this._remoteDataSource);

  final ShowtimeRemoteDataSource _remoteDataSource;

  Future<PaginatedResponse<ShowtimeEntity>> getShowtimes(
    ShowtimeQueryDto? query,
  ) {
    return _remoteDataSource.fetchShowtimes(query);
  }

  Future<ShowtimeEntity> getShowtime(int id) {
    return _remoteDataSource.fetchShowtime(id);
  }

  Future<ShowtimeEntity> createShowtime(ShowtimePayloadDto payload) {
    return _remoteDataSource.createShowtime(payload);
  }

  Future<ShowtimeEntity> updateShowtime(
    int id,
    ShowtimeUpdateDto payload,
  ) {
    return _remoteDataSource.updateShowtime(id, payload);
  }

  Future<void> deleteShowtime(int id) {
    return _remoteDataSource.deleteShowtime(id);
  }
}
