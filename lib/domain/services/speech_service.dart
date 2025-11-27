import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  bool _isListening = false;
  bool _isSpeaking = false;

  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;

  /// Initialize speech recognition
  Future<bool> initializeSpeech() async {
    try {
      return await _speechToText.initialize(
        onStatus: (status) {
          _isListening = status == 'listening';
        },
        onError: (error) {
          _isListening = false;
        },
      );
    } catch (e) {
      return false;
    }
  }

  /// Initialize text-to-speech
  Future<void> initializeTts() async {
    await _flutterTts.setLanguage('vi-VN');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
    });

    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
    });

    _flutterTts.setErrorHandler((msg) {
      _isSpeaking = false;
    });
  }

  /// Start listening to user's voice
  Future<void> startListening({
    required Function(String) onResult,
    required Function(String) onError,
  }) async {
    if (!_speechToText.isAvailable) {
      final initialized = await initializeSpeech();
      if (!initialized) {
        onError('Không thể khởi tạo nhận diện giọng nói');
        return;
      }
    }

    if (_speechToText.isListening) {
      await _speechToText.stop();
    }

    try {
      await _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            onResult(result.recognizedWords);
            _isListening = false;
          }
        },
        localeId: 'vi_VN',
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: false,
        cancelOnError: true,
      );
      _isListening = true;
    } catch (e) {
      onError('Lỗi khi nhận diện giọng nói: ${e.toString()}');
      _isListening = false;
    }
  }

  /// Stop listening
  Future<void> stopListening() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
    }
    _isListening = false;
  }

  /// Speak text
  Future<void> speak(String text) async {
    if (_isSpeaking) {
      await _flutterTts.stop();
    }

    try {
      await _flutterTts.speak(text);
    } catch (e) {
      _isSpeaking = false;
    }
  }

  /// Stop speaking
  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
    _isSpeaking = false;
  }

  /// Check if speech recognition is available
  Future<bool> isSpeechAvailable() async {
    return await _speechToText.initialize();
  }

  /// Get available languages for TTS
  Future<List<dynamic>> getAvailableLanguages() async {
    return await _flutterTts.getLanguages;
  }

  /// Dispose resources
  void dispose() {
    _speechToText.stop();
    _flutterTts.stop();
  }
}
