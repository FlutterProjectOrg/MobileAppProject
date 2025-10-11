import 'package:flutter/material.dart';

class Pagination extends StatelessWidget {
  final List<Widget> children;
  const Pagination({Key? key, required this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

class PaginationContent extends StatelessWidget {
  final List<Widget> children;
  const PaginationContent({Key? key, required this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }
}

class PaginationItem extends StatelessWidget {
  final Widget child;
  const PaginationItem({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: child,
    );
  }
}

class PaginationLink extends StatelessWidget {
  final bool isActive;
  final VoidCallback? onPressed;
  final Widget child;

  const PaginationLink({
    Key? key,
    required this.child,
    this.isActive = false,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Colors.transparent : Colors.grey.shade200,
        foregroundColor: isActive
            ? Theme.of(context).colorScheme.primary
            : Colors.black,
        side: isActive
            ? BorderSide(color: Theme.of(context).colorScheme.primary)
            : null,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: const Size(40, 40),
      ),
      child: child,
    );
  }
}

class PaginationPrevious extends StatelessWidget {
  final VoidCallback? onPressed;
  const PaginationPrevious({Key? key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PaginationLink(
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.chevron_left),
          SizedBox(width: 4),
          Text('Previous'),
        ],
      ),
    );
  }
}

class PaginationNext extends StatelessWidget {
  final VoidCallback? onPressed;
  const PaginationNext({Key? key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PaginationLink(
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text('Next'),
          SizedBox(width: 4),
          Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}

class PaginationEllipsis extends StatelessWidget {
  const PaginationEllipsis({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 40,
      height: 40,
      child: Center(child: Icon(Icons.more_horiz)),
    );
  }
}
