import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  FlutterTts? _flutterTts;
  bool _isInitialized = false;
  bool _isSpeaking = false;

  /// Initialize the TTS service
  Future<void> initialize() async {
    if (_isInitialized) return;

    _flutterTts = FlutterTts();

    try {
      // Set language to English (US)
      await _flutterTts!.setLanguage('en-US');

      // Set speech rate (0.0 to 1.0, where 0.5 is normal)
      await _flutterTts!.setSpeechRate(0.5);

      // Set volume (0.0 to 1.0)
      await _flutterTts!.setVolume(0.8);

      // Set pitch (0.5 to 2.0, where 1.0 is normal)
      await _flutterTts!.setPitch(1.0);

      // Set completion handler
      _flutterTts!.setCompletionHandler(() {
        _isSpeaking = false;
      });

      // Set error handler
      _flutterTts!.setErrorHandler((msg) {
        _isSpeaking = false;
        print('TTS Error: $msg');
      });

      _isInitialized = true;
    } catch (e) {
      print('TTS Initialization Error: $e');
    }
  }

  /// Speak the given text
  Future<void> speak(String text) async {
    if (!_isInitialized || text.isEmpty) return;

    try {
      // Stop any current speech
      await stop();

      _isSpeaking = true;
      await _flutterTts!.speak(text);
    } catch (e) {
      print('TTS Speak Error: $e');
      _isSpeaking = false;
    }
  }

  /// Stop current speech
  Future<void> stop() async {
    if (!_isInitialized) return;

    try {
      await _flutterTts!.stop();
      _isSpeaking = false;
    } catch (e) {
      print('TTS Stop Error: $e');
    }
  }

  /// Pause current speech
  Future<void> pause() async {
    if (!_isInitialized) return;

    try {
      await _flutterTts!.pause();
    } catch (e) {
      print('TTS Pause Error: $e');
    }
  }

  /// Check if TTS is currently speaking
  bool get isSpeaking => _isSpeaking;

  /// Check if TTS is initialized
  bool get isInitialized => _isInitialized;

  /// Set speech rate (0.0 to 1.0)
  Future<void> setSpeechRate(double rate) async {
    if (!_isInitialized) return;

    try {
      await _flutterTts!.setSpeechRate(rate.clamp(0.0, 1.0));
    } catch (e) {
      print('TTS Set Speech Rate Error: $e');
    }
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    if (!_isInitialized) return;

    try {
      await _flutterTts!.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      print('TTS Set Volume Error: $e');
    }
  }

  /// Set pitch (0.5 to 2.0)
  Future<void> setPitch(double pitch) async {
    if (!_isInitialized) return;

    try {
      await _flutterTts!.setPitch(pitch.clamp(0.5, 2.0));
    } catch (e) {
      print('TTS Set Pitch Error: $e');
    }
  }

  /// Dispose of the TTS service
  void dispose() {
    _flutterTts?.stop();
    _flutterTts = null;
    _isInitialized = false;
    _isSpeaking = false;
  }
}
