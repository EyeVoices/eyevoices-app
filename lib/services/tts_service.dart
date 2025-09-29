import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';
import '../config/app_config.dart';

class TTSService {
  late FlutterTts _flutterTts;
  bool _isInitialized = false;

  Future<void> initialize() async {
    print('🎵 Initializing TTS Service...');
    _flutterTts = FlutterTts();

    // iOS specific settings for proper audio output
    if (Platform.isIOS) {
      await _flutterTts.setSharedInstance(true);
      await _flutterTts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
        ],
        IosTextToSpeechAudioMode.spokenAudio,
      );
    }

    await _flutterTts.setLanguage(AppConfig.ttsLanguage);
    await _flutterTts.setPitch(AppConfig.ttsPitch);
    await _flutterTts.setSpeechRate(AppConfig.ttsSpeechRate);
    await _flutterTts.setVolume(AppConfig.ttsVolume);

    _setupHandlers();
    _isInitialized = true;
    print('✅ TTS Service initialized successfully');
  }

  void _setupHandlers() {
    _flutterTts.setStartHandler(() {
      print('✅ TTS Started');
    });

    _flutterTts.setCompletionHandler(() {
      print('✅ TTS Completed');
    });

    _flutterTts.setErrorHandler((msg) {
      print('❌ TTS Error: $msg');
    });
  }

  Future<void> speak(String text) async {
    if (!_isInitialized) {
      print('❌ TTS Service not initialized');
      return;
    }

    try {
      print('🎵 Speaking: $text');
      await _flutterTts.stop();

      var result = await _flutterTts.speak(text);
      if (result == 1) {
        print('✅ TTS speak command successful');
      } else {
        print('❌ TTS speak command failed with result: $result');
      }
    } catch (e) {
      print('❌ Error in TTS: $e');
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  void dispose() {
    _flutterTts.stop();
  }
}
