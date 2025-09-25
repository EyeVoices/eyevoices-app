import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(EyeVoicesApp(cameras: cameras));
}

class EyeVoicesApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  
  const EyeVoicesApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EyeVoices',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        fontFamily: 'Roboto',
      ),
      home: EyeVoicesHome(cameras: cameras),
      debugShowCheckedModeBanner: false,
    );
  }
}

class EyeVoicesHome extends StatefulWidget {
  final List<CameraDescription> cameras;
  
  const EyeVoicesHome({super.key, required this.cameras});

  @override
  State<EyeVoicesHome> createState() => _EyeVoicesHomeState();
}

class _EyeVoicesHomeState extends State<EyeVoicesHome>
    with TickerProviderStateMixin {
  late Timer _highlightTimer;
  int _currentHighlightIndex = 0;
  late FlutterTts _flutterTts;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late PageController _pageController; // Added for horizontal wheel
  
  CameraController? _cameraController;
  FaceDetector? _faceDetector;
  bool _isDetecting = false;
  bool _isBlinkDetectionEnabled = true;
  
  // Blink detection variables
  bool _isBlinking = false;
  int _blinkFrameCounter = 0;
  DateTime? _lastBlinkTime;
  
  final List<String> _sentences = [
    "Hello, how are you today?",
    "I would like some water please.",
    "Can you help me with this?",
    "Thank you very much.",
    "I need to go to the bathroom.",
    "I'm feeling tired now.",
    "What time is it?",
    "Good morning everyone."
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.8,
      initialPage: 0,
    );
    _initializeTts();
    _initializeAnimation();
    _initializeCamera();
    _initializeFaceDetector();
    _startHighlightTimer();
  }

  void _initializeTts() async {
    print('🎵 Initializing TTS...');
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
    
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    
    _flutterTts.setStartHandler(() {
      print('✅ TTS Started');
    });
    
    _flutterTts.setCompletionHandler(() {
      print('✅ TTS Completed');
    });
    
    _flutterTts.setErrorHandler((msg) {
      print('❌ TTS Error: $msg');
    });
    
    print('✅ TTS initialized successfully');
  }

  void _initializeAnimation() {
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _glowController.repeat(reverse: true);
  }

  Future<void> _initializeCamera() async {
    print('📱 Initializing camera...');
    if (widget.cameras.isEmpty) {
      print('❌ No cameras available');
      return;
    }

    final frontCamera = widget.cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => widget.cameras.first,
    );

    print('📹 Selected camera: ${frontCamera.name}');
    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.low, // Use lower resolution for better performance and detection
      enableAudio: false,
      // Don't specify imageFormatGroup, let it use defaults
    );

    try {
      await _cameraController!.initialize();
      print('✅ Camera initialized successfully');
      _cameraController!.startImageStream(_processCameraImage);
      print('🎬 Camera image stream started');
    } catch (e) {
      print('❌ Camera initialization failed: $e');
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _initializeFaceDetector() {
    print('🤖 Initializing face detector...');
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: false,
        enableLandmarks: false,
        enableClassification: true, // This is needed for eye openness probability
        enableTracking: true, // Enable tracking for better performance
        minFaceSize: 0.05, // Even smaller minimum face size
        performanceMode: FaceDetectorMode.accurate, // Use accurate mode instead of fast
      ),
    );
    print('✅ Face detector initialized with accurate mode and very small min face size');
  }

  static int frameCount = 0;
  
  void _processCameraImage(CameraImage cameraImage) async {
    if (_isDetecting || !_isBlinkDetectionEnabled) return;
    
    // Process every 3rd frame for better performance but more responsive detection
    frameCount++;
    if (frameCount % 3 != 0) return;

    _isDetecting = true;
    
    // Detailed debugging every 30 frames
    if (frameCount % 30 == 0) {
      print('📸 Processing frame #$frameCount - Image: ${cameraImage.width}x${cameraImage.height}, planes: ${cameraImage.planes.length}');
    }

    try {
      final inputImage = _convertCameraImage(cameraImage);
      final faces = await _faceDetector!.processImage(inputImage);

      if (faces.isNotEmpty) {
        if (frameCount % 15 == 0) {
          print('😀 ${faces.length} face(s) detected! Processing blink detection...');
        }
        _detectBlink(faces.first);
      } else {
        // Only show "no faces" message occasionally to avoid spam
        if (frameCount % 30 == 0) {
          print('❌ No faces detected in frame #$frameCount - Check camera positioning and lighting');
        }
      }
    } catch (e) {
      print('💥 Face detection error at frame #$frameCount: $e');
      print('📊 Camera image details: ${cameraImage.width}x${cameraImage.height}, format: ${cameraImage.format.group}');
    } finally {
      _isDetecting = false;
    }
  }

  InputImage _convertCameraImage(CameraImage cameraImage) {
    // Log camera image details for debugging
    if (frameCount % 30 == 0) {
      print('📸 Camera details: ${cameraImage.width}x${cameraImage.height}');
      print('📸 Format: ${cameraImage.format.group}');
      print('📸 Planes: ${cameraImage.planes.length}');
      for (int i = 0; i < cameraImage.planes.length; i++) {
        print('📸 Plane $i: ${cameraImage.planes[i].bytes.length} bytes, bytesPerRow: ${cameraImage.planes[i].bytesPerRow}');
      }
    }
    
    // For BGRA8888 format, we need to handle the bytes correctly
    Uint8List bytes;
    InputImageFormat format;
    InputImageRotation rotation;
    
    if (Platform.isIOS && cameraImage.format.group == ImageFormatGroup.bgra8888) {
      // For BGRA format, use all bytes from the single plane
      bytes = cameraImage.planes[0].bytes;
      format = InputImageFormat.bgra8888;
      // Try different rotations to find the right one
      rotation = InputImageRotation.rotation0deg; // Start with no rotation
    } else {
      // Default YUV handling
      bytes = cameraImage.planes[0].bytes;
      format = InputImageFormat.yuv420;
      rotation = InputImageRotation.rotation0deg;
    }
    
    if (frameCount % 30 == 0) {
      print('📸 Using format: $format, rotation: $rotation');
      print('📸 Bytes length: ${bytes.length}');
    }
    
    final inputImage = InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(cameraImage.width.toDouble(), cameraImage.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: cameraImage.planes[0].bytesPerRow,
      ),
    );
    
    return inputImage;
  }

  void _detectBlink(Face face) {
    // Use eye openness probability (more reliable than contours)
    final leftEyeProb = face.leftEyeOpenProbability;
    final rightEyeProb = face.rightEyeOpenProbability;
    
    if (leftEyeProb != null && rightEyeProb != null) {
      double avgEyeOpenness = (leftEyeProb + rightEyeProb) / 2.0;
      
      // Debug output every few frames
      if (frameCount % 15 == 0) {
        print('👁️ Eyes: L=${leftEyeProb.toStringAsFixed(3)} R=${rightEyeProb.toStringAsFixed(3)} Avg=${avgEyeOpenness.toStringAsFixed(3)}');
        print('🔍 Blink state: isBlinking=$_isBlinking, frameCounter=$_blinkFrameCounter');
      }
      
      // Improved blink detection with clearer thresholds
      if (avgEyeOpenness < 0.6) { // Eyes closing
        if (!_isBlinking) {
          _blinkFrameCounter++;
          print('📉 Eyes closing... frame $_blinkFrameCounter (openness: ${avgEyeOpenness.toStringAsFixed(3)})');
          if (_blinkFrameCounter >= 2) {
            _isBlinking = true;
            print('💫 Blink state: STARTED');
          }
        }
      } else if (avgEyeOpenness > 0.7) { // Eyes opening
        if (_isBlinking && _blinkFrameCounter >= 2) {
          // Blink complete - check cooldown
          DateTime now = DateTime.now();
          if (_lastBlinkTime == null || 
              now.difference(_lastBlinkTime!).inMilliseconds > 1500) {
            print('🎯 BLINK COMPLETE! Triggering speech...');
            _onBlinkDetected();
            _lastBlinkTime = now;
          } else {
            print('⏰ Blink detected but in cooldown period');
          }
          _isBlinking = false;
          _blinkFrameCounter = 0;
          print('💫 Blink state: RESET');
        }
      }
      // Middle range (0.6-0.7) maintains current state
    } else {
      print('⚠️ Eye probability data not available');
    }
  }

  void _startHighlightTimer() {
    print('⏰ Starting highlight timer...');
    _highlightTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _currentHighlightIndex = (_currentHighlightIndex + 1) % _sentences.length;
      });
      
      // Add a small delay to ensure PageController is ready, then animate
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && _pageController.hasClients) {
          print('🎡 Animating wheel to page $_currentHighlightIndex');
          _pageController.animateToPage(
            _currentHighlightIndex,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else {
          print('❌ PageController has no clients - cannot animate wheel');
        }
      });
      
      print('🔄 Highlighted sentence changed to: "${_sentences[_currentHighlightIndex]}"');
    });
  }

  void _onBlinkDetected() async {
    String currentSentence = _sentences[_currentHighlightIndex];
    
    try {
      print('🎵 Speaking: $currentSentence');
      await _flutterTts.stop();
      
      var result = await _flutterTts.speak(currentSentence);
      if (result == 1) {
        print('✅ TTS speak command successful');
      } else {
        print('❌ TTS speak command failed with result: $result');
      }
    } catch (e) {
      print('❌ Error in TTS: $e');
    }
  }

  void _toggleBlinkDetection() {
    setState(() {
      _isBlinkDetectionEnabled = !_isBlinkDetectionEnabled;
      if (!_isBlinkDetectionEnabled) {
        // Reset blink detection state
        _blinkFrameCounter = 0;
        _isBlinking = false;
        print('🚫 Blink detection DISABLED');
      } else {
        print('✅ Blink detection ENABLED');
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _highlightTimer.cancel();
    _glowController.dispose();
    _cameraController?.dispose();
    _faceDetector?.close();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A0033),
              Color(0xFF0A0A0A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 30),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                            color: Colors.purple.withOpacity(_glowAnimation.value),
                            width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withOpacity(_glowAnimation.value * 0.3),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Text(
                        'EyeVoices',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Camera Preview
              if (_cameraController != null && _cameraController!.value.isInitialized)
                Container(
                  margin: const EdgeInsets.all(20),
                  child: Stack(
                    children: [
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: _isBlinkDetectionEnabled 
                                ? Colors.green 
                                : Colors.orange, 
                            width: 3
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: CameraPreview(_cameraController!),
                        ),
                      ),
                      if (_isBlinkDetectionEnabled)
                        const Positioned(
                          top: 10,
                          right: 10,
                          child: Icon(
                            Icons.remove_red_eye,
                            color: Colors.green,
                            size: 30,
                          ),
                        ),
                    ],
                  ),
                ),

              // Toggle Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ElevatedButton.icon(
                  onPressed: _toggleBlinkDetection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isBlinkDetectionEnabled 
                        ? Colors.green 
                        : Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  icon: Icon(_isBlinkDetectionEnabled 
                      ? Icons.visibility 
                      : Icons.visibility_off),
                  label: Text(
                    _isBlinkDetectionEnabled 
                        ? 'Blink Detection: ON' 
                        : 'Blink Detection: OFF',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Sentences List
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.purple.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Sentences',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 100, // Fixed height for horizontal wheel
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _sentences.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentHighlightIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            final isHighlighted = index == _currentHighlightIndex;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 10),
                              padding: const EdgeInsets.all(12),
                              transform: isHighlighted ? Matrix4.identity() : Matrix4.identity()..scale(0.9),
                              decoration: BoxDecoration(
                                gradient: isHighlighted
                                    ? LinearGradient(
                                        colors: [
                                          Colors.purple.withOpacity(0.6),
                                          Colors.purple.withOpacity(0.3),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : LinearGradient(
                                        colors: [
                                          Colors.white.withOpacity(0.08),
                                          Colors.white.withOpacity(0.03),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isHighlighted
                                      ? Colors.purple.withOpacity(0.8)
                                      : Colors.grey.withOpacity(0.2),
                                  width: isHighlighted ? 3 : 1,
                                ),
                                boxShadow: isHighlighted
                                    ? [
                                        BoxShadow(
                                          color: Colors.purple.withOpacity(0.4),
                                          blurRadius: 15,
                                          spreadRadius: 3,
                                          offset: const Offset(0, 5),
                                        ),
                                        BoxShadow(
                                          color: Colors.purple.withOpacity(0.2),
                                          blurRadius: 25,
                                          spreadRadius: 1,
                                          offset: const Offset(0, 8),
                                        ),
                                      ]
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 8,
                                          spreadRadius: 0,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: isHighlighted ? 30 : 22,
                                        height: isHighlighted ? 30 : 22,
                                        decoration: BoxDecoration(
                                          gradient: isHighlighted
                                              ? LinearGradient(
                                                  colors: [
                                                    Colors.purple.withOpacity(0.9),
                                                    Colors.purple.withOpacity(0.7),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                )
                                              : LinearGradient(
                                                  colors: [
                                                    Colors.grey.withOpacity(0.4),
                                                    Colors.grey.withOpacity(0.2),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                          shape: BoxShape.circle,
                                          boxShadow: isHighlighted
                                              ? [
                                                  BoxShadow(
                                                    color: Colors.purple.withOpacity(0.3),
                                                    blurRadius: 8,
                                                    spreadRadius: 1,
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: isHighlighted ? 14 : 10,
                                          ),
                                        ),
                                      ),
                                      if (isHighlighted) ...[
                                        const SizedBox(width: 15),
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.purple.withOpacity(0.3),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.volume_up,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _sentences[index],
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: isHighlighted ? 13 : 10,
                                      color: isHighlighted
                                          ? Colors.white
                                          : Colors.grey[400],
                                      fontWeight: isHighlighted
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 15),
                      // Page indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _sentences.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: index == _currentHighlightIndex ? 12 : 8,
                            height: index == _currentHighlightIndex ? 12 : 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index == _currentHighlightIndex
                                  ? Colors.purple
                                  : Colors.grey.withOpacity(0.4),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Status
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: _isBlinkDetectionEnabled ? Colors.green : Colors.orange,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isBlinkDetectionEnabled 
                          ? Icons.remove_red_eye 
                          : Icons.touch_app,
                      color: _isBlinkDetectionEnabled ? Colors.green : Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _isBlinkDetectionEnabled 
                          ? 'Blink to speak highlighted sentence'
                          : 'Blink detection disabled',
                      style: TextStyle(
                        color: _isBlinkDetectionEnabled ? Colors.green : Colors.orange,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
