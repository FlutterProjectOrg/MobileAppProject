import 'package:flutter/material.dart';
import 'package:mobile_app_project/Pages/UI/AppColors.dart';

class Popover extends StatelessWidget {
  final Widget child;
  final Widget content;
  final PopoverDirection direction;

  const Popover({
    Key? key,
    required this.child,
    required this.content,
    this.direction = PopoverDirection.bottom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: () => _showPopover(context), child: child);
  }

  void _showPopover(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(color: Colors.transparent),
          ),
          Positioned(
            left: direction == PopoverDirection.right
                ? offset.dx + size.width + 8
                : null,
            right: direction == PopoverDirection.left
                ? MediaQuery.of(context).size.width - offset.dx + 8
                : null,
            top: direction == PopoverDirection.bottom
                ? offset.dy + size.height + 8
                : null,
            bottom: direction == PopoverDirection.top
                ? MediaQuery.of(context).size.height - offset.dy + 8
                : null,
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 300),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryOrange.withOpacity(0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryOrange.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: content,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum PopoverDirection { top, bottom, left, right }
