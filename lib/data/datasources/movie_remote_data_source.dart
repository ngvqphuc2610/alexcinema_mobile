import '../models/dto/movie_dto.dart';
import '../models/entity/movie_entity.dart';
import '../models/entity/pagination_entity.dart';
import '../services/api_client.dart';
import '../services/api_utils.dart';

class MovieRemoteDataSource {
  const MovieRemoteDataSource(this._client);

  final ApiClient _client;

  Future<PaginatedResponse<MovieEntity>> fetchMovies(MovieQueryDto? query) async {
    final response = await _client.get(
      'movies',
      queryParameters: query?.toQueryParameters(),
    );
    final map = ensureMap(response, errorMessage: 'Invalid movies response');
    return PaginatedResponse<MovieEntity>.fromJson(map, MovieEntity.fromJson);
  }

  Future<MovieEntity> fetchMovie(int id) async {
    final response = await _client.get('movies/$id');
    final map = ensureMap(response, errorMessage: 'Invalid movie response');
    return MovieEntity.fromJson(map);
  }

  Future<MovieEntity> createMovie(MoviePayloadDto payload) async {
    final response = await _client.post('movies', body: payload.toJson());
    final map = ensureMap(response, errorMessage: 'Invalid create movie response');
    return MovieEntity.fromJson(map);
  }

  Future<MovieEntity> updateMovie(int id, MovieUpdateDto payload) async {
    final response = await _client.patch('movies/$id', body: payload.toJson());
    final map = ensureMap(response, errorMessage: 'Invalid update movie response');
    return MovieEntity.fromJson(map);
  }

  Future<void> deleteMovie(int id) async {
    await _client.delete('movies/$id');
  }
}
