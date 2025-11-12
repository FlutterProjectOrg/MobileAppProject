import 'package:flutter/material.dart';
import 'package:mobile_app_project/Pages/UI/AppColors.dart';

class CustomAspectRatio extends StatelessWidget {
  final Widget child;
  final double ratio;
  final BoxFit fit;

  const CustomAspectRatio({
    Key? key,
    required this.child,
    this.ratio = 16 / 9,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: ratio,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryOrange.withOpacity(0.2)),
        ),
        clipBehavior: Clip.antiAlias,
        child: FittedBox(fit: fit, child: child),
      ),
    );
  }
}
