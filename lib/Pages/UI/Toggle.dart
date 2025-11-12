import 'package:flutter/material.dart';
import 'package:mobile_app_project/Pages/UI/AppColors.dart';

class Toggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? label;
  final IconData? icon;

  const Toggle({
    Key? key,
    required this.value,
    required this.onChanged,
    this.label,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: value ? AppColors.gradientPrimary : null,
          color: value ? null : AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: value
                ? Colors.transparent
                : AppColors.primaryOrange.withOpacity(0.3),
          ),
          boxShadow: value
              ? [
                  BoxShadow(
                    color: AppColors.primaryOrange.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: value ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
            ],
            if (label != null)
              Text(
                label!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: value ? Colors.white : AppColors.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
