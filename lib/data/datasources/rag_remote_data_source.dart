import '../models/dto/rag_search_dto.dart';
import '../services/api_client.dart';

class RagRemoteDataSource {
  final ApiClient _apiClient;

  RagRemoteDataSource(this._apiClient);

  /// Search for relevant context using RAG
  Future<RagSearchResponseDto> search({
    required String query,
    int? limit,
  }) async {
    final requestDto = RagSearchRequestDto(query: query, limit: limit);
    print('🔍 [RagRemoteDataSource] Sending request: ${requestDto.toJson()}');

    try {
      final response = await _apiClient.post(
        'rag/search',
        body: requestDto.toJson(),
      );

      print('🔍 [RagRemoteDataSource] Response type: ${response.runtimeType}');
      print('🔍 [RagRemoteDataSource] Response: $response');

      final result = RagSearchResponseDto.fromJson(response);
      print('✅ [RagRemoteDataSource] Parsed successfully');
      return result;
    } catch (e) {
      print('❌ [RagRemoteDataSource] Error: $e');
      rethrow;
    }
  }

  /// Hybrid search: combines vector (semantic) + keyword (exact) search
  /// Better for fuzzy matching like "doraamon" → "Doraemon"
  Future<RagSearchResponseDto> hybridSearch({
    required String query,
    int? limit,
  }) async {
    final requestDto = RagSearchRequestDto(query: query, limit: limit);
    print('🔍🔍 [RagRemoteDataSource] Hybrid search request: ${requestDto.toJson()}');

    try {
      final response = await _apiClient.post(
        'rag/hybrid-search',
        body: requestDto.toJson(),
      );

      print('✅ [RagRemoteDataSource] Hybrid search response received');
      final result = RagSearchResponseDto.fromJson(response);
      return result;
    } catch (e) {
      print('❌ [RagRemoteDataSource] Hybrid search error: $e');
      rethrow;
    }
  }

  /// Trigger indexing of movies
  Future<void> indexMovies() async {
    await _apiClient.post('rag/index/movies');
  }

  /// Trigger indexing of showtimes
  Future<void> indexShowtimes() async {
    await _apiClient.post('rag/index/showtimes');
  }

  /// Trigger indexing of promotions
  Future<void> indexPromotions() async {
    await _apiClient.post('rag/index/promotions');
  }

  /// Trigger indexing of cinemas
  Future<void> indexCinemas() async {
    await _apiClient.post('rag/index/cinemas');
  }

  /// Trigger indexing of all data
  Future<Map<String, dynamic>> indexAll() async {
    final response = await _apiClient.post('rag/index/all');
    return response['data'] as Map<String, dynamic>;
  }
}
