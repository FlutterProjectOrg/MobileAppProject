import 'package:flutter/material.dart';
import 'package:mobile_app_project/Pages/UI/AppColors.dart';

class CustomDrawer extends StatelessWidget {
  final String? title;
  final Widget? header;
  final List<DrawerItem> items;
  final Widget? footer;

  const CustomDrawer({
    Key? key,
    this.title,
    this.header,
    required this.items,
    this.footer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, AppColors.background],
          ),
        ),
        child: Column(
          children: [
            if (header != null)
              header!
            else if (title != null)
              Container(
                padding: EdgeInsets.fromLTRB(
                  24,
                  MediaQuery.of(context).padding.top + 24,
                  24,
                  24,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryOrange.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.restaurant_menu,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        title!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  if (item.isDivider) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Divider(
                        color: AppColors.primaryOrange.withOpacity(0.2),
                      ),
                    );
                  }
                  return _buildDrawerItem(context, item);
                },
              ),
            ),
            if (footer != null) footer!,
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, DrawerItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        gradient: item.isSelected ? AppColors.gradientPrimary.scale(0.2) : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: item.icon != null
            ? Icon(
                item.icon,
                color: item.isSelected
                    ? AppColors.primaryOrange
                    : AppColors.textSecondary,
                size: 22,
              )
            : null,
        title: Text(
          item.title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: item.isSelected ? FontWeight.w600 : FontWeight.w500,
            color: item.isSelected
                ? AppColors.primaryOrange
                : AppColors.textPrimary,
          ),
        ),
        subtitle: item.subtitle != null
            ? Text(
                item.subtitle!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              )
            : null,
        trailing: item.badge != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.badge!,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              )
            : (item.trailing ??
                  (item.onTap != null
                      ? Icon(
                          Icons.chevron_right,
                          color: AppColors.textSecondary.withOpacity(0.5),
                          size: 20,
                        )
                      : null)),
        onTap: item.onTap != null
            ? () {
                item.onTap!();
                Navigator.pop(context);
              }
            : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class DrawerItem {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? badge;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isDivider;

  DrawerItem({
    required this.title,
    this.subtitle,
    this.icon,
    this.badge,
    this.trailing,
    this.onTap,
    this.isSelected = false,
    this.isDivider = false,
  });

  static DrawerItem divider() {
    return DrawerItem(title: '', isDivider: true);
  }
}
