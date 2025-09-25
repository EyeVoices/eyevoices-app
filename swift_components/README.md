# Swift Blink Detection Component

This directory contains the Swift component for detecting eye blinks using the device's front-facing camera.

## Files

### BlinkDetector.swift
- Core blink detection logic
- Camera setup and video processing
- API communication with Flutter app
- Currently includes simulated blink detection (replace with actual computer vision implementation)

### BlinkDetectionViewController.swift
- UI controller for the blink detection interface
- Start/stop controls for blink detection
- Status display and user feedback

## Integration with Flutter

The Swift component communicates with the Flutter app through:
1. **HTTP API**: Makes POST requests to `http://localhost:8080/blink` when a blink is detected
2. **Platform Channels**: (To be implemented) Direct communication between Swift and Dart

## Next Steps

1. **Implement Real Blink Detection**: Replace the simulated detection with actual computer vision using:
   - Vision framework for face detection
   - Core ML for eye state classification
   - MLKit for face landmarks

2. **Add Platform Channel**: Create a Flutter platform channel for more efficient communication

3. **Camera Permissions**: Add proper camera permission handling

4. **Error Handling**: Improve error handling and user feedback

## Usage

1. Initialize the BlinkDetector
2. Call `startBlinkDetection()` to begin monitoring
3. The detector will automatically call the Flutter API when blinks are detected
4. Call `stopBlinkDetection()` to stop monitoring

## Dependencies

- AVFoundation (for camera access)
- UIKit (for UI components)
- Foundation (for networking)

## Camera Permissions

Add the following to your iOS app's Info.plist:
```xml
<key>NSCameraUsageDescription</key>
<string>This app uses the camera to detect eye blinks for accessibility features.</string>
```
