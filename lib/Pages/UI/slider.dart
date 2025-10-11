import 'package:flutter/material.dart';

class CustomSlider extends StatelessWidget {
  final double min;
  final double max;
  final double? value;
  final RangeValues? rangeValues;
  final ValueChanged<double>? onChanged;
  final ValueChanged<RangeValues>? onRangeChanged;

  const CustomSlider({
    Key? key,
    this.min = 0,
    this.max = 100,
    this.value,
    this.rangeValues,
    this.onChanged,
    this.onRangeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (rangeValues != null) {
      // Multi-thumb slider (range)
      return RangeSlider(
        min: min,
        max: max,
        values: rangeValues!,
        onChanged: onRangeChanged,
        activeColor: Theme.of(context).colorScheme.primary,
        inactiveColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
      );
    }

    // Single-thumb slider
    return Slider(
      min: min,
      max: max,
      value: value ?? min,
      onChanged: onChanged,
      activeColor: Theme.of(context).colorScheme.primary,
      inactiveColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
      thumbColor: Theme.of(context).colorScheme.primary,
    );
  }
}
