# EyeVoices App

A cross-platform Flutter app that uses blink detection to trigger text-to-speech for accessibility.

## Features

- **8 Sentence Display**: Shows 8 predefined sentences in a spacey grid layout
- **Auto-highlighting**: Cycles through sentences every 2 seconds with visual highlighting
- **Blink Detection**: Uses MediaPipe face detection to detect eye blinks
- **Text-to-Speech**: Speaks the currently highlighted sentence when a blink is detected
- **Cross-platform**: Works on both iOS and Android

## Technology Stack

- **Flutter**: Cross-platform mobile development framework
- **MediaPipe (Google ML Kit)**: Face detection and landmark tracking
- **Camera Plugin**: Access to device camera for real-time blink detection
- **Flutter TTS**: Text-to-speech functionality

## How It Works

1. The app displays 8 sentences in a 2x4 grid
2. Every 2 seconds, the app highlights the next sentence in sequence
3. The front camera continuously monitors for face landmarks
4. When a blink is detected (Eye Aspect Ratio below threshold), the currently highlighted sentence is spoken
5. The cycle continues indefinitely

## Setup and Installation

### Prerequisites
- Flutter SDK 3.35.4 or later
- iOS development: Xcode with iOS 11.0+
- Android development: Android Studio with API level 21+

### Installation
```bash
# Clone the repository
git clone <repository-url>
cd eyevoices-app

# Get dependencies
flutter pub get

# Run on iOS simulator/device
flutter run

# Run on Android simulator/device
flutter run
```

### Permissions

The app requires camera access:

**iOS**: Camera permission is automatically handled by the camera plugin
**Android**: Camera permission is automatically handled by the camera plugin

## Architecture

```
lib/
├── main.dart                 # Main app with MediaPipe integration
├── main_old_platform.dart   # Previous platform channel implementation
└── main_old.dart            # Original demo implementation
```

## Usage

1. Launch the app
2. Grant camera permissions when prompted
3. Tap the "Blink Detection ON/OFF" button to enable blink detection
4. The camera preview will show in the top section
5. Blink deliberately to trigger speech of the currently highlighted sentence

## Customization

### Adding New Sentences
Edit the `_sentences` list in `main.dart`:

```dart
final List<String> _sentences = [
  "Your custom sentence here",
  // ... more sentences
];
```

### Adjusting Blink Sensitivity
Modify the blink detection parameters in `main.dart`:

```dart
static const double _blinkThreshold = 0.25;  // Lower = more sensitive
static const int _blinkFrames = 3;           // Frames to confirm blink
```

### Changing Highlight Timing
Update the timer duration:

```dart
Timer.periodic(const Duration(seconds: 2), (timer) {
  // Change seconds value here
});
```

## Known Limitations

1. Blink detection uses a simplified algorithm - can be improved with more sophisticated eye aspect ratio calculations
2. Performance may vary based on lighting conditions
3. Front camera quality affects detection accuracy

## Future Enhancements

- [ ] Improved blink detection algorithm with proper Eye Aspect Ratio calculation
- [ ] Calibration screen for personalized blink sensitivity
- [ ] Voice command integration
- [ ] Custom sentence management
- [ ] Analytics and usage tracking
- [ ] Offline operation mode

## Platform Support

- ✅ iOS (11.0+)
- ✅ Android (API 21+)
- ❌ Web (removed)
- ❌ Windows (removed)
- ❌ macOS (removed)
- ❌ Linux (removed)

## Dependencies

- `flutter_tts: ^4.2.0` - Text-to-speech functionality
- `camera: ^0.11.0+2` - Camera access and preview
- `google_mlkit_face_detection: ^0.11.1` - Face detection and landmarks

## License

This project is licensed under the MIT License - see the LICENSE file for details.