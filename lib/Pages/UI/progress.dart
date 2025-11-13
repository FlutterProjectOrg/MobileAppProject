import 'package:flutter/material.dart';

class Progress extends StatelessWidget {
  final double value; // Valeur de 0.0 à 100.0
  final double height;
  final Color backgroundColor;
  final Color foregroundColor;

  const Progress({
    Key? key,
    required this.value,
    this.height = 8.0,
    this.backgroundColor = const Color(0xFFB3D4FC), // équivalent bg-primary/20
    this.foregroundColor = const Color(0xFF3B82F6), // équivalent bg-primary
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: Stack(
        children: [
          Container(height: height, color: backgroundColor),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: height,
            width:
                value.clamp(0, 100) / 100 * MediaQuery.of(context).size.width,
            color: foregroundColor,
          ),
        ],
      ),
    );
  }
}
