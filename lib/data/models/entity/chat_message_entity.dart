import 'package:equatable/equatable.dart';

enum MessageRole { user, assistant, system }

enum MessageType { text, voice, booking }

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.type = MessageType.text,
    this.bookingData,
    this.isError = false,
  });

  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final MessageType type;
  final Map<String, dynamic>? bookingData;
  final bool isError;

  bool get isUser => role == MessageRole.user;
  bool get isAssistant => role == MessageRole.assistant;
  bool get isSystem => role == MessageRole.system;
  bool get isBookingIntent =>
      type == MessageType.booking && bookingData != null;

  ChatMessage copyWith({
    String? id,
    MessageRole? role,
    String? content,
    DateTime? timestamp,
    MessageType? type,
    Map<String, dynamic>? bookingData,
    bool? isError,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      bookingData: bookingData ?? this.bookingData,
      isError: isError ?? this.isError,
    );
  }

  @override
  List<Object?> get props => [id, role, content, timestamp, type, isError];

  /// Create a user message
  factory ChatMessage.user(
    String content, {
    MessageType type = MessageType.text,
  }) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.user,
      content: content,
      timestamp: DateTime.now(),
      type: type,
    );
  }

  /// Create an assistant message
  factory ChatMessage.assistant(
    String content, {
    MessageType type = MessageType.text,
    Map<String, dynamic>? bookingData,
  }) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.assistant,
      content: content,
      timestamp: DateTime.now(),
      type: type,
      bookingData: bookingData,
    );
  }

  /// Create a system message
  factory ChatMessage.system(String content) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.system,
      content: content,
      timestamp: DateTime.now(),
      type: MessageType.text,
    );
  }

  /// Create an error message
  factory ChatMessage.error(String content) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.system,
      content: content,
      timestamp: DateTime.now(),
      isError: true,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role.name,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'bookingData': bookingData,
      'isError': isError,
    };
  }

  /// Create from JSON
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      role: MessageRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => MessageRole.user,
      ),
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: MessageType.values.firstWhere(
        (e) => e.name == (json['type'] ?? 'text'),
        orElse: () => MessageType.text,
      ),
      bookingData: json['bookingData'] as Map<String, dynamic>?,
      isError: json['isError'] as bool? ?? false,
    );
  }
}
