import 'package:flutter/material.dart';
import 'package:mobile_app_project/Pages/UI/AppColors.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final CardVariant variant;
  final bool elevated;

  const CustomCard({
    Key? key,
    required this.child,
    this.padding,
    this.onTap,
    this.variant = CardVariant.default_,
    this.elevated = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(16),
        border: variant == CardVariant.outlined
            ? Border.all(color: AppColors.primaryOrange.withOpacity(0.2))
            : null,
        gradient: variant == CardVariant.gradient
            ? AppColors.gradientPrimary.scale(0.2)
            : null,
        boxShadow: elevated || variant == CardVariant.elevated
            ? [
                BoxShadow(
                  color: AppColors.primaryOrange.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      card = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: card,
      );
    }

    return card;
  }

  Color _getBackgroundColor() {
    switch (variant) {
      case CardVariant.outlined:
        return Colors.transparent;
      case CardVariant.gradient:
        return Colors.transparent;
      case CardVariant.elevated:
      case CardVariant.default_:
        return Colors.white;
    }
  }
}

enum CardVariant { default_, outlined, elevated, gradient }
