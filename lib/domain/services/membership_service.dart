import '../../data/models/dto/membership_dto.dart';
import '../../data/models/entity/membership_entity.dart';
import '../../data/models/entity/pagination_entity.dart';
import '../../data/repositories/membership_repository.dart';

class MembershipService {
  const MembershipService(this._repository);

  final MembershipRepository _repository;

  Future<PaginatedResponse<MembershipEntity>> getMemberships(MembershipQueryDto? query) {
    return _repository.getMemberships(query);
  }

  Future<MembershipEntity> getMembership(int id) {
    return _repository.getMembership(id);
  }
}
