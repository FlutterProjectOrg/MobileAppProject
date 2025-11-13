import 'package:flutter/material.dart';

enum SeparatorOrientation { horizontal, vertical }

class Separator extends StatelessWidget {
  final SeparatorOrientation orientation;
  final bool decorative;
  final Color? color;
  final double thickness;
  final double? indent;
  final double? endIndent;

  const Separator({
    Key? key,
    this.orientation = SeparatorOrientation.horizontal,
    this.decorative = true,
    this.color,
    this.thickness = 1.0,
    this.indent,
    this.endIndent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dividerColor = color ?? Theme.of(context).dividerColor;

    if (orientation == SeparatorOrientation.vertical) {
      return VerticalDivider(
        width: thickness,
        thickness: thickness,
        color: decorative ? dividerColor : Colors.transparent,
        indent: indent,
        endIndent: endIndent,
      );
    }

    return Divider(
      height: thickness,
      thickness: thickness,
      color: decorative ? dividerColor : Colors.transparent,
      indent: indent,
      endIndent: endIndent,
    );
  }
}
