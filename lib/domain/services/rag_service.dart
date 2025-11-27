import '../../data/repositories/rag_repository.dart';
import '../../data/models/dto/rag_search_dto.dart';

class RagService {
  final RagRepository _repository;

  RagService(this._repository);

  /// Search for relevant context based on user query
  /// Returns augmented context to be injected into Gemini prompt
  Future<RagSearchData?> search(String query, {int limit = 3}) async {
    try {
      print('🔍 [RagService] Searching for: $query (limit: $limit)');
      final response = await _repository.search(query: query, limit: limit);
      print('🔍 [RagService] Response success: ${response.success}');

      if (response.success) {
        print('✅ [RagService] Context length: ${response.data.context.length}');
        print('✅ [RagService] Sources count: ${response.data.sources.length}');
        return response.data;
      }
      print('⚠️ [RagService] Response not successful');
      return null;
    } catch (e) {
      // Return null if RAG search fails - fallback to regular Gemini
      print('❌ [RagService] Error: $e');
      return null;
    }
  }

  /// Trigger indexing of all data (admin function)
  Future<bool> indexAllData() async {
    try {
      await _repository.indexAll();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Index only movies
  Future<bool> indexMovies() async {
    try {
      await _repository.indexMovies();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Index only showtimes
  Future<bool> indexShowtimes() async {
    try {
      await _repository.indexShowtimes();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Index only promotions
  Future<bool> indexPromotions() async {
    try {
      await _repository.indexPromotions();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Index only cinemas
  Future<bool> indexCinemas() async {
    try {
      await _repository.indexCinemas();
      return true;
    } catch (e) {
      return false;
    }
  }
}
