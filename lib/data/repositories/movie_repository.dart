import '../datasources/movie_remote_data_source.dart';
import '../models/dto/movie_dto.dart';
import '../models/entity/movie_entity.dart';
import '../models/entity/pagination_entity.dart';

class MovieRepository {
  const MovieRepository(this._remoteDataSource);

  final MovieRemoteDataSource _remoteDataSource;

  Future<PaginatedResponse<MovieEntity>> getMovies(MovieQueryDto? query) {
    return _remoteDataSource.fetchMovies(query);
  }

  Future<MovieEntity> getMovie(int id) {
    return _remoteDataSource.fetchMovie(id);
  }

  Future<MovieEntity> createMovie(MoviePayloadDto dto) {
    return _remoteDataSource.createMovie(dto);
  }

  Future<MovieEntity> updateMovie(int id, MovieUpdateDto dto) {
    return _remoteDataSource.updateMovie(id, dto);
  }

  Future<void> deleteMovie(int id) {
    return _remoteDataSource.deleteMovie(id);
  }
}
