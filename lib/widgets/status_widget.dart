import 'package:flutter/material.dart';

class StatusWidget extends StatelessWidget {
  final bool isBlinkDetectionEnabled;

  const StatusWidget({super.key, required this.isBlinkDetectionEnabled});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isBlinkDetectionEnabled ? Colors.green : Colors.orange,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isBlinkDetectionEnabled ? Icons.remove_red_eye : Icons.touch_app,
            color: isBlinkDetectionEnabled ? Colors.green : Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            isBlinkDetectionEnabled
                ? 'Blink to speak highlighted sentence'
                : 'Blink detection disabled',
            style: TextStyle(
              color: isBlinkDetectionEnabled ? Colors.green : Colors.orange,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
