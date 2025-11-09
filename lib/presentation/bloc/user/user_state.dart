import '../../../data/models/dto/user_dto.dart';
import '../../../data/models/entity/user_entity.dart';
import '../common/paginated_state.dart';

typedef UsersState = PaginatedState<UserEntity, UserQueryDto>;
