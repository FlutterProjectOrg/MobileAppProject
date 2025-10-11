import 'package:flutter/material.dart';

enum BadgeVariant { defaultVariant, secondary, destructive, outline }

class Badge extends StatelessWidget {
  final BadgeVariant variant;
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  final bool asChild;

  const Badge({
    Key? key,
    this.variant = BadgeVariant.defaultVariant,
    this.child,
    this.padding,
    this.borderRadius,
    this.asChild = false,
  }) : super(key: key);

  Color _backgroundColor(BuildContext context) {
    switch (variant) {
      case BadgeVariant.secondary:
        return Theme.of(context).colorScheme.secondary;
      case BadgeVariant.destructive:
        return Colors.red;
      case BadgeVariant.outline:
        return Colors.transparent;
      case BadgeVariant.defaultVariant:
        return Theme.of(context).colorScheme.primary;
    }
  }

  Color _textColor(BuildContext context) {
    switch (variant) {
      case BadgeVariant.secondary:
        return Colors.white;
      case BadgeVariant.destructive:
        return Colors.white;
      case BadgeVariant.outline:
        return Theme.of(context).textTheme.bodyLarge!.color!;
      case BadgeVariant.defaultVariant:
        return Colors.white;
    }
  }

  BoxBorder? _border(BuildContext context) {
    switch (variant) {
      case BadgeVariant.outline:
        return Border.all(color: Theme.of(context).dividerColor);
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = child ?? const SizedBox.shrink();

    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _backgroundColor(context),
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        border: _border(context),
      ),
      child: DefaultTextStyle(
        style: TextStyle(
          color: _textColor(context),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        child: content,
      ),
    );
  }
}
