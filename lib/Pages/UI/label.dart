import 'package:flutter/material.dart';

class Label extends StatelessWidget {
  final String text;
  final bool disabled;
  final TextStyle? style;

  const Label({Key? key, required this.text, this.disabled = false, this.style})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? 0.5 : 1.0,
      child: Text(
        text,
        style:
            style ??
            TextStyle(
              fontSize: 14, // text-sm
              fontWeight: FontWeight.w500, // font-medium
              height: 1.2, // leading-none
              color: disabled ? Colors.grey : Colors.black,
            ),
      ),
    );
  }
}
