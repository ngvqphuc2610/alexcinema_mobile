import 'package:equatable/equatable.dart';
import '../../../data/models/entity/chat_message_entity.dart';

enum ChatStatus { initial, loading, listening, speaking, success, error }

class ChatState extends Equatable {
  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.errorMessage,
    this.isListening = false,
    this.isSpeaking = false,
    this.suggestions = const [],
  });

  final ChatStatus status;
  final List<ChatMessage> messages;
  final String? errorMessage;
  final bool isListening;
  final bool isSpeaking;
  final List<String> suggestions;

  ChatState copyWith({
    ChatStatus? status,
    List<ChatMessage>? messages,
    String? errorMessage,
    bool? isListening,
    bool? isSpeaking,
    List<String>? suggestions,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      errorMessage: errorMessage,
      isListening: isListening ?? this.isListening,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      suggestions: suggestions ?? this.suggestions,
    );
  }

  @override
  List<Object?> get props => [
    status,
    messages,
    errorMessage,
    isListening,
    isSpeaking,
    suggestions,
  ];
}
