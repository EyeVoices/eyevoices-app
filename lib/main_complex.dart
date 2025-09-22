import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(const EyeVoicesApp());
}

class EyeVoicesApp extends StatelessWidget {
  const EyeVoicesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EyeVoices',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
      ),
      home: const EyeVoicesHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class EyeVoicesHome extends StatefulWidget {
  const EyeVoicesHome({super.key});

  @override
  State<EyeVoicesHome> createState() => _EyeVoicesHomeState();
}

class _EyeVoicesHomeState extends State<EyeVoicesHome>
    with TickerProviderStateMixin {
  late Timer _highlightTimer;
  int _currentHighlightIndex = 0;
  FlutterTts? _flutterTts;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  bool _isBlinkDetectionEnabled = false;

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
    _initializeAnimation();
    _startHighlightTimer();
    _initializeTts();
  }

  void _initializeTts() async {
    try {
      _flutterTts = FlutterTts();
      await _flutterTts?.setLanguage("en-US");
      await _flutterTts?.setPitch(1.0);
      await _flutterTts?.setSpeechRate(0.5);
    } catch (e) {
      if (kDebugMode) print('Error initializing TTS: $e');
    }
  }

  void _initializeAnimation() {
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    _glowController.repeat(reverse: true);
  }

  void _startHighlightTimer() {
    _highlightTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          _currentHighlightIndex = (_currentHighlightIndex + 1) % _sentences.length;
        });
      }
    });
  }

  void _toggleBlinkDetection() {
    setState(() {
      _isBlinkDetectionEnabled = !_isBlinkDetectionEnabled;
    });
    
    if (_isBlinkDetectionEnabled) {
      // Simulate blink detection for testing
      _simulateBlinkDetection();
    }
  }

  void _simulateBlinkDetection() {
    // For testing - simulate a blink every 5 seconds when enabled
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_isBlinkDetectionEnabled) {
        timer.cancel();
        return;
      }
      _speakCurrentSentence();
    });
  }

  void _speakCurrentSentence() async {
    try {
      String currentSentence = _sentences[_currentHighlightIndex];
      await _flutterTts?.speak(currentSentence);
      if (kDebugMode) print('🗣️ Speaking: $currentSentence');
    } catch (e) {
      if (kDebugMode) print('Error speaking: $e');
    }
  }

  @override
  void dispose() {
    _highlightTimer.cancel();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              Color(0xFF1A0B2E),
              Color(0xFF16213E),
              Color(0xFF0F0F0F),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                margin: const EdgeInsets.all(24),
                child: AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.purple.withOpacity(_glowAnimation.value),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withOpacity(_glowAnimation.value * 0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Text(
                        'EyeVoices',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 3,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Camera placeholder
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isBlinkDetectionEnabled 
                        ? Colors.green 
                        : Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.white54,
                          size: 32,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Camera Coming Soon',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Toggle button
              Container(
                margin: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _toggleBlinkDetection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isBlinkDetectionEnabled 
                        ? Colors.green 
                        : Colors.grey,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    _isBlinkDetectionEnabled 
                        ? 'Simulated Detection ON' 
                        : 'Simulated Detection OFF',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              
              // Sentences Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                    ),
                    itemCount: _sentences.length,
                    itemBuilder: (context, index) {
                      final isHighlighted = index == _currentHighlightIndex;
                      
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isHighlighted 
                                ? Colors.cyanAccent 
                                : Colors.white.withOpacity(0.1),
                            width: isHighlighted ? 3 : 1,
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isHighlighted
                                ? [
                                    Colors.cyanAccent.withOpacity(0.2),
                                    Colors.purple.withOpacity(0.2),
                                  ]
                                : [
                                    Colors.white.withOpacity(0.05),
                                    Colors.white.withOpacity(0.02),
                                  ],
                          ),
                          boxShadow: isHighlighted
                              ? [
                                  BoxShadow(
                                    color: Colors.cyanAccent.withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : [],
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              _sentences[index],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isHighlighted ? 16 : 14,
                                fontWeight: isHighlighted 
                                    ? FontWeight.w500 
                                    : FontWeight.w300,
                                color: isHighlighted 
                                    ? Colors.cyanAccent 
                                    : Colors.white.withOpacity(0.8),
                                letterSpacing: 0.5,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              // Status indicator
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withOpacity(0.1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _isBlinkDetectionEnabled ? Colors.green : Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isBlinkDetectionEnabled 
                          ? 'Simulated detection active' 
                          : 'Tap button to test TTS',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        letterSpacing: 1,
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
