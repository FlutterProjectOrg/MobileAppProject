import 'package:flutter/material.dart';
import 'package:mobile_app_project/Pages/UI/AppColors.dart';

class Separator extends StatelessWidget {
  final String? label;
  final bool vertical;
  final double? height;
  final double? width;

  const Separator({
    Key? key,
    this.label,
    this.vertical = false,
    this.height,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (vertical) {
      return SizedBox(
        height: height ?? double.infinity,
        child: VerticalDivider(
          width: width ?? 1,
          thickness: 1,
          color: AppColors.primaryOrange.withOpacity(0.2),
        ),
      );
    }

    if (label != null) {
      return Row(
        children: [
          Expanded(
            child: Divider(
              color: AppColors.primaryOrange.withOpacity(0.2),
              thickness: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              label!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: AppColors.primaryOrange.withOpacity(0.2),
              thickness: 1,
            ),
          ),
        ],
      );
    }

    return Divider(
      height: height ?? 1,
      thickness: 1,
      color: AppColors.primaryOrange.withOpacity(0.2),
    );
  }
}
