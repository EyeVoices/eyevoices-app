import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../config/app_config.dart';
import '../models/blink_pattern.dart';

class CameraService {
  final List<CameraDescription> cameras;
  final Function(BlinkPattern) onPatternDetected;

  CameraController? _cameraController;
  FaceDetector? _faceDetector;
  bool _isDetecting = false;

  // Enhanced blink detection variables
  List<DateTime> _blinkHistory = [];
  bool _isBothEyesBlinking = false;
  int _bothEyesBlinkFrames = 0;
  DateTime? _lastPatternTime;
  static int frameCount = 0;

  CameraService({required this.cameras, required this.onPatternDetected});

  bool get isInitialized => _cameraController?.value.isInitialized ?? false;
  CameraController? get cameraController => _cameraController;

  Future<void> initialize() async {
    await _initializeCamera();
    _initializeFaceDetector();
  }

  Future<void> _initializeCamera() async {
    print('📱 Initializing camera...');
    if (cameras.isEmpty) {
      print('❌ No cameras available');
      return;
    }

    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    print('📹 Selected camera: ${frontCamera.name}');
    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.low,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      print('✅ Camera initialized successfully');
      _cameraController!.startImageStream(_processCameraImage);
      print('🎬 Camera image stream started');
    } catch (e) {
      print('❌ Camera initialization failed: $e');
    }
  }

  void _initializeFaceDetector() {
    print('🤖 Initializing face detector...');
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: false,
        enableLandmarks: false,
        enableClassification: true,
        enableTracking: true,
        minFaceSize: 0.05,
        performanceMode: FaceDetectorMode.accurate,
      ),
    );
    print('✅ Face detector initialized');
  }

  void _processCameraImage(CameraImage cameraImage) async {
    if (_isDetecting) return;

    frameCount++;
    if (frameCount % 3 != 0) return;

    _isDetecting = true;

    try {
      final inputImage = _convertCameraImage(cameraImage);
      final faces = await _faceDetector!.processImage(inputImage);

      if (faces.isNotEmpty) {
        if (frameCount % 15 == 0) {
          print('😀 ${faces.length} face(s) detected!');
        }
        _detectBlinkPatterns(faces.first);
      } else {
        if (frameCount % 30 == 0) {
          print('❌ No faces detected');
        }
      }
    } catch (e) {
      print('💥 Face detection error: $e');
    } finally {
      _isDetecting = false;
    }
  }

  InputImage _convertCameraImage(CameraImage cameraImage) {
    Uint8List bytes;
    InputImageFormat format;
    InputImageRotation rotation = InputImageRotation.rotation0deg;

    if (Platform.isIOS &&
        cameraImage.format.group == ImageFormatGroup.bgra8888) {
      bytes = cameraImage.planes[0].bytes;
      format = InputImageFormat.bgra8888;
    } else {
      bytes = cameraImage.planes[0].bytes;
      format = InputImageFormat.yuv420;
    }

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(cameraImage.width.toDouble(), cameraImage.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: cameraImage.planes[0].bytesPerRow,
      ),
    );
  }

  void _detectBlinkPatterns(Face face) {
    final leftEyeProb = face.leftEyeOpenProbability;
    final rightEyeProb = face.rightEyeOpenProbability;

    if (leftEyeProb != null && rightEyeProb != null) {
      _processBothEyesBlink(leftEyeProb, rightEyeProb);
    }
  }

  void _processBothEyesBlink(double leftEyeProb, double rightEyeProb) {
    DateTime now = DateTime.now();

    // Check cooldown period
    if (_lastPatternTime != null &&
        now.difference(_lastPatternTime!).inMilliseconds <
            AppConfig.patternCooldown.inMilliseconds) {
      return;
    }

    // Check if both eyes are closed
    double avgEyeOpenness = (leftEyeProb + rightEyeProb) / 2.0;
    bool bothEyesClosed = avgEyeOpenness < AppConfig.bothEyesClosedThreshold;

    if (frameCount % 15 == 0) {
      print('👁️ Both eyes openness: ${avgEyeOpenness.toStringAsFixed(3)}');
    }

    if (bothEyesClosed) {
      if (!_isBothEyesBlinking) {
        _bothEyesBlinkFrames++;
        if (_bothEyesBlinkFrames >= AppConfig.blinkFramesRequired) {
          _isBothEyesBlinking = true;
          print('💫 Both eyes blink STARTED');
        }
      }
    } else if (_isBothEyesBlinking) {
      if (_bothEyesBlinkFrames >= AppConfig.blinkFramesRequired) {
        print('🎯 Both eyes blink COMPLETED - checking for double blink...');
        _checkForDoubleBlink(now);
      }
      _isBothEyesBlinking = false;
      _bothEyesBlinkFrames = 0;
    }
  }

  void _checkForDoubleBlink(DateTime now) {
    // Add current blink timestamp to history
    _blinkHistory.add(now);

    // Clean old blinks (keep only those within double blink time window)
    _blinkHistory.removeWhere(
      (blinkTime) =>
          now.difference(blinkTime).inMilliseconds >
          AppConfig.doubleBlinkTimeWindow.inMilliseconds,
    );

    if (_blinkHistory.length >= 2) {
      print('🎯🎯 DOUBLE BLINK DETECTED! Triggering action...');
      _registerPattern(BlinkPattern.doubleBlink, now);

      // Clear blink history after successful double blink
      _blinkHistory.clear();
    } else {
      print('📝 Single blink registered (waiting for potential double blink)');
    }
  }

  void _registerPattern(BlinkPattern pattern, DateTime now) {
    _lastPatternTime = now;
    onPatternDetected(pattern);
  }

  void setDetectionEnabled(bool enabled) {
    if (_cameraController?.value.isInitialized == true) {
      if (enabled) {
        // Start image stream for detection
        _cameraController!.startImageStream(_processCameraImage);
        print('✅ Detection ENABLED - Image stream started');
      } else {
        // Stop image stream to save resources
        _cameraController!.stopImageStream();
        _bothEyesBlinkFrames = 0;
        _isBothEyesBlinking = false;
        _isDetecting = false;
        _blinkHistory.clear();
        print('🚫 Detection DISABLED - Image stream stopped');
      }
    }
  }

  void dispose() {
    _cameraController?.dispose();
    _faceDetector?.close();
  }
}
