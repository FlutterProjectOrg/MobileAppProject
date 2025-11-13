import 'package:flutter/material.dart';

class ResizablePanelGroup extends StatefulWidget {
  final List<Widget> children;
  final Axis direction;

  const ResizablePanelGroup({
    Key? key,
    required this.children,
    this.direction = Axis.horizontal,
  }) : super(key: key);

  @override
  State<ResizablePanelGroup> createState() => _ResizablePanelGroupState();
}

class _ResizablePanelGroupState extends State<ResizablePanelGroup> {
  late List<double> sizes;

  @override
  void initState() {
    super.initState();
    sizes = List.filled(widget.children.length, 1 / widget.children.length);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalSize = widget.direction == Axis.horizontal
            ? constraints.maxWidth
            : constraints.maxHeight;

        return Flex(
          direction: widget.direction,
          children: List.generate(widget.children.length * 2 - 1, (index) {
            if (index.isEven) {
              final childIndex = index ~/ 2;
              final size = sizes[childIndex] * totalSize;

              return SizedBox(
                width: widget.direction == Axis.horizontal ? size : null,
                height: widget.direction == Axis.vertical ? size : null,
                child: widget.children[childIndex],
              );
            } else {
              final handleIndex = index ~/ 2;
              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanUpdate: (details) {
                  setState(() {
                    double delta = widget.direction == Axis.horizontal
                        ? details.delta.dx / totalSize
                        : details.delta.dy / totalSize;
                    sizes[handleIndex] += delta;
                    sizes[handleIndex + 1] -= delta;

                    // Clamp between 0.1 and 0.9
                    sizes[handleIndex] = sizes[handleIndex].clamp(0.1, 0.9);
                    sizes[handleIndex + 1] = sizes[handleIndex + 1].clamp(
                      0.1,
                      0.9,
                    );
                  });
                },
                child: MouseRegion(
                  cursor: widget.direction == Axis.horizontal
                      ? SystemMouseCursors.resizeColumn
                      : SystemMouseCursors.resizeRow,
                  child: Container(
                    color: Colors.grey[300],
                    width: widget.direction == Axis.horizontal ? 4 : null,
                    height: widget.direction == Axis.vertical ? 4 : null,
                    child: const Center(
                      child: Icon(
                        Icons.drag_indicator,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              );
            }
          }),
        );
      },
    );
  }
}
