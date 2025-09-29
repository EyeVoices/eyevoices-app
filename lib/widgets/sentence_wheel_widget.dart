import 'package:flutter/material.dart';

class SentenceWheelWidget extends StatelessWidget {
  final List<String> sentences;
  final int currentHighlightIndex;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;

  const SentenceWheelWidget({
    super.key,
    required this.sentences,
    required this.currentHighlightIndex,
    required this.pageController,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          const Text(
            'Sentences',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 100,
            child: PageView.builder(
              controller: pageController,
              itemCount: sentences.length,
              onPageChanged: onPageChanged,
              itemBuilder: (context, index) {
                return _buildSentenceCard(index);
              },
            ),
          ),
          const SizedBox(height: 15),
          _buildPageIndicators(),
        ],
      ),
    );
  }

  Widget _buildSentenceCard(int index) {
    final isHighlighted = index == currentHighlightIndex;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(12),
      transform: isHighlighted ? Matrix4.identity() : Matrix4.identity()
        ..scale(0.9),
      decoration: BoxDecoration(
        gradient: isHighlighted
            ? LinearGradient(
                colors: [
                  Colors.purple.withOpacity(0.6),
                  Colors.purple.withOpacity(0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [
                  Colors.grey.withOpacity(0.08),
                  Colors.grey.withOpacity(0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHighlighted
              ? Colors.purple.withOpacity(0.8)
              : Colors.grey.withOpacity(0.2),
          width: isHighlighted ? 3 : 1,
        ),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 3,
                  offset: const Offset(0, 5),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSentenceNumber(index, isHighlighted),
              if (isHighlighted) ...[
                const SizedBox(width: 15),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.volume_up,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            sentences[index],
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isHighlighted ? 13 : 10,
              color: isHighlighted ? Colors.white : Colors.grey[600],
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentenceNumber(int index, bool isHighlighted) {
    return Container(
      width: isHighlighted ? 30 : 22,
      height: isHighlighted ? 30 : 22,
      decoration: BoxDecoration(
        gradient: isHighlighted
            ? LinearGradient(
                colors: [
                  Colors.purple.withOpacity(0.9),
                  Colors.purple.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [
                  Colors.grey.withOpacity(0.4),
                  Colors.grey.withOpacity(0.2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        shape: BoxShape.circle,
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          '${index + 1}',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isHighlighted ? 14 : 10,
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        sentences.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == currentHighlightIndex ? 12 : 8,
          height: index == currentHighlightIndex ? 12 : 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == currentHighlightIndex
                ? Colors.purple
                : Colors.grey.withOpacity(0.4),
          ),
        ),
      ),
    );
  }
}
