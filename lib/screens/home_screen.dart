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
  int? _selectedIndex; // Für grüne Hervorhebung

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
    _ttsService = TTSService();
    _cameraService = CameraService(
      cameras: widget.cameras,
      onBlinkDetected: _onBlinkDetected,
    );

    _initializeServices();
    _startHighlightTimer();
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
    });
  }

  void _onBlinkDetected() async {
    if (_isBlinkDetectionEnabled) {
      String currentSentence = _sentences[_currentHighlightIndex];
      await _ttsService.speak(currentSentence);

      // Setze grüne Hervorhebung für ausgewählten Satz
      setState(() {
        _selectedIndex = _currentHighlightIndex;
      });

      // Entferne grüne Hervorhebung nach 2 Sekunden
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _selectedIndex = null;
          });
        }
      });
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
    _highlightTimer.cancel();
    _cameraService.dispose();
    _ttsService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const HeaderWidget(),

            const SizedBox(height: 10),

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
                selectedIndex: _selectedIndex,
              ),
            ),

            StatusWidget(isBlinkDetectionEnabled: _isBlinkDetectionEnabled),
          ],
        ),
      ),
    );
  }
}
