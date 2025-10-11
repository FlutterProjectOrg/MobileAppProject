import 'package:flutter/material.dart' hide CarouselController;
import 'package:carousel_slider/carousel_slider.dart';

class CarouselWidget extends StatefulWidget {
  final List<Widget> children;
  final Axis axis;
  final double viewportFraction;
  final bool enableInfiniteScroll;

  const CarouselWidget({
    Key? key,
    required this.children,
    this.axis = Axis.horizontal,
    this.viewportFraction = 1.0,
    this.enableInfiniteScroll = true,
  }) : super(key: key);

  @override
  State<CarouselWidget> createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<CarouselWidget> {
  final CarouselController _controller = CarouselController();
  int _current = 0;

  void _scrollPrev() {
    if (_current > 0) {
      _controller.animateToPage(
        _current - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollNext() {
    if (_current < widget.children.length - 1) {
      _controller.animateToPage(
        _current + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CarouselSlider(
          items: widget.children,
          carouselController: _controller,
          options: CarouselOptions(
            scrollDirection: widget.axis,
            viewportFraction: widget.viewportFraction,
            enableInfiniteScroll: widget.enableInfiniteScroll,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            },
          ),
        ),

        // Previous button
        Positioned(
          left: 8,
          child: IconButton(
            icon: const Icon(Icons.arrow_left),
            onPressed: _current > 0 ? _scrollPrev : null,
          ),
        ),

        // Next button
        Positioned(
          right: 8,
          child: IconButton(
            icon: const Icon(Icons.arrow_right),
            onPressed: _current < widget.children.length - 1
                ? _scrollNext
                : null,
          ),
        ),
      ],
    );
  }
}
