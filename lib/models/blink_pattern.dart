/// Different types of blink patterns that can be detected
enum BlinkPattern {
  doubleBlink, // Both eyes closed twice in quick succession
  leftEyeBlink, // Only left eye blink
  rightEyeBlink, // Only right eye blink
  longBlink, // Extended blink duration
  // singleBlink is intentionally omitted for now
}

/// Represents a detected blink event
class BlinkEvent {
  final BlinkPattern pattern;
  final DateTime timestamp;
  final double confidence;

  const BlinkEvent({
    required this.pattern,
    required this.timestamp,
    this.confidence = 1.0,
  });

  @override
  String toString() {
    return 'BlinkEvent(pattern: $pattern, timestamp: $timestamp, confidence: $confidence)';
  }
}
