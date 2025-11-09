import '../datasources/screen_type_remote_data_source.dart';
import '../models/dto/screen_type_dto.dart';
import '../models/entity/screen_type_entity.dart';

class ScreenTypeRepository {
  const ScreenTypeRepository(this._remoteDataSource);

  final ScreenTypeRemoteDataSource _remoteDataSource;

  Future<List<ScreenTypeEntity>> getScreenTypes(ScreenTypeQueryDto? query) {
    return _remoteDataSource.fetchScreenTypes(query);
  }

  Future<ScreenTypeEntity> getScreenType(int id) {
    return _remoteDataSource.fetchScreenType(id);
  }

  Future<ScreenTypeEntity> createScreenType(ScreenTypePayloadDto dto) {
    return _remoteDataSource.createScreenType(dto);
  }

  Future<ScreenTypeEntity> updateScreenType(int id, ScreenTypeUpdateDto dto) {
    return _remoteDataSource.updateScreenType(id, dto);
  }

  Future<void> deleteScreenType(int id) {
    return _remoteDataSource.deleteScreenType(id);
  }
}
