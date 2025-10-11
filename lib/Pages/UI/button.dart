import 'package:flutter/material.dart';

enum ButtonVariant {
  defaultVariant,
  destructive,
  outline,
  secondary,
  ghost,
  link,
}

enum ButtonSize { defaultSize, sm, lg, icon }

class Button extends StatelessWidget {
  final ButtonVariant variant;
  final ButtonSize size;
  final VoidCallback? onPressed;
  final Widget? child;
  final bool asChild; // In Flutter, usually child is enough

  const Button({
    Key? key,
    this.variant = ButtonVariant.defaultVariant,
    this.size = ButtonSize.defaultSize,
    this.onPressed,
    this.child,
    this.asChild = false,
  }) : super(key: key);

  Color _backgroundColor(BuildContext context) {
    switch (variant) {
      case ButtonVariant.destructive:
        return Colors.red;
      case ButtonVariant.outline:
      case ButtonVariant.ghost:
        return Colors.transparent;
      case ButtonVariant.secondary:
        return Theme.of(context).colorScheme.secondary;
      case ButtonVariant.link:
        return Colors.transparent;
      case ButtonVariant.defaultVariant:
        return Theme.of(context).colorScheme.primary;
    }
  }

  Color _textColor(BuildContext context) {
    switch (variant) {
      case ButtonVariant.destructive:
        return Colors.white;
      case ButtonVariant.outline:
      case ButtonVariant.ghost:
        return Theme.of(context).textTheme.bodyLarge!.color!;
      case ButtonVariant.secondary:
        return Colors.white;
      case ButtonVariant.link:
        return Theme.of(context).colorScheme.primary;
      case ButtonVariant.defaultVariant:
        return Colors.white;
    }
  }

  EdgeInsetsGeometry _padding() {
    switch (size) {
      case ButtonSize.sm:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case ButtonSize.lg:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 10);
      case ButtonSize.icon:
        return const EdgeInsets.all(8);
      case ButtonSize.defaultSize:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    }
  }

  double _height() {
    switch (size) {
      case ButtonSize.sm:
        return 32;
      case ButtonSize.lg:
        return 40;
      case ButtonSize.icon:
        return 36;
      case ButtonSize.defaultSize:
        return 36;
    }
  }

  BorderSide? _border(BuildContext context) {
    if (variant == ButtonVariant.outline) {
      return BorderSide(color: Theme.of(context).dividerColor);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height(),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _backgroundColor(context),
          foregroundColor: _textColor(context),
          padding: _padding(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: _border(context) ?? BorderSide.none,
          ),
          elevation: 0,
        ),
        child: child,
      ),
    );
  }
}
