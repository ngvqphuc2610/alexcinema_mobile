import '../models/dto/membership_dto.dart';
import '../models/entity/membership_entity.dart';
import '../models/entity/pagination_entity.dart';
import '../services/api_client.dart';
import '../services/api_utils.dart';

class MembershipRemoteDataSource {
  const MembershipRemoteDataSource(this._client);

  final ApiClient _client;

  Future<PaginatedResponse<MembershipEntity>> fetchMemberships(MembershipQueryDto? query) async {
    final response = await _client.get(
      'memberships',
      queryParameters: query?.toQueryParameters(),
    );
    final map = ensureMap(response, errorMessage: 'Invalid membership response');
    return PaginatedResponse<MembershipEntity>.fromJson(map, MembershipEntity.fromJson);
  }

  Future<MembershipEntity> fetchMembership(int id) async {
    final response = await _client.get('memberships/$id');
    final map = ensureMap(response, errorMessage: 'Invalid membership detail response');
    return MembershipEntity.fromJson(map);
  }
}
