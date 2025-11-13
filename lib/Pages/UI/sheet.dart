import 'package:flutter/material.dart';

enum SheetSide { top, bottom, left, right }

class Sheet extends StatelessWidget {
  final Widget child;
  final SheetSide side;
  final bool isOpen;
  final VoidCallback? onClose;

  const Sheet({
    Key? key,
    required this.child,
    this.side = SheetSide.right,
    this.isOpen = false,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isOpen) return SizedBox.shrink();

    return Stack(
      children: [
        // Overlay
        GestureDetector(
          onTap: onClose,
          child: Container(color: Colors.black54),
        ),
        // Sheet content
        Align(
          alignment: _getAlignment(),
          child: _SheetContent(side: side, onClose: onClose, child: child),
        ),
      ],
    );
  }

  Alignment _getAlignment() {
    switch (side) {
      case SheetSide.top:
        return Alignment.topCenter;
      case SheetSide.bottom:
        return Alignment.bottomCenter;
      case SheetSide.left:
        return Alignment.centerLeft;
      case SheetSide.right:
        return Alignment.centerRight;
    }
  }
}

class _SheetContent extends StatelessWidget {
  final Widget child;
  final SheetSide side;
  final VoidCallback? onClose;

  const _SheetContent({
    Key? key,
    required this.child,
    required this.side,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.75;
    double height = MediaQuery.of(context).size.height * 0.75;

    return Material(
      color: Theme.of(context).canvasColor,
      elevation: 24,
      child: Container(
        width: side == SheetSide.left || side == SheetSide.right
            ? width
            : double.infinity,
        height: side == SheetSide.top || side == SheetSide.bottom
            ? height
            : double.infinity,
        padding: EdgeInsets.all(16),
        child: Stack(
          children: [
            child,
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(icon: Icon(Icons.close), onPressed: onClose),
            ),
          ],
        ),
      ),
    );
  }
}
