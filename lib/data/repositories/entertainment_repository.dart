import '../datasources/entertainment_remote_data_source.dart';
import '../models/dto/entertainment_dto.dart';
import '../models/entity/entertainment_entity.dart';
import '../models/entity/pagination_entity.dart';

class EntertainmentRepository {
  const EntertainmentRepository(this._remoteDataSource);

  final EntertainmentRemoteDataSource _remoteDataSource;

  Future<PaginatedResponse<EntertainmentEntity>> getEntertainment(
    EntertainmentQueryDto? query,
  ) {
    return _remoteDataSource.fetchEntertainment(query);
  }

  Future<EntertainmentEntity> getEntertainmentDetail(int id) {
    return _remoteDataSource.fetchDetail(id);
  }

  Future<EntertainmentEntity> createEntertainment(
    EntertainmentPayloadDto payload,
  ) {
    return _remoteDataSource.createEntertainment(payload);
  }

  Future<EntertainmentEntity> updateEntertainment(
    int id,
    EntertainmentUpdateDto payload,
  ) {
    return _remoteDataSource.updateEntertainment(id, payload);
  }

  Future<void> deleteEntertainment(int id) {
    return _remoteDataSource.deleteEntertainment(id);
  }
}
