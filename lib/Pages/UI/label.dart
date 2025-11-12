import 'package:flutter/material.dart';
import 'package:mobile_app_project/Pages/UI/AppColors.dart';

class Label extends StatelessWidget {
  final String text;
  final bool required;
  final String? tooltip;

  const Label({
    Key? key,
    required this.text,
    this.required = false,
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (required)
          const Text(
            ' *',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
        if (tooltip != null) ...[
          const SizedBox(width: 4),
          Tooltip(
            message: tooltip!,
            child: Icon(
              Icons.help_outline,
              size: 16,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
          ),
        ],
      ],
    );
  }
}
