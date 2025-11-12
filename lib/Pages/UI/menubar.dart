import 'package:flutter/material.dart';
import 'package:mobile_app_project/Pages/UI/AppColors.dart';

class MenuBar extends StatelessWidget {
  final List<MenuBarItem> items;

  const MenuBar({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.primaryOrange.withOpacity(0.2)),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryOrange.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: items.map((item) {
          return _buildMenuItem(context, item);
        }).toList(),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, MenuBarItem item) {
    return PopupMenuButton(
      offset: const Offset(0, 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            if (item.icon != null) ...[
              Icon(item.icon, size: 18, color: AppColors.primaryOrange),
              const SizedBox(width: 8),
            ],
            Text(
              item.label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
      itemBuilder: (context) {
        return item.children.map((child) {
          return PopupMenuItem(
            onTap: child.onTap,
            child: Row(
              children: [
                if (child.icon != null) ...[
                  Icon(child.icon, size: 16, color: AppColors.primaryOrange),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    child.label,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (child.shortcut != null)
                  Text(
                    child.shortcut!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}

class MenuBarItem {
  final String label;
  final IconData? icon;
  final List<MenuBarChild> children;

  MenuBarItem({required this.label, this.icon, required this.children});
}

class MenuBarChild {
  final String label;
  final IconData? icon;
  final String? shortcut;
  final VoidCallback onTap;

  MenuBarChild({
    required this.label,
    this.icon,
    this.shortcut,
    required this.onTap,
  });
}
