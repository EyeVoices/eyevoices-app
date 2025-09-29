import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  final Animation<double> glowAnimation;

  const HeaderWidget({super.key, required this.glowAnimation});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: AnimatedBuilder(
        animation: glowAnimation,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.purple.withOpacity(glowAnimation.value),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(glowAnimation.value * 0.3),
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
    );
  }
}
