import 'package:flutter/material.dart';

class NavigationMenu extends StatelessWidget {
  final List<Widget> children;
  const NavigationMenu({Key? key, required this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }
}

class NavigationMenuItem extends StatelessWidget {
  final Widget trigger;
  final Widget content;

  const NavigationMenuItem({
    Key? key,
    required this.trigger,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _NavigationMenuItemWrapper(trigger: trigger, content: content);
  }
}

class _NavigationMenuItemWrapper extends StatefulWidget {
  final Widget trigger;
  final Widget content;

  const _NavigationMenuItemWrapper({
    Key? key,
    required this.trigger,
    required this.content,
  }) : super(key: key);

  @override
  State<_NavigationMenuItemWrapper> createState() =>
      _NavigationMenuItemWrapperState();
}

class _NavigationMenuItemWrapperState
    extends State<_NavigationMenuItemWrapper> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  void _toggleOverlay() {
    setState(() {
      if (_isOpen) {
        _overlayEntry?.remove();
        _overlayEntry = null;
        _isOpen = false;
      } else {
        _overlayEntry = _createOverlay();
        Overlay.of(context).insert(_overlayEntry!);
        _isOpen = true;
      }
    });
  }

  OverlayEntry _createOverlay() {
    return OverlayEntry(
      builder: (context) => Positioned(
        width: 200,
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: const Offset(0, 40),
          showWhenUnlinked: false,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(6),
            color: Theme.of(context).colorScheme.surface,
            child: widget.content,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(onTap: _toggleOverlay, child: widget.trigger),
    );
  }
}

class NavigationMenuTrigger extends StatelessWidget {
  final String label;
  const NavigationMenuTrigger({Key? key, required this.label})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_drop_down, size: 20),
        ],
      ),
    );
  }
}

class NavigationMenuContent extends StatelessWidget {
  final List<Widget> children;
  const NavigationMenuContent({Key? key, required this.children})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

class NavigationMenuLink extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const NavigationMenuLink({Key? key, required this.label, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      hoverColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(label, style: const TextStyle(fontSize: 14)),
      ),
    );
  }
}

class NavigationMenuIndicator extends StatelessWidget {
  const NavigationMenuIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      transform: Matrix4.rotationZ(45 * 3.1415927 / 180),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
    );
  }
}
