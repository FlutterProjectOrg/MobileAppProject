import 'package:flutter/material.dart';

class Collapsible extends StatefulWidget {
  final Widget trigger;
  final Widget content;
  final bool initiallyExpanded;

  const Collapsible({
    Key? key,
    required this.trigger,
    required this.content,
    this.initiallyExpanded = false,
  }) : super(key: key);

  @override
  State<Collapsible> createState() => _CollapsibleState();
}

class _CollapsibleState extends State<Collapsible>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
      value: _isExpanded ? 1 : 0,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(onTap: _toggle, child: widget.trigger),
        SizeTransition(
          sizeFactor: _animation,
          axisAlignment: 1.0,
          child: widget.content,
        ),
      ],
    );
  }
}
