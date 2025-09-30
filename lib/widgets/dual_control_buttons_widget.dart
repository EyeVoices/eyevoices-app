import 'package:flutter/material.dart';
import '../config/theme_extensions.dart';

class DualControlButtonsWidget extends StatelessWidget {
  final bool isBlinkDetectionEnabled;
  final bool isAutoPlayEnabled;
  final VoidCallback onToggleBlinkDetection;
  final VoidCallback onToggleAutoPlay;

  const DualControlButtonsWidget({
    super.key,
    required this.isBlinkDetectionEnabled,
    required this.isAutoPlayEnabled,
    required this.onToggleBlinkDetection,
    required this.onToggleAutoPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          // Blink Detection Button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onToggleBlinkDetection,
              style: ElevatedButton.styleFrom(
                backgroundColor: isBlinkDetectionEnabled
                    ? context.successGreen
                    : context.warningOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: Icon(
                isBlinkDetectionEnabled
                    ? Icons.visibility
                    : Icons.visibility_off,
                size: 18,
              ),
              label: Text(
                isBlinkDetectionEnabled ? 'Detection: ON' : 'Detection: OFF',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Auto-Play Button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onToggleAutoPlay,
              style: ElevatedButton.styleFrom(
                backgroundColor: isAutoPlayEnabled
                    ? context.focusBlue
                    : context.sentenceGray,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: Icon(
                isAutoPlayEnabled ? Icons.play_arrow : Icons.pause,
                size: 18,
              ),
              label: Text(
                isAutoPlayEnabled ? 'Auto-Play: ON' : 'Auto-Play: OFF',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
