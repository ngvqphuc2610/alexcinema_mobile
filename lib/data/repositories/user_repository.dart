import '../datasources/user_remote_data_source.dart';
import '../models/dto/user_dto.dart';
import '../models/entity/pagination_entity.dart';
import '../models/entity/user_entity.dart';

class UserRepository {
  const UserRepository(this._remoteDataSource);

  final UserRemoteDataSource _remoteDataSource;

  Future<PaginatedResponse<UserEntity>> getUsers(UserQueryDto? query) {
    return _remoteDataSource.fetchUsers(query);
  }

  Future<UserEntity> getUser(int id) {
    return _remoteDataSource.fetchUser(id);
  }

  Future<UserEntity> updateUser(int id, UserUpdateDto dto) {
    return _remoteDataSource.updateUser(id, dto);
  }

  Future<UserEntity> updatePassword(int id, ChangePasswordDto dto) {
    return _remoteDataSource.changePassword(id, dto);
  }

  Future<void> deleteUser(int id) {
    return _remoteDataSource.deleteUser(id);
  }
}
