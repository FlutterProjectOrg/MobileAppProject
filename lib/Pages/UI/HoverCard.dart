import 'package:flutter/material.dart';

class HoverCard extends StatefulWidget {
  final Widget trigger;
  final Widget content;
  final Alignment align;
  final double sideOffset;

  const HoverCard({
    super.key,
    required this.trigger,
    required this.content,
    this.align = Alignment.center,
    this.sideOffset = 4.0,
  });

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  void _showHoverCard() {
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 256, // équivalent à w-64
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: Offset(0, widget.sideOffset),
          showWhenUnlinked: false,
          child: Material(
            color: Colors.white,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: widget.content,
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideHoverCard() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _showHoverCard(),
      onExit: (_) => _hideHoverCard(),
      child: CompositedTransformTarget(link: _layerLink, child: widget.trigger),
    );
  }
}
