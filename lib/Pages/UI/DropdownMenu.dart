import 'package:flutter/material.dart';

class DropdownMenuItemData<T> {
  final String label;
  final T? value;
  final bool checked;
  final bool isRadio;

  DropdownMenuItemData({
    required this.label,
    this.value,
    this.checked = false,
    this.isRadio = false,
  });
}

class CustomDropdownMenu<T> extends StatelessWidget {
  final List<DropdownMenuItemData<T>> items;
  final void Function(T?) onSelected;
  final String? hint;

  const CustomDropdownMenu({
    Key? key,
    required this.items,
    required this.onSelected,
    this.hint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      onSelected: onSelected,
      itemBuilder: (context) {
        return items.map((item) {
          return PopupMenuItem<T>(
            value: item.value,
            child: Row(
              children: [
                if (item.isRadio)
                  Radio(
                    value: item.value,
                    groupValue: items
                        .firstWhere((i) => i.checked, orElse: () => item)
                        .value,
                    onChanged: (_) => onSelected(item.value),
                  )
                else if (item.checked)
                  const Icon(Icons.check, size: 20),
                const SizedBox(width: 8),
                Text(item.label),
              ],
            ),
          );
        }).toList();
      },
      child: hint != null ? Text(hint!) : const Icon(Icons.more_vert),
    );
  }
}

// Exemple d'utilisation
class MyDropdownExample extends StatefulWidget {
  const MyDropdownExample({super.key});

  @override
  State<MyDropdownExample> createState() => _MyDropdownExampleState();
}

class _MyDropdownExampleState extends State<MyDropdownExample> {
  String selectedItem = '';

  @override
  Widget build(BuildContext context) {
    return CustomDropdownMenu<String>(
      hint: "Open Menu",
      items: [
        DropdownMenuItemData(label: "Option 1", value: "1"),
        DropdownMenuItemData(label: "Option 2", value: "2", checked: true),
        DropdownMenuItemData(
          label: "Option 3 (Radio)",
          value: "3",
          isRadio: true,
        ),
      ],
      onSelected: (value) {
        setState(() {
          selectedItem = value ?? '';
        });
      },
    );
  }
}
