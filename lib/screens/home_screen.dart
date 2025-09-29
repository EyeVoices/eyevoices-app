import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/tts_service.dart';
import '../services/camera_service.dart';
import '../widgets/camera_preview_widget.dart';
import '../widgets/sentence_wheel_widget.dart';
import '../widgets/header_widget.dart';
import '../widgets/control_button_widget.dart';
import '../widgets/status_widget.dart';

class HomeScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const HomeScreen({super.key, required this.cameras});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late Timer _highlightTimer;
  int _currentHighlightIndex = 0;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late PageController _pageController;

  late TTSService _ttsService;
  late CameraService _cameraService;
  bool _isBlinkDetectionEnabled = true;

  final List<String> _sentences = [
    "Hello, how are you today?",
    "I would like some water please.",
    "Can you help me with this?",
    "Thank you very much.",
    "I need to go to the bathroom.",
    "I'm feeling tired now.",
    "What time is it?",
    "Good morning everyone.",
  ];

  @override
  void initState() {
    super.initState();
    _initializeComponents();
  }

  void _initializeComponents() {
    _pageController = PageController(viewportFraction: 0.8, initialPage: 0);

    _ttsService = TTSService();
    _cameraService = CameraService(
      cameras: widget.cameras,
      onBlinkDetected: _onBlinkDetected,
    );

    _initializeAnimation();
    _initializeServices();
    _startHighlightTimer();
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

  Future<void> _initializeServices() async {
    await _ttsService.initialize();
    await _cameraService.initialize();
    if (mounted) setState(() {});
  }

  void _startHighlightTimer() {
    _highlightTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _currentHighlightIndex =
            (_currentHighlightIndex + 1) % _sentences.length;
      });

      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && _pageController.hasClients) {
          _pageController.animateToPage(
            _currentHighlightIndex,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    });
  }

  void _onBlinkDetected() async {
    if (_isBlinkDetectionEnabled) {
      String currentSentence = _sentences[_currentHighlightIndex];
      await _ttsService.speak(currentSentence);
    }
  }

  void _toggleBlinkDetection() {
    setState(() {
      _isBlinkDetectionEnabled = !_isBlinkDetectionEnabled;
      _cameraService.setDetectionEnabled(_isBlinkDetectionEnabled);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _highlightTimer.cancel();
    _glowController.dispose();
    _cameraService.dispose();
    _ttsService.dispose();
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
            colors: [Color(0xFF1A0033), Color(0xFF0A0A0A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              HeaderWidget(glowAnimation: _glowAnimation),

              CameraPreviewWidget(
                cameraService: _cameraService,
                isBlinkDetectionEnabled: _isBlinkDetectionEnabled,
              ),

              ControlButtonWidget(
                isBlinkDetectionEnabled: _isBlinkDetectionEnabled,
                onToggle: _toggleBlinkDetection,
              ),

              const SizedBox(height: 30),

              Expanded(
                child: SentenceWheelWidget(
                  sentences: _sentences,
                  currentHighlightIndex: _currentHighlightIndex,
                  pageController: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentHighlightIndex = index;
                    });
                  },
                ),
              ),

              StatusWidget(isBlinkDetectionEnabled: _isBlinkDetectionEnabled),
            ],
          ),
        ),
      ),
    );
  }
}
