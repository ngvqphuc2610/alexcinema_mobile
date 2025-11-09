import '../datasources/screen_remote_data_source.dart';
import '../models/dto/screen_dto.dart';
import '../models/entity/pagination_entity.dart';
import '../models/entity/screen_entity.dart';

class ScreenRepository {
  const ScreenRepository(this._remoteDataSource);

  final ScreenRemoteDataSource _remoteDataSource;

  Future<PaginatedResponse<ScreenEntity>> getScreens(ScreenQueryDto? query) {
    return _remoteDataSource.fetchScreens(query);
  }

  Future<ScreenEntity> getScreen(int id) {
    return _remoteDataSource.fetchScreen(id);
  }

  Future<ScreenEntity> createScreen(ScreenPayloadDto payload) {
    return _remoteDataSource.createScreen(payload);
  }

  Future<ScreenEntity> updateScreen(int id, ScreenUpdateDto payload) {
    return _remoteDataSource.updateScreen(id, payload);
  }

  Future<void> deleteScreen(int id) {
    return _remoteDataSource.deleteScreen(id);
  }
}
