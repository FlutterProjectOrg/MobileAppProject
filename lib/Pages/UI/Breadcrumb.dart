import 'package:flutter/material.dart';

/// Main breadcrumb container
class Breadcrumb extends StatelessWidget {
  final List<Widget> children;

  const Breadcrumb({Key? key, required this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'breadcrumb',
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

/// List of breadcrumb items
class BreadcrumbList extends StatelessWidget {
  final List<Widget> children;
  final double gap;

  const BreadcrumbList({Key? key, required this.children, this.gap = 8.0})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: gap, runSpacing: gap / 2, children: children);
  }
}

/// Individual breadcrumb item
class BreadcrumbItem extends StatelessWidget {
  final Widget child;
  final double gap;

  const BreadcrumbItem({Key? key, required this.child, this.gap = 4.0})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [child]);
  }
}

/// Link inside breadcrumb
class BreadcrumbLink extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const BreadcrumbLink({Key? key, required this.child, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: DefaultTextStyle(
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          decoration: TextDecoration.underline,
        ),
        child: child,
      ),
    );
  }
}

/// Current page inside breadcrumb
class BreadcrumbPage extends StatelessWidget {
  final String text;

  const BreadcrumbPage({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: text,
      selected: true,
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge!.color,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
}

/// Separator between items
class BreadcrumbSeparator extends StatelessWidget {
  final Widget? child;

  const BreadcrumbSeparator({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: child ?? Icon(Icons.chevron_right, size: 16, color: Colors.grey),
    );
  }
}

/// Ellipsis for collapsed breadcrumbs
class BreadcrumbEllipsis extends StatelessWidget {
  const BreadcrumbEllipsis({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.more_horiz, size: 16, color: Colors.grey),
        Semantics(label: 'More', child: SizedBox.shrink()),
      ],
    );
  }
}
