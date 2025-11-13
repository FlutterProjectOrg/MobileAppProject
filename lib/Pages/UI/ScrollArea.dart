import 'package:flutter/material.dart';

class ScrollArea extends StatelessWidget {
  final Widget child;
  final Axis scrollDirection;

  const ScrollArea({
    Key? key,
    required this.child,
    this.scrollDirection = Axis.vertical,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: _CustomScrollBehavior(),
      child: SingleChildScrollView(
        scrollDirection: scrollDirection,
        child: child,
      ),
    );
  }
}

/// Comportement personnalisé pour cacher le glow par défaut
class _CustomScrollBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return _CustomScrollBar(child: child, details: details);
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

class _CustomScrollBar extends StatelessWidget {
  final Widget child;
  final ScrollableDetails details;

  const _CustomScrollBar({Key? key, required this.child, required this.details})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: details.controller,
      thumbVisibility: true,
      thickness: 8,
      radius: const Radius.circular(10),
      child: child,
    );
  }
}
