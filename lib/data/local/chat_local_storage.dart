import 'package:hive/hive.dart';
import '../../data/models/entity/chat_message_entity.dart';

/// Local storage for chat messages using Hive
class ChatLocalStorage {
  static const String _boxName = 'chat_messages';
  Box<Map<dynamic, dynamic>>? _box;

  /// Initialize Hive box
  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    print('✅ [ChatLocalStorage] Initialized with ${_box!.length} messages');
  }

  /// Save a single message
  Future<void> saveMessage(ChatMessage message) async {
    if (_box == null) {
      print('❌ [ChatLocalStorage] Box not initialized');
      return;
    }
    
    await _box!.put(message.id, message.toJson());
    print('💾 [ChatLocalStorage] Saved message ${message.id}');
  }

  /// Save multiple messages (bulk)
  Future<void> saveMessages(List<ChatMessage> messages) async {
    if (_box == null) {
      print('❌ [ChatLocalStorage] Box not initialized');
      return;
    }
    
    final Map<String, Map<String, dynamic>> data = {
      for (var msg in messages) msg.id: msg.toJson()
    };
    
    await _box!.putAll(data);
    print('💾 [ChatLocalStorage] Saved ${messages.length} messages');
  }

  /// Load all messages from storage
  List<ChatMessage> loadMessages() {
    if (_box == null) {
      print('❌ [ChatLocalStorage] Box not initialized');
      return [];
    }

    try {
      final messages = _box!.values
          .map((json) {
            try {
              return ChatMessage.fromJson(Map<String, dynamic>.from(json));
            } catch (e) {
              print('⚠️ [ChatLocalStorage] Error parsing message: $e');
              return null;
            }
          })
          .whereType<ChatMessage>()
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

      print('📥 [ChatLocalStorage] Loaded ${messages.length} messages');
      return messages;
    } catch (e) {
      print('❌ [ChatLocalStorage] Error loading messages: $e');
      return [];
    }
  }

  /// Clear all messages
  Future<void> clearMessages() async {
    if (_box == null) {
      print('❌ [ChatLocalStorage] Box not initialized');
      return;
    }

    await _box!.clear();
    print('🗑️ [ChatLocalStorage] Cleared all messages');
  }

  /// Get message count
  int getMessageCount() {
    return _box?.length ?? 0;
  }

  /// Close the box
  Future<void> close() async {
    await _box?.close();
    print('🔒 [ChatLocalStorage] Closed storage');
  }
}
