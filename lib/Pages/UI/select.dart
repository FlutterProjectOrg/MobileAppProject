import 'package:flutter/material.dart';

class Select<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? hint;
  final double? width;

  const Select({
    Key? key,
    this.value,
    required this.items,
    this.onChanged,
    this.hint,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color:
            Theme.of(context).inputDecorationTheme.fillColor ??
            Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: hint != null ? Text(hint!) : null,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          onChanged: onChanged,
          items: items,
        ),
      ),
    );
  }
}

/// Exemple d'utilisation avec des items et un séparateur
class SelectExample extends StatefulWidget {
  const SelectExample({Key? key}) : super(key: key);

  @override
  State<SelectExample> createState() => _SelectExampleState();
}

class _SelectExampleState extends State<SelectExample> {
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Select<String>(
          value: selectedValue,
          hint: "Choisir une option",
          onChanged: (val) {
            setState(() {
              selectedValue = val;
            });
          },
          items: [
            const DropdownMenuItem(value: "option1", child: Text("Option 1")),
            const DropdownMenuItem(value: "option2", child: Text("Option 2")),
            const DropdownMenuItem(enabled: false, child: Divider(height: 1)),
            const DropdownMenuItem(value: "option3", child: Text("Option 3")),
          ],
        ),
      ],
    );
  }
}
