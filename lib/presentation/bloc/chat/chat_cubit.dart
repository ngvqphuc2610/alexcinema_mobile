import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/entity/chat_message_entity.dart';
import '../../../data/local/chat_local_storage.dart';
import '../../../domain/services/gemini_service.dart';
import '../../../domain/services/speech_service.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit(
    this._geminiService,
    this._speechService,
    this._localStorage,
  ) : super(const ChatState()) {
    _initialize();
  }

  final GeminiService _geminiService;
  final SpeechService _speechService;
  final ChatLocalStorage _localStorage;

  Future<void> _initialize() async {
    // Initialize speech services
    await _speechService.initializeSpeech();
    await _speechService.initializeTts();

    // Load suggestions
    final suggestions = await _geminiService.getSuggestions();
    
    // Load saved messages from storage
    final savedMessages = _localStorage.loadMessages();
    
    if (savedMessages.isNotEmpty) {
      print('📥 [ChatCubit] Loaded ${savedMessages.length} saved messages');
      emit(state.copyWith(
        messages: savedMessages,
        suggestions: suggestions,
      ));
      return;
    }

    // If no saved messages, add welcome message
    final welcomeMessage = ChatMessage.assistant(
      'Xin chào! Tôi là trợ lý AI của Alex Cinema. Tôi có thể giúp bạn tìm phim, kiểm tra lịch chiếu, hoặc đặt vé. Bạn cần hỗ trợ gì?',
    );
    
    // Save welcome message
    await _localStorage.saveMessage(welcomeMessage);
    
    emit(state.copyWith(
      messages: [welcomeMessage],
      suggestions: suggestions,
    ));
  }

  /// Send text message
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage.user(text);
    emit(
      state.copyWith(
        messages: [...state.messages, userMessage],
        status: ChatStatus.loading,
      ),
    );

    try {
      // Get response from Gemini
      final response = await _geminiService.sendMessage(text);

      // Check if this is a booking intent
      final bookingIntent = await _geminiService.parseBookingIntent(text);

      if (bookingIntent != null && bookingIntent['intent'] == 'book_ticket') {
        // This is a booking request
        final assistantMessage = ChatMessage.assistant(
          bookingIntent['message'] as String? ?? response,
          type: MessageType.booking,
          bookingData: bookingIntent,
        );
        
        // Save messages to storage
        await _localStorage.saveMessage(userMessage);
        await _localStorage.saveMessage(assistantMessage);
        
        emit(
          state.copyWith(
            messages: [...state.messages, assistantMessage],
            status: ChatStatus.success,
          ),
        );
      } else {
        // Normal chat response
        final assistantMessage = ChatMessage.assistant(response);
        
        // Save messages to storage
        await _localStorage.saveMessage(userMessage);
        await _localStorage.saveMessage(assistantMessage);
        
        emit(
          state.copyWith(
            messages: [...state.messages, assistantMessage],
            status: ChatStatus.success,
          ),
        );
      }
    } catch (e) {
      final errorMessage = ChatMessage.error(
        'Xin lỗi, đã có lỗi xảy ra: ${e.toString()}',
      );
      emit(
        state.copyWith(
          messages: [...state.messages, errorMessage],
          status: ChatStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Start voice input
  Future<void> startVoiceInput() async {
    emit(state.copyWith(isListening: true, status: ChatStatus.listening));

    await _speechService.startListening(
      onResult: (recognizedText) {
        emit(state.copyWith(isListening: false));
        if (recognizedText.isNotEmpty) {
          sendMessage(recognizedText);
        }
      },
      onError: (error) {
        final errorMessage = ChatMessage.error(error);
        emit(
          state.copyWith(
            messages: [...state.messages, errorMessage],
            isListening: false,
            status: ChatStatus.error,
            errorMessage: error,
          ),
        );
      },
    );
  }

  /// Stop voice input
  Future<void> stopVoiceInput() async {
    await _speechService.stopListening();
    emit(state.copyWith(isListening: false, status: ChatStatus.initial));
  }

  /// Speak message (Text-to-Speech)
  Future<void> speakMessage(String text) async {
    emit(state.copyWith(isSpeaking: true, status: ChatStatus.speaking));
    await _speechService.speak(text);
    emit(state.copyWith(isSpeaking: false, status: ChatStatus.success));
  }

  /// Stop speaking
  Future<void> stopSpeaking() async {
    await _speechService.stopSpeaking();
    emit(state.copyWith(isSpeaking: false, status: ChatStatus.initial));
  }

  /// Clear chat history
  void clearChat() {
    _localStorage.clearMessages();
    _geminiService.clearHistory();
    emit(const ChatState());
    _initialize();
  }

  /// Use suggestion
  Future<void> useSuggestion(String suggestion) async {
    await sendMessage(suggestion);
  }

  @override
  Future<void> close() {
    _speechService.dispose();
    return super.close();
  }
}
