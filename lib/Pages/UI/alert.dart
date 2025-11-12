import 'package:flutter/material.dart';
import 'package:mobile_app_project/Pages/UI/AppColors.dart';

class Alert extends StatelessWidget {
  final String title;
  final String? description;
  final AlertVariant variant;
  final IconData? icon;
  final VoidCallback? onClose;

  const Alert({
    Key? key,
    required this.title,
    this.description,
    this.variant = AlertVariant.info,
    this.icon,
    this.onClose,
  }) : super(key: key);

  Color _getVariantColor() {
    switch (variant) {
      case AlertVariant.success:
        return AppColors.primaryOrange;
      case AlertVariant.warning:
        return AppColors.primaryYellow;
      case AlertVariant.error:
        return Colors.red;
      case AlertVariant.info:
        return AppColors.primaryOrange;
    }
  }

  IconData _getVariantIcon() {
    if (icon != null) return icon!;
    switch (variant) {
      case AlertVariant.success:
        return Icons.check_circle_outline;
      case AlertVariant.warning:
        return Icons.warning_amber_outlined;
      case AlertVariant.error:
        return Icons.error_outline;
      case AlertVariant.info:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final variantColor = _getVariantColor();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: variantColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: variantColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_getVariantIcon(), color: variantColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: variantColor,
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    description!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onClose != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onClose,
              child: Icon(Icons.close, color: variantColor, size: 18),
            ),
          ],
        ],
      ),
    );
  }
}

enum AlertVariant { success, warning, error, info }
