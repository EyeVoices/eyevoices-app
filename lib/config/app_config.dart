class AppConfig {
  // App settings
  static const String appName = 'EyeVoices';
  static const Duration highlightInterval = Duration(seconds: 3);
  static const Duration blinkCooldown = Duration(milliseconds: 1500);

  // Blink detection settings
  static const double blinkThreshold = 0.6;
  static const double blinkRecoveryThreshold = 0.7;
  static const int blinkFramesRequired = 2;

  // Advanced blink pattern detection settings
  static const Duration doubleBlinkTimeWindow = Duration(milliseconds: 800);
  static const Duration patternCooldown = Duration(milliseconds: 2000);
  static const double bothEyesClosedThreshold = 0.4;

  // Single eye blink detection settings
  static const double singleEyeClosedThreshold = 0.4;
  static const double otherEyeOpenThreshold =
      0.7; // Other eye must be clearly open
  static const int singleEyeBlinkFramesRequired = 2;

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
}
