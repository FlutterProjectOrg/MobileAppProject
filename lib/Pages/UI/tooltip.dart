import 'package:flutter/material.dart';

class CustomTooltip extends StatelessWidget {
  final Widget child;
  final String message;
  final Duration showDuration;
  final EdgeInsets padding;
  final double verticalOffset;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  const CustomTooltip({
    Key? key,
    required this.child,
    required this.message,
    this.showDuration = const Duration(seconds: 2),
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.verticalOffset = 0,
    this.textStyle,
    this.backgroundColor,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      waitDuration: const Duration(milliseconds: 0),
      showDuration: showDuration,
      verticalOffset: verticalOffset,
      padding: padding,
      textStyle:
          textStyle ?? const TextStyle(color: Colors.white, fontSize: 12),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.blue,
        borderRadius: borderRadius ?? BorderRadius.circular(6),
      ),
      child: child,
    );
  }
}
