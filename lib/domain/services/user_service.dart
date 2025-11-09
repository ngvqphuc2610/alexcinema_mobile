import '../../data/models/dto/user_dto.dart';
import '../../data/models/entity/pagination_entity.dart';
import '../../data/models/entity/user_entity.dart';
import '../../data/repositories/user_repository.dart';

class UserService {
  const UserService(this._repository);

  final UserRepository _repository;

  Future<PaginatedResponse<UserEntity>> getUsers(UserQueryDto? query) {
    return _repository.getUsers(query);
  }

  Future<UserEntity> getUser(int id) {
    return _repository.getUser(id);
  }

  Future<UserEntity> updateUser(int id, UserUpdateDto dto) {
    return _repository.updateUser(id, dto);
  }

  Future<UserEntity> updatePassword(int id, ChangePasswordDto dto) {
    return _repository.updatePassword(id, dto);
  }

  Future<void> deleteUser(int id) {
    return _repository.deleteUser(id);
  }
}
