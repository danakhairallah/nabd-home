import 'package:flutter_speech/flutter_speech.dart';

class STTService {
  final SpeechRecognition _speech = SpeechRecognition();
  bool _isListening = false;
  String _recognizedText = '';
  void Function(String)? _onResultCallback;
  void Function(String)? _onCompletionCallback;

  STTService() {
    _speech.setAvailabilityHandler((bool result) {});
    _speech.setRecognitionStartedHandler(() {
      _isListening = true;
      _recognizedText = '';
    });
    _speech.setRecognitionResultHandler((String text) {
      _recognizedText = text;
      _onResultCallback?.call(text);
    });
    _speech.setRecognitionCompleteHandler((String text) {
      _isListening = false;
      _recognizedText = text;
      _onCompletionCallback?.call(text);
    });
  }

  Future<void> initialize({
    required Function(String) onResult,
    required Function(String) onCompletion,
  }) async {
    _onResultCallback = onResult;
    _onCompletionCallback = onCompletion;
    await _speech.activate('ar_SA');
  }

  Future<void> startListening() async {
    if (!_isListening) {
      _recognizedText = '';
      await _speech.listen();
    }
  }

  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
    }
  }
}
