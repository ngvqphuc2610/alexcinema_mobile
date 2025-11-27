import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'rag_service.dart';

class GeminiService {
  late final GenerativeModel _model;
  ChatSession? _chatSession;
  RagService? _ragService;

  GeminiService({RagService? ragService}) : _ragService = ragService {
    final apiKey = dotenv.env['GEMENI_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception('GEMENI_API_KEY not found in .env file');
    }

    _model = GenerativeModel(
      model: 'gemini-flash-latest',
      apiKey: apiKey,
      systemInstruction: Content.system(_getCinemaSystemInstruction()),
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
    );
  }

  String _getCinemaSystemInstruction() {
    return 'Bạn là trợ lý AI thông minh của Alex Cinema - hệ thống đặt vé xem phim trực tuyến.\n\n'
        'NHIỆM VỤ CHÍNH:\n'
        '1. Trả lời câu hỏi về phim, lịch chiếu, rạp, giá vé\n'
        '2. Hỗ trợ đặt vé qua giọng nói hoặc text\n'
        '3. Giúp người dùng tìm phim phù hợp với sở thích\n\n'
        'KHẢ NĂNG:\n'
        '- Tìm kiếm phim theo tên, thể loại, diễn viên, đạo diễn\n'
        '- Kiểm tra lịch chiếu theo ngày/giờ\n'
        '- Gợi ý phim dựa trên sở thích người dùng\n'
        '- Parse yêu cầu đặt vé thành thông tin có cấu trúc\n\n'
        'ĐỊNH DẠNG ĐẶT VÉ:\n'
        'Khi người dùng muốn đặt vé, trả về JSON format với các field: intent, movieName, date, time, seats, message\n\n'
        'NGUYÊN TẮC:\n'
        '- Luôn lịch sự, thân thiện, nhiệt tình\n'
        '- Trả lời ngắn gọn, súc tích bằng tiếng Việt\n'
        '- Nếu không hiểu rõ, hỏi lại để clarify\n'
        '- Không bịa đặt thông tin về phim/lịch chiếu\n'
        '- Nếu không có thông tin, hướng dẫn user tìm trên app';
  }

  /// Start a new chat session
  void startNewSession() {
    _chatSession = _model.startChat();
  }

  /// Send message and get response (with RAG support)
  Future<String> sendMessage(String message) async {
    try {
      _chatSession ??= _model.startChat();

      // Try to get relevant context from RAG
      String augmentedMessage = message;
      print('🔍 [GeminiService] Searching RAG for: $message');
      print('🔍 [GeminiService] RagService is null: ${_ragService == null}');

      if (_ragService != null) {
        try {
          final ragResult = await _ragService!.search(message);
          print(
            '🔍 [GeminiService] RAG result: ${ragResult != null ? "Found" : "Null"}',
          );

          if (ragResult != null && ragResult.context.isNotEmpty) {
            print(
              '✅ [GeminiService] RAG context length: ${ragResult.context.length}',
            );
            print(
              '✅ [GeminiService] RAG sources count: ${ragResult.sources.length}',
            );

            // Inject RAG context into the prompt
            augmentedMessage =
                '''
THÔNG TIN TỪ HỆ THỐNG:
${ragResult.context}

---
CÂU HỎI NGƯỜI DÙNG: $message

Hãy trả lời dựa trên thông tin trên. Nếu thông tin không đủ, hãy nói rõ.
''';
            print('✅ [GeminiService] Using augmented message');
          } else {
            print('⚠️ [GeminiService] RAG returned empty context');
          }
        } catch (e) {
          print('❌ [GeminiService] RAG search failed: $e');
        }
      }

      final response = await _chatSession!.sendMessage(
        Content.text(augmentedMessage),
      );

      return response.text ?? 'Xin lỗi, tôi không thể trả lời lúc này.';
    } catch (e) {
      print('❌ [GeminiService] Error: $e');
      throw Exception('Gemini API Error: ${e.toString()}');
    }
  }

  /// Send message with context (for voice booking)
  Future<Map<String, dynamic>?> parseBookingIntent(String userInput) async {
    try {
      final prompt =
          'Phân tích yêu cầu đặt vé sau và trả về JSON (chỉ JSON, không có text khác):\n\n'
          'User input: "$userInput"\n\n'
          'Trả về format:\n'
          '{\n'
          '  "intent": "book_ticket" hoặc "ask_question",\n'
          '  "movieName": "tên phim nếu có",\n'
          '  "date": "YYYY-MM-DD hoặc \'today\'/\'tomorrow\' hoặc null",\n'
          '  "time": "HH:MM hoặc null",\n'
          '  "seats": số ghế hoặc null,\n'
          '  "message": "tin nhắn xác nhận"\n'
          '}';

      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';

      // Extract JSON from response
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(text);
      if (jsonMatch != null) {
        final jsonStr = jsonMatch.group(0)!;
        // Parse JSON manually to avoid import issues
        return _parseJsonString(jsonStr);
      }

      return null;
    } catch (e) {
      throw Exception('Parse booking intent error: ${e.toString()}');
    }
  }

  /// Simple JSON parser (basic implementation)
  Map<String, dynamic>? _parseJsonString(String jsonStr) {
    try {
      // This is a simplified parser, in production use dart:convert
      final Map<String, dynamic> result = {};

      // Remove outer braces and whitespace
      final content = jsonStr.trim().substring(1, jsonStr.length - 1).trim();

      // Split by commas (simple approach)
      final pairs = content.split(RegExp(r',(?=\s*")'));

      for (final pair in pairs) {
        final parts = pair.split(':');
        if (parts.length == 2) {
          final key = parts[0].trim().replaceAll('"', '');
          var value = parts[1].trim();

          // Remove quotes from string values
          if (value.startsWith('"') && value.endsWith('"')) {
            value = value.substring(1, value.length - 1);
          }

          // Parse null
          if (value == 'null') {
            result[key] = null;
          }
          // Parse number
          else if (RegExp(r'^\d+$').hasMatch(value)) {
            result[key] = int.tryParse(value);
          }
          // String value
          else {
            result[key] = value;
          }
        }
      }

      return result;
    } catch (e) {
      return null;
    }
  }

  /// Clear chat history
  void clearHistory() {
    _chatSession = null;
  }

  /// Get suggestions for user
  Future<List<String>> getSuggestions() async {
    final suggestions = [
      'Phim gì đang hot hôm nay?',
      'Tìm phim hành động hay',
      'Đặt vé xem phim tối nay',
      'Suất chiếu phim Avengers',
      'Giá vé bao nhiêu?',
    ];
    return suggestions;
  }
}
