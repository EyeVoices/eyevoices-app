class AppConfig {
  // App settings
  static const String appName = 'EyeVoices';
  static const Duration highlightInterval = Duration(seconds: 3);
  static const Duration blinkCooldown = Duration(milliseconds: 1500);

  // Blink detection settings
  static const double blinkThreshold = 0.6;
  static const double blinkRecoveryThreshold = 0.7;
  static const int blinkFramesRequired = 2;

  // TTS settings
  static const String ttsLanguage = "en-US";
  static const double ttsPitch = 1.0;
  static const double ttsSpeechRate = 0.5;
  static const double ttsVolume = 1.0;

  // Default sentences
  static const List<String> defaultSentences = [
    "Hello, how are you today?",
    "I would like some water please.",
    "Can you help me with this?",
    "Thank you very much.",
    "I need to go to the bathroom.",
    "I'm feeling tired now.",
    "What time is it?",
    "Good morning everyone.",
  ];

  // UI settings
  static const double cameraPreviewHeight = 200.0;
  static const double sentenceWheelHeight = 100.0;

  // Colors
  static const primaryColor = 0xFF6A1B9A; // Purple
  static const backgroundColor = 0xFF0A0A0A; // Dark
  static const gradientStartColor = 0xFF1A0033; // Dark purple
}
