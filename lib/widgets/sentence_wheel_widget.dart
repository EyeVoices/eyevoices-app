import 'package:flutter/material.dart';

class SentenceWheelWidget extends StatelessWidget {
  final List<String> sentences;
  final int currentHighlightIndex;
  final int? selectedIndex; // Für grüne Hervorhebung nach Blink

  const SentenceWheelWidget({
    super.key,
    required this.sentences,
    required this.currentHighlightIndex,
    this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 2.0,
        ),
        itemCount: sentences.length,
        itemBuilder: (context, index) {
          return _buildSentenceCard(index);
        },
      ),
    );
  }

  Widget _buildSentenceCard(int index) {
    final isHighlighted = index == currentHighlightIndex;
    final isSelected = index == selectedIndex;

    Color borderColor;
    Color backgroundColor;
    List<BoxShadow> shadows;

    if (isSelected) {
      // Grün für ausgewählt (nach Blink)
      borderColor = Colors.green;
      backgroundColor = Colors.green.withOpacity(0.1);
      shadows = [
        BoxShadow(
          color: Colors.green.withOpacity(0.3),
          blurRadius: 8,
          spreadRadius: 2,
        ),
      ];
    } else if (isHighlighted) {
      // Blau mit Glow für aktuell fokussiert
      borderColor = Colors.blue;
      backgroundColor = Colors.blue.withOpacity(0.05);
      shadows = [
        BoxShadow(
          color: Colors.blue.withOpacity(0.4),
          blurRadius: 12,
          spreadRadius: 3,
        ),
      ];
    } else {
      // Grau für normal
      borderColor = Colors.grey.withOpacity(0.3);
      backgroundColor = Colors.grey.withOpacity(0.05);
      shadows = [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          blurRadius: 4,
          spreadRadius: 0,
          offset: const Offset(0, 2),
        ),
      ];
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: borderColor,
          width: isHighlighted || isSelected ? 2 : 1,
        ),
        boxShadow: shadows,
      ),
      child: Center(
        child: Text(
          sentences[index],
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
        ),
      ),
    );
  }
}
