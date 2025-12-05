import '../datasources/rag_remote_data_source.dart';
import '../models/dto/rag_search_dto.dart';

class RagRepository {
  final RagRemoteDataSource _remoteDataSource;

  RagRepository(this._remoteDataSource);

  Future<RagSearchResponseDto> search({
    required String query,
    int? limit,
  }) async {
    return await _remoteDataSource.search(query: query, limit: limit);
  }

  /// Hybrid search: vector (semantic) + keyword (exact) for better fuzzy matching
  Future<RagSearchResponseDto> hybridSearch({
    required String query,
    int? limit,
  }) async {
    return await _remoteDataSource.hybridSearch(query: query, limit: limit);
  }

  Future<void> indexMovies() async {
    await _remoteDataSource.indexMovies();
  }

  Future<void> indexShowtimes() async {
    await _remoteDataSource.indexShowtimes();
  }

  Future<void> indexPromotions() async {
    await _remoteDataSource.indexPromotions();
  }

  Future<void> indexCinemas() async {
    await _remoteDataSource.indexCinemas();
  }

  Future<Map<String, dynamic>> indexAll() async {
    return await _remoteDataSource.indexAll();
  }
}
