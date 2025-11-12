import 'package:flutter/material.dart';

/// A widget that displays star ratings
class StarRating extends StatelessWidget {
  final double rating;
  final int starCount;
  final double size;
  final Color color;
  final Color? emptyColor;
  final bool allowHalfStars;

  const StarRating({
    Key? key,
    required this.rating,
    this.starCount = 5,
    this.size = 20,
    this.color = const Color(0xFFFFC107),
    this.emptyColor,
    this.allowHalfStars = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final emptyStarColor = emptyColor ?? Colors.grey[300]!;

    return Wrap(
      spacing: 0,
      children: List.generate(starCount, (index) {
        final starValue = index + 1;
        IconData iconData;

        if (allowHalfStars) {
          if (rating >= starValue) {
            iconData = Icons.star;
          } else if (rating >= starValue - 0.5) {
            iconData = Icons.star_half;
          } else {
            iconData = Icons.star_border;
          }
        } else {
          iconData = rating >= starValue ? Icons.star : Icons.star_border;
        }

        return Icon(
          iconData,
          size: size,
          color: rating >= starValue - 0.5 ? color : emptyStarColor,
        );
      }),
    );
  }
}

/// An interactive star rating selector
class InteractiveStarRating extends StatefulWidget {
  final double initialRating;
  final Function(double) onRatingChanged;
  final int starCount;
  final double size;
  final Color color;
  final Color? emptyColor;

  const InteractiveStarRating({
    Key? key,
    this.initialRating = 0,
    required this.onRatingChanged,
    this.starCount = 5,
    this.size = 32,
    this.color = const Color(0xFFFFC107),
    this.emptyColor,
  }) : super(key: key);

  @override
  State<InteractiveStarRating> createState() => _InteractiveStarRatingState();
}

class _InteractiveStarRatingState extends State<InteractiveStarRating> {
  late double _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    final emptyStarColor = widget.emptyColor ?? Colors.grey[300]!;

    return Wrap(
      spacing: 4,
      children: List.generate(widget.starCount, (index) {
        final starValue = index + 1;

        return GestureDetector(
          onTap: () {
            setState(() {
              _currentRating = starValue.toDouble();
            });
            widget.onRatingChanged(_currentRating);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              _currentRating >= starValue ? Icons.star : Icons.star_border,
              size: widget.size,
              color: _currentRating >= starValue ? widget.color : emptyStarColor,
            ),
          ),
        );
      }),
    );
  }
}
