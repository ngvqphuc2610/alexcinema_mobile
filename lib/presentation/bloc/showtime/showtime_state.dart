import '../../../data/models/dto/showtime_dto.dart';
import '../../../data/models/entity/showtime_entity.dart';
import '../common/paginated_state.dart';

typedef ShowtimeState = PaginatedState<ShowtimeEntity, ShowtimeQueryDto>;
