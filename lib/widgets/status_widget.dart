import 'package:flutter/material.dart';
import '../config/theme_extensions.dart';

class StatusWidget extends StatelessWidget {
  final bool isBlinkDetectionEnabled;

  const StatusWidget({super.key, required this.isBlinkDetectionEnabled});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: context.statusBackground,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isBlinkDetectionEnabled
              ? context.successGreen
              : context.warningOrange,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isBlinkDetectionEnabled ? Icons.remove_red_eye : Icons.touch_app,
            color: isBlinkDetectionEnabled
                ? context.successGreen
                : context.warningOrange,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            isBlinkDetectionEnabled
                ? 'Blink to speak highlighted sentence'
                : 'Blink detection disabled',
            style: TextStyle(
              color: isBlinkDetectionEnabled
                  ? context.successGreen
                  : context.warningOrange,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
