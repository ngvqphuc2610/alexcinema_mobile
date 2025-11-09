import '../../../data/models/dto/entertainment_dto.dart';
import '../../../data/models/entity/entertainment_entity.dart';
import '../common/paginated_state.dart';

typedef EntertainmentState = PaginatedState<EntertainmentEntity, EntertainmentQueryDto>;
