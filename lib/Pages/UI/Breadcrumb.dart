import 'package:flutter/material.dart';
import 'package:mobile_app_project/Pages/UI/AppColors.dart';

/// Main breadcrumb container
class Breadcrumb extends StatelessWidget {
  final List<CustomBreadcrumbItem> items;

  const Breadcrumb({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryOrange.withOpacity(0.2)),
      ),
      child: Row(
        children: List.generate(items.length * 2 - 1, (index) {
          if (index.isOdd) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Icon(
                Icons.chevron_right,
                size: 16,
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
            );
          }

          final itemIndex = index ~/ 2;
          final item = items[itemIndex];
          final isLast = itemIndex == items.length - 1;

          return GestureDetector(
            onTap: item.onTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.icon != null) ...[
                  Icon(
                    item.icon,
                    size: 16,
                    color: isLast
                        ? AppColors.primaryOrange
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isLast ? FontWeight.w600 : FontWeight.normal,
                    color: isLast
                        ? AppColors.primaryOrange
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
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

/// Custom breadcrumb item
class CustomBreadcrumbItem {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  CustomBreadcrumbItem({required this.label, this.icon, this.onTap});
}
