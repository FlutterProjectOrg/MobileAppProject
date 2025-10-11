import 'package:flutter/material.dart';

class CustomToggleGroup extends StatefulWidget {
  final List<Widget> children;
  final List<bool>? isSelected;
  final ValueChanged<int>? onPressed;
  final double borderRadius;
  final double spacing;

  const CustomToggleGroup({
    Key? key,
    required this.children,
    this.isSelected,
    this.onPressed,
    this.borderRadius = 8,
    this.spacing = 4,
  }) : super(key: key);

  @override
  _CustomToggleGroupState createState() => _CustomToggleGroupState();
}

class _CustomToggleGroupState extends State<CustomToggleGroup> {
  late List<bool> _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.isSelected ?? List.filled(widget.children.length, false);
  }

  void _handlePressed(int index) {
    setState(() {
      _selected = List.filled(_selected.length, false);
      _selected[index] = true;
    });
    widget.onPressed?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: widget.spacing,
      children: List.generate(widget.children.length, (index) {
        final isActive = _selected[index];
        return GestureDetector(
          onTap: () => _handlePressed(index),
          child: Container(
            decoration: BoxDecoration(
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              border: Border.all(color: Theme.of(context).colorScheme.primary),
              borderRadius: BorderRadius.horizontal(
                left: index == 0
                    ? Radius.circular(widget.borderRadius)
                    : Radius.zero,
                right: index == widget.children.length - 1
                    ? Radius.circular(widget.borderRadius)
                    : Radius.zero,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DefaultTextStyle(
              style: TextStyle(
                color: isActive
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
              ),
              child: widget.children[index],
            ),
          ),
        );
      }),
    );
  }
}
