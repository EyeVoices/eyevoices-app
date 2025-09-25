import 'package:flutter/services.dart';

/// Service class for communicating with the native Swift blink detection component
class BlinkDetectionService {
  static const MethodChannel _channel = MethodChannel('eyevoices/blink_detection');
  
  // Singleton pattern
  static final BlinkDetectionService _instance = BlinkDetectionService._internal();
  factory BlinkDetectionService() => _instance;
  BlinkDetectionService._internal();
  
  /// Callback function to be called when a blink is detected
  Function(String)? onBlinkDetected;
  
  /// Initialize the service and set up the method call handler
  Future<void> initialize() async {
    _channel.setMethodCallHandler(_handleMethodCall);
  }
  
  /// Start blink detection on the native side
  Future<bool> startBlinkDetection() async {
    try {
      final result = await _channel.invokeMethod('startBlinkDetection');
      return result == true;
    } on PlatformException catch (e) {
      print('Failed to start blink detection: ${e.message}');
      return false;
    }
  }
  
  /// Stop blink detection on the native side
  Future<bool> stopBlinkDetection() async {
    try {
      final result = await _channel.invokeMethod('stopBlinkDetection');
      return result == true;
    } on PlatformException catch (e) {
      print('Failed to stop blink detection: ${e.message}');
      return false;
    }
  }
  
  /// Check if blink detection is currently running
  Future<bool> isBlinkDetectionRunning() async {
    try {
      final result = await _channel.invokeMethod('isBlinkDetectionRunning');
      return result == true;
    } on PlatformException catch (e) {
      print('Failed to check blink detection status: ${e.message}');
      return false;
    }
  }
  
  /// Trigger speech for a specific sentence (alternative to HTTP API)
  Future<bool> speakSentence(String sentence) async {
    try {
      final result = await _channel.invokeMethod('speakSentence', {'sentence': sentence});
      return result == true;
    } on PlatformException catch (e) {
      print('Failed to speak sentence: ${e.message}');
      return false;
    }
  }
  
  /// Handle method calls from the native side
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onBlinkDetected':
        final String sentence = call.arguments['sentence'] ?? '';
        onBlinkDetected?.call(sentence);
        return true;
      case 'onBlinkDetectionError':
        final String error = call.arguments['error'] ?? 'Unknown error';
        print('Blink detection error: $error');
        return true;
      default:
        throw MissingPluginException('Method ${call.method} not implemented');
    }
  }
  
  /// Set the callback function for blink detection
  void setBlinkDetectedCallback(Function(String) callback) {
    onBlinkDetected = callback;
  }
}
