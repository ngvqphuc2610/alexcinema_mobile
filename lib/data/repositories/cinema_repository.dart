import '../datasources/cinema_remote_data_source.dart';
import '../models/dto/cinema_dto.dart';
import '../models/entity/cinemas_entity.dart';
import '../models/entity/pagination_entity.dart';

class CinemaRepository {
  const CinemaRepository(this._remoteDataSource);

  final CinemaRemoteDataSource _remoteDataSource;

  Future<PaginatedResponse<CinemaEntity>> getCinemas(CinemaQueryDto? query) {
    return _remoteDataSource.fetchCinemas(query);
  }

  Future<CinemaEntity> getCinema(int id) {
    return _remoteDataSource.fetchCinema(id);
  }

  Future<CinemaEntity> createCinema(CinemaPayloadDto payload) {
    return _remoteDataSource.createCinema(payload);
  }

  Future<CinemaEntity> updateCinema(int id, CinemaUpdateDto payload) {
    return _remoteDataSource.updateCinema(id, payload);
  }

  Future<void> deleteCinema(int id) {
    return _remoteDataSource.deleteCinema(id);
  }
}
