import '../../../data/models/dto/cinema_dto.dart';
import '../../../data/models/entity/cinemas_entity.dart';
import '../common/paginated_state.dart';

typedef CinemasState = PaginatedState<CinemaEntity, CinemaQueryDto>;
