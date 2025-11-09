import '../../../data/models/dto/movie_dto.dart';
import '../../../data/models/entity/movie_entity.dart';
import '../common/paginated_state.dart';

typedef MoviesState = PaginatedState<MovieEntity, MovieQueryDto>;
