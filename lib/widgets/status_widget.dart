import 'package:flutter/material.dart';
import '../config/theme_extensions.dart';

class StatusWidget extends StatelessWidget {
  final bool isBlinkDetectionEnabled;
  final bool isAutoPlayEnabled;

  const StatusWidget({
    super.key,
    required this.isBlinkDetectionEnabled,
    this.isAutoPlayEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    String statusText;
    if (!isBlinkDetectionEnabled) {
      statusText = 'Blink detection disabled';
    } else if (isAutoPlayEnabled) {
      statusText = 'Double-blink to speak • Auto-play: ON';
    } else {
      statusText = 'Left/Right eye: navigate • Double-blink: speak';
    }

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
          Flexible(
            child: Text(
              statusText,
              style: TextStyle(
                color: isBlinkDetectionEnabled
                    ? context.successGreen
                    : context.warningOrange,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
