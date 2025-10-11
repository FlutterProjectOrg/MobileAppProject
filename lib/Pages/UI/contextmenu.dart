import 'package:flutter/material.dart';

class ContextMenuExample extends StatelessWidget {
  const ContextMenuExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ContextMenuButton(
          child: ElevatedButton(
            onPressed: () {},
            child: const Text('Right Click / Long Press'),
          ),
          items: [
            ContextMenuItemData(
              label: 'New File',
              icon: Icons.insert_drive_file,
              onSelected: () => print('New File'),
            ),
            ContextMenuItemData(
              label: 'Open',
              icon: Icons.folder_open,
              onSelected: () => print('Open'),
            ),
            ContextMenuItemData(
              label: 'Save',
              icon: Icons.save,
              onSelected: () => print('Save'),
            ),
            ContextMenuItemData.separator(),
            ContextMenuItemData.checkbox(
              label: 'Enable Feature',
              value: true,
              onChanged: (val) => print('Feature enabled: $val'),
            ),
          ],
        ),
      ),
    );
  }
}

// Modèle de données pour un item du menu
class ContextMenuItemData {
  final String label;
  final IconData? icon;
  final VoidCallback? onSelected;
  final bool? isCheckbox;
  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final bool isSeparator;

  ContextMenuItemData({required this.label, this.icon, this.onSelected})
    : isCheckbox = false,
      value = null,
      onChanged = null,
      isSeparator = false;

  ContextMenuItemData.checkbox({
    required this.label,
    required this.value,
    required this.onChanged,
  }) : icon = null,
       onSelected = null,
       isCheckbox = true,
       isSeparator = false;

  ContextMenuItemData.separator()
    : label = '',
      icon = null,
      onSelected = null,
      isCheckbox = false,
      value = null,
      onChanged = null,
      isSeparator = true;
}

// Widget context menu
class ContextMenuButton extends StatelessWidget {
  final Widget child;
  final List<ContextMenuItemData> items;

  const ContextMenuButton({Key? key, required this.child, required this.items})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      child: child,
      itemBuilder: (context) =>
          items.asMap().entries.map<PopupMenuEntry<int>>((entry) {
            final index = entry.key;
            final item = entry.value;

            if (item.isSeparator) {
              return const PopupMenuDivider();
            }

            if (item.isCheckbox == true) {
              return CheckedPopupMenuItem<int>(
                value: index,
                checked: item.value ?? false,
                child: Text(item.label),
                onTap: () => item.onChanged?.call(!(item.value ?? false)),
              );
            }

            return PopupMenuItem<int>(
              value: index,
              onTap: item.onSelected,
              child: Row(
                children: [
                  if (item.icon != null) Icon(item.icon, size: 20),
                  if (item.icon != null) const SizedBox(width: 8),
                  Text(item.label),
                ],
              ),
            );
          }).toList(),
    );
  }
}
