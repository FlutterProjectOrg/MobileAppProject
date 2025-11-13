import 'package:flutter/material.dart';

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final bool isDisabled;

  const CustomCheckbox({
    Key? key,
    required this.value,
    this.onChanged,
    this.isDisabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: isDisabled
          ? null
          : () {
              if (onChanged != null) onChanged!(!value);
            },
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: value
              ? theme.colorScheme.primary
              : theme.inputDecorationTheme.fillColor ?? Colors.grey.shade200,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: value ? theme.colorScheme.primary : Colors.grey.shade400,
            width: 1.5,
          ),
        ),
        child: value
            ? Icon(Icons.check, size: 18, color: theme.colorScheme.onPrimary)
            : null,
      ),
    );
  }
}
