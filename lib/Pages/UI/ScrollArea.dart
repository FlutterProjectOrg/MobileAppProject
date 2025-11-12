import 'package:flutter/material.dart';
import 'package:mobile_app_project/Pages/UI/AppColors.dart';

class ScrollArea extends StatelessWidget {
  final Widget child;
  final double? maxHeight;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;

  const ScrollArea({
    Key? key,
    required this.child,
    this.maxHeight,
    this.padding,
    this.physics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: maxHeight != null
          ? BoxConstraints(maxHeight: maxHeight!)
          : null,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryOrange.withOpacity(0.2)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Scrollbar(
          thumbVisibility: true,
          thickness: 6,
          radius: const Radius.circular(3),
          child: SingleChildScrollView(
            padding: padding ?? const EdgeInsets.all(16),
            physics: physics,
            child: child,
          ),
        ),
      ),
    );
  }
}
