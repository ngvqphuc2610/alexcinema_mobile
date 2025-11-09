import '../models/dto/user_dto.dart';
import '../models/entity/pagination_entity.dart';
import '../models/entity/user_entity.dart';
import '../services/api_client.dart';
import '../services/api_utils.dart';

class UserRemoteDataSource {
  const UserRemoteDataSource(this._client);

  final ApiClient _client;

  Future<PaginatedResponse<UserEntity>> fetchUsers(UserQueryDto? query) async {
    final response = await _client.get(
      'users',
      queryParameters: query?.toQueryParameters(),
    );
    final map = ensureMap(response, errorMessage: 'Invalid users response');
    return PaginatedResponse<UserEntity>.fromJson(
      map,
      UserEntity.fromJson,
    );
  }

  Future<UserEntity> fetchUser(int id) async {
    final response = await _client.get('users/$id');
    final map = ensureMap(response, errorMessage: 'Invalid user response');
    return UserEntity.fromJson(map);
  }

  Future<UserEntity> updateUser(int id, UserUpdateDto payload) async {
    final response = await _client.patch('users/$id', body: payload.toJson());
    final map = ensureMap(response, errorMessage: 'Invalid update user response');
    return UserEntity.fromJson(map);
  }

  Future<UserEntity> changePassword(int id, ChangePasswordDto dto) async {
    final response = await _client.patch('users/$id/password', body: dto.toJson());
    final map = ensureMap(response, errorMessage: 'Invalid password update response');
    return UserEntity.fromJson(map);
  }

  Future<void> deleteUser(int id) async {
    await _client.delete('users/$id');
  }
}
