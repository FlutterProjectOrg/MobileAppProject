import 'package:flutter/material.dart';

/// Card container
class CardWidget extends StatelessWidget {
  final Widget? child;

  const CardWidget({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: child,
    );
  }
}

/// Card header
class CardHeader extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry padding;

  const CardHeader({
    Key? key,
    this.child,
    this.padding = const EdgeInsets.fromLTRB(24, 24, 24, 0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(padding: padding, child: child);
  }
}

/// Card title
class CardTitle extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const CardTitle({Key? key, required this.text, this.style}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: style ?? Theme.of(context).textTheme.titleLarge);
  }
}

/// Card description
class CardDescription extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const CardDescription({Key? key, required this.text, this.style})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:
          style ??
          Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
    );
  }
}

/// Card content
class CardContent extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry padding;

  const CardContent({
    Key? key,
    this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(padding: padding, child: child);
  }
}

/// Card action
class CardAction extends StatelessWidget {
  final Widget? child;

  const CardAction({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(alignment: Alignment.topRight, child: child);
  }
}

/// Card footer
class CardFooter extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry padding;

  const CardFooter({
    Key? key,
    this.child,
    this.padding = const EdgeInsets.fromLTRB(24, 12, 24, 24),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(padding: padding, child: child);
  }
}
