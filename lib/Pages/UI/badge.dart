import 'package:flutter/material.dart';
import 'package:mobile_app_project/Pages/UI/AppColors.dart';

class Badge extends StatelessWidget {
  final String label;
  final BadgeVariant variant;
  final IconData? icon;

  const Badge({
    Key? key,
    required this.label,
    this.variant = BadgeVariant.primary,
    this.icon,
  }) : super(key: key);

  Color _getBackgroundColor() {
    switch (variant) {
      case BadgeVariant.primary:
        return AppColors.primaryOrange;
      case BadgeVariant.secondary:
        return AppColors.primaryYellow;
      case BadgeVariant.success:
        return AppColors.primaryOrange;
      case BadgeVariant.warning:
        return AppColors.primaryYellow;
      case BadgeVariant.error:
        return Colors.red;
      case BadgeVariant.outline:
        return Colors.transparent;
    }
  }

  Color _getTextColor() {
    switch (variant) {
      case BadgeVariant.outline:
        return AppColors.primaryOrange;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(6),
        border: variant == BadgeVariant.outline
            ? Border.all(color: AppColors.primaryOrange)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: _getTextColor()),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _getTextColor(),
            ),
          ),
        ],
      ),
    );
  }
}

enum BadgeVariant { primary, secondary, success, warning, error, outline }
