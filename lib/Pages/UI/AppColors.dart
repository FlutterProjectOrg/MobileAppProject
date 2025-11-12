import 'package:flutter/material.dart';

class AppColors {
  // Gradient principal (orange/jaune)
  static const primaryOrange = Color(0xFFFF6B35);
  static const primaryOrangeMid = Color(0xFFFF8E53);
  static const primaryYellow = Color(0xFFF7B731);

  // Couleurs de base
  static const background = Color(0xFFFAFAFA);
  static const cardBackground = Colors.white;
  static const textPrimary = Color(0xFF1F2937);
  static const textSecondary = Color(0xFF6B7280);

  // Gradient
  static const gradientPrimary = LinearGradient(
    colors: [primaryOrange, primaryOrangeMid, primaryYellow],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientSecondary = LinearGradient(
    colors: [Color(0xFFF3F4F6), Color(0xFFE5E7EB)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

// Extension pour scale gradient
extension GradientScale on Gradient {
  Gradient scale(double factor) {
    if (this is LinearGradient) {
      final linear = this as LinearGradient;
      return LinearGradient(
        colors: linear.colors
            .map((c) => Color.lerp(Colors.white, c, factor)!)
            .toList(),
        begin: linear.begin,
        end: linear.end,
      );
    }
    return this;
  }
}
