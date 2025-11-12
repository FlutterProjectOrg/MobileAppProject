import 'package:flutter/material.dart';
import 'package:mobile_app_project/Pages/UI/AppColors.dart';

class ToggleGroup<T> extends StatelessWidget {
  final T? value;
  final List<ToggleOption<T>> options;
  final ValueChanged<T?> onChanged;
  final bool allowMultiple;
  final List<T>? selectedValues;
  final ValueChanged<List<T>>? onMultipleChanged;

  const ToggleGroup({
    Key? key,
    this.value,
    required this.options,
    required this.onChanged,
    this.allowMultiple = false,
    this.selectedValues,
    this.onMultipleChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = allowMultiple
            ? (selectedValues?.contains(option.value) ?? false)
            : value == option.value;

        return GestureDetector(
          onTap: () {
            if (allowMultiple && onMultipleChanged != null) {
              final newValues = List<T>.from(selectedValues ?? []);
              if (isSelected) {
                newValues.remove(option.value);
              } else {
                newValues.add(option.value);
              }
              onMultipleChanged!(newValues);
            } else {
              onChanged(isSelected ? null : option.value);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: isSelected ? AppColors.gradientPrimary : null,
              color: isSelected ? null : AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : AppColors.primaryOrange.withOpacity(0.3),
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primaryOrange.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (option.icon != null) ...[
                  Icon(
                    option.icon,
                    size: 16,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  option.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class ToggleOption<T> {
  final T value;
  final String label;
  final IconData? icon;

  ToggleOption({required this.value, required this.label, this.icon});
}
