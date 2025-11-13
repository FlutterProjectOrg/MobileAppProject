import 'package:flutter/material.dart';

class Skeleton extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const Skeleton({Key? key, this.width, this.height, this.borderRadius})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      width: width ?? double.infinity,
      height: height ?? 16.0,
      decoration: BoxDecoration(
        color: Colors.grey[300], // couleur de l'effet pulse
        borderRadius: borderRadius ?? BorderRadius.circular(4.0),
      ),
      child: const _PulseAnimation(),
    );
  }
}

class _PulseAnimation extends StatefulWidget {
  const _PulseAnimation({Key? key}) : super(key: key);

  @override
  State<_PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<_PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.3,
      end: 0.6,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(color: Colors.grey[300]),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
