import 'package:flutter/material.dart';

enum ToggleVariant { defaultVariant, outline }

enum ToggleSize { sm, defaultSize, lg }

class Toggle extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final ToggleVariant variant;
  final ToggleSize size;
  final Widget? child;

  const Toggle({
    Key? key,
    this.value = false,
    this.onChanged,
    this.variant = ToggleVariant.defaultVariant,
    this.size = ToggleSize.defaultSize,
    this.child,
  }) : super(key: key);

  @override
  _ToggleState createState() => _ToggleState();
}

class _ToggleState extends State<Toggle> {
  late bool _isOn;

  @override
  void initState() {
    super.initState();
    _isOn = widget.value;
  }

  void _toggle() {
    setState(() {
      _isOn = !_isOn;
    });
    widget.onChanged?.call(_isOn);
  }

  double get _height {
    switch (widget.size) {
      case ToggleSize.sm:
        return 32;
      case ToggleSize.defaultSize:
        return 36;
      case ToggleSize.lg:
        return 40;
    }
  }

  EdgeInsets get _padding {
    switch (widget.size) {
      case ToggleSize.sm:
        return const EdgeInsets.symmetric(horizontal: 6);
      case ToggleSize.defaultSize:
        return const EdgeInsets.symmetric(horizontal: 8);
      case ToggleSize.lg:
        return const EdgeInsets.symmetric(horizontal: 10);
    }
  }

  BoxDecoration get _decoration {
    switch (widget.variant) {
      case ToggleVariant.outline:
        return BoxDecoration(
          color: _isOn ? Colors.blue : Colors.transparent,
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(8),
        );
      case ToggleVariant.defaultVariant:
        return BoxDecoration(
          color: _isOn ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        );
    }
  }

  TextStyle get _textStyle {
    return TextStyle(
      color: _isOn ? Colors.white : Colors.black,
      fontSize: widget.size == ToggleSize.sm
          ? 12
          : widget.size == ToggleSize.lg
          ? 16
          : 14,
      fontWeight: FontWeight.w500,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: Container(
        height: _height,
        padding: _padding,
        decoration: _decoration,
        alignment: Alignment.center,
        child: DefaultTextStyle(
          style: _textStyle,
          child: widget.child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}
