import '../../data/models/dto/movie_dto.dart';
import '../../data/models/entity/movie_entity.dart';
import '../../data/models/entity/pagination_entity.dart';
import '../../data/repositories/movie_repository.dart';

class MovieService {
  const MovieService(this._repository);

  final MovieRepository _repository;

  Future<PaginatedResponse<MovieEntity>> getMovies(MovieQueryDto? query) {
    return _repository.getMovies(query);
  }

  Future<MovieEntity> getMovie(int id) {
    return _repository.getMovie(id);
  }

  Future<MovieEntity> createMovie(MoviePayloadDto dto) {
    return _repository.createMovie(dto);
  }

  Future<MovieEntity> updateMovie(int id, MovieUpdateDto dto) {
    return _repository.updateMovie(id, dto);
  }

  Future<void> deleteMovie(int id) {
    return _repository.deleteMovie(id);
  }
}
