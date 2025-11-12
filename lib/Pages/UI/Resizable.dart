import 'package:flutter/material.dart';
import 'package:mobile_app_project/Pages/UI/AppColors.dart';

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

class Resizable extends StatefulWidget {
  final Widget child;
  final double minWidth;
  final double minHeight;
  final double maxWidth;
  final double maxHeight;
  final double initialWidth;
  final double initialHeight;

  const Resizable({
    Key? key,
    required this.child,
    this.minWidth = 100,
    this.minHeight = 100,
    this.maxWidth = double.infinity,
    this.maxHeight = double.infinity,
    this.initialWidth = 200,
    this.initialHeight = 200,
  }) : super(key: key);

  @override
  State<Resizable> createState() => _ResizableState();
}

class _ResizableState extends State<Resizable> {
  late double _width;
  late double _height;

  @override
  void initState() {
    super.initState();
    _width = widget.initialWidth;
    _height = widget.initialHeight;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _width,
      height: _height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryOrange.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryOrange.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          widget.child,
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _width = (_width + details.delta.dx).clamp(
                    widget.minWidth,
                    widget.maxWidth,
                  );
                  _height = (_height + details.delta.dy).clamp(
                    widget.minHeight,
                    widget.maxHeight,
                  );
                });
              },
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: const Icon(
                  Icons.drag_handle,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
