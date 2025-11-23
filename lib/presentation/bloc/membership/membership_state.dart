import '../../../data/models/dto/membership_dto.dart';
import '../../../data/models/entity/membership_entity.dart';
import '../common/paginated_state.dart';

typedef MembershipState = PaginatedState<MembershipEntity, MembershipQueryDto>;
