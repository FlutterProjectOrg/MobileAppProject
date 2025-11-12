import 'package:flutter/material.dart';
import 'package:mobile_app_project/Pages/UI/AppColors.dart';

class HoverCard extends StatefulWidget {
  final Widget child;
  final Widget hoverContent;
  final Duration delay;

  const HoverCard({
    Key? key,
    required this.child,
    required this.hoverContent,
    this.delay = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        Future.delayed(widget.delay, () {
          if (mounted) {
            setState(() => _isHovered = true);
          }
        });
      },
      onExit: (_) {
        setState(() => _isHovered = false);
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          widget.child,
          if (_isHovered)
            Positioned(
              top: -8,
              left: 0,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
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
                  child: widget.hoverContent,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
