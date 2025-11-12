import 'package:flutter/material.dart';
import 'package:mobile_app_project/Pages/UI/AppColors.dart';

class Sidebar extends StatelessWidget {
  final Widget? header;
  final List<SidebarItem> items;
  final Widget? footer;
  final double width;

  const Sidebar({
    Key? key,
    this.header,
    required this.items,
    this.footer,
    this.width = 280,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: AppColors.primaryOrange.withOpacity(0.2)),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryOrange.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          if (header != null)
            Container(
              padding: const EdgeInsets.all(24),
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
              child: header!,
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                if (item.isDivider) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Divider(
                      color: AppColors.primaryOrange.withOpacity(0.2),
                    ),
                  );
                }
                if (item.isHeader) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  );
                }
                return _buildSidebarItem(item);
              },
            ),
          ),
          if (footer != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppColors.primaryOrange.withOpacity(0.2),
                  ),
                ),
              ),
              child: footer!,
            ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(SidebarItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
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
                size: 20,
              )
            : null,
        title: Text(
          item.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: item.isSelected ? FontWeight.w600 : FontWeight.w500,
            color: item.isSelected
                ? AppColors.primaryOrange
                : AppColors.textPrimary,
          ),
        ),
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
                          size: 18,
                        )
                      : null)),
        onTap: item.onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        dense: true,
      ),
    );
  }
}

class SidebarItem {
  final String title;
  final IconData? icon;
  final String? badge;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isDivider;
  final bool isHeader;

  SidebarItem({
    required this.title,
    this.icon,
    this.badge,
    this.trailing,
    this.onTap,
    this.isSelected = false,
    this.isDivider = false,
    this.isHeader = false,
  });

  static SidebarItem divider() {
    return SidebarItem(title: '', isDivider: true);
  }

  static SidebarItem header(String title) {
    return SidebarItem(title: title, isHeader: true);
  }
}
