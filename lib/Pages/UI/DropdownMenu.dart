import 'package:flutter/material.dart';
import 'package:mobile_app_project/Pages/UI/AppColors.dart';

class CustomDropdownMenu extends StatelessWidget {
  final Widget trigger;
  final List<DropdownMenuItem> items;
  final DropdownAlignment alignment;

  const CustomDropdownMenu({
    Key? key,
    required this.trigger,
    required this.items,
    this.alignment = DropdownAlignment.bottomLeft,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: () => _showMenu(context), child: trigger);
  }

  void _showMenu(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height + 8,
        offset.dx + size.width,
        offset.dy,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      color: Colors.white,
      items: items.map((item) {
        return PopupMenuItem(
          onTap: item.onTap,
          child: Row(
            children: [
              if (item.icon != null)
                ...([
                  Icon(
                    item.icon,
                    size: 18,
                    color: item.isDestructive
                        ? Colors.red
                        : AppColors.primaryOrange,
                  ),
                  const SizedBox(width: 12),
                ]),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: item.isDestructive
                            ? Colors.red
                            : AppColors.textPrimary,
                      ),
                    ),
                    if (item.description != null)
                      ...([
                        const SizedBox(height: 2),
                        Text(
                          item.description!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ]),
                  ],
                ),
              ),
              if (item.trailing != null) item.trailing!,
            ],
          ),
        );
      }).toList(),
    );
  }
}

class DropdownMenuItem {
  final String label;
  final String? description;
  final IconData? icon;
  final Widget? trailing;
  final VoidCallback onTap;
  final bool isDestructive;

  DropdownMenuItem({
    required this.label,
    this.description,
    this.icon,
    this.trailing,
    required this.onTap,
    this.isDestructive = false,
  });
}

enum DropdownAlignment { topLeft, topRight, bottomLeft, bottomRight }
