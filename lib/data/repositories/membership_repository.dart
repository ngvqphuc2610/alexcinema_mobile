import '../datasources/membership_remote_data_source.dart';
import '../models/dto/membership_dto.dart';
import '../models/entity/membership_entity.dart';
import '../models/entity/pagination_entity.dart';

class MembershipRepository {
  const MembershipRepository(this._remoteDataSource);

  final MembershipRemoteDataSource _remoteDataSource;

  Future<PaginatedResponse<MembershipEntity>> getMemberships(MembershipQueryDto? query) {
    return _remoteDataSource.fetchMemberships(query);
  }

  Future<MembershipEntity> getMembership(int id) {
    return _remoteDataSource.fetchMembership(id);
  }
}
