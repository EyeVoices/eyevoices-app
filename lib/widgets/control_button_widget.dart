import 'package:flutter/material.dart';
import '../config/theme_extensions.dart';

class ControlButtonWidget extends StatelessWidget {
  final bool isBlinkDetectionEnabled;
  final VoidCallback onToggle;

  const ControlButtonWidget({
    super.key,
    required this.isBlinkDetectionEnabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: ElevatedButton.icon(
        onPressed: onToggle,
        style: ElevatedButton.styleFrom(
          backgroundColor: isBlinkDetectionEnabled
              ? context.successGreen
              : context.warningOrange,
          foregroundColor: context.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        icon: Icon(
          isBlinkDetectionEnabled ? Icons.visibility : Icons.visibility_off,
        ),
        label: Text(
          isBlinkDetectionEnabled
              ? 'Blink Detection: ON'
              : 'Blink Detection: OFF',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
