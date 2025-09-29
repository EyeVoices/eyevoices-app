import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class CameraService {
  final List<CameraDescription> cameras;
  final VoidCallback onBlinkDetected;

  CameraController? _cameraController;
  FaceDetector? _faceDetector;
  bool _isDetecting = false;

  // Blink detection variables
  bool _isBlinking = false;
  int _blinkFrameCounter = 0;
  DateTime? _lastBlinkTime;
  static int frameCount = 0;

  CameraService({required this.cameras, required this.onBlinkDetected});

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
        _detectBlink(faces.first);
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

  void _detectBlink(Face face) {
    final leftEyeProb = face.leftEyeOpenProbability;
    final rightEyeProb = face.rightEyeOpenProbability;

    if (leftEyeProb != null && rightEyeProb != null) {
      double avgEyeOpenness = (leftEyeProb + rightEyeProb) / 2.0;

      if (frameCount % 15 == 0) {
        print('👁️ Eyes openness: ${avgEyeOpenness.toStringAsFixed(3)}');
      }

      if (avgEyeOpenness < 0.6) {
        if (!_isBlinking) {
          _blinkFrameCounter++;
          if (_blinkFrameCounter >= 2) {
            _isBlinking = true;
            print('💫 Blink STARTED');
          }
        }
      } else if (avgEyeOpenness > 0.7) {
        if (_isBlinking && _blinkFrameCounter >= 2) {
          DateTime now = DateTime.now();
          if (_lastBlinkTime == null ||
              now.difference(_lastBlinkTime!).inMilliseconds > 1500) {
            print('🎯 BLINK COMPLETE! Triggering speech...');
            onBlinkDetected();
            _lastBlinkTime = now;
          }
          _isBlinking = false;
          _blinkFrameCounter = 0;
        }
      }
    }
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
        _blinkFrameCounter = 0;
        _isBlinking = false;
        _isDetecting = false;
        print('🚫 Detection DISABLED - Image stream stopped');
      }
    }
  }

  void dispose() {
    _cameraController?.dispose();
    _faceDetector?.close();
  }
}
