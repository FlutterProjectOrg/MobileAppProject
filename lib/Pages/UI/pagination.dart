import 'package:flutter/material.dart';
import 'package:mobile_app_project/Pages/UI/AppColors.dart';

class Pagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;
  final bool showFirstLast;

  const Pagination({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.showFirstLast = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (showFirstLast)
          _buildButton(
            icon: Icons.first_page,
            onTap: currentPage > 1 ? () => onPageChanged(1) : null,
          ),
        const SizedBox(width: 4),
        _buildButton(
          icon: Icons.chevron_left,
          onTap: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
        ),
        const SizedBox(width: 8),
        ..._buildPageNumbers(),
        const SizedBox(width: 8),
        _buildButton(
          icon: Icons.chevron_right,
          onTap: currentPage < totalPages
              ? () => onPageChanged(currentPage + 1)
              : null,
        ),
        const SizedBox(width: 4),
        if (showFirstLast)
          _buildButton(
            icon: Icons.last_page,
            onTap: currentPage < totalPages
                ? () => onPageChanged(totalPages)
                : null,
          ),
      ],
    );
  }

  List<Widget> _buildPageNumbers() {
    List<Widget> pages = [];
    int start = (currentPage - 2).clamp(1, totalPages);
    int end = (currentPage + 2).clamp(1, totalPages);

    if (start > 1) {
      pages.add(_buildPageButton(1));
      if (start > 2) {
        pages.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '...',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        );
      }
    }

    for (int i = start; i <= end; i++) {
      pages.add(_buildPageButton(i));
    }

    if (end < totalPages) {
      if (end < totalPages - 1) {
        pages.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '...',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        );
      }
      pages.add(_buildPageButton(totalPages));
    }

    return pages;
  }

  Widget _buildPageButton(int page) {
    final isActive = page == currentPage;
    return GestureDetector(
      onTap: () => onPageChanged(page),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          gradient: isActive ? AppColors.gradientPrimary : null,
          color: isActive ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive
                ? Colors.transparent
                : AppColors.primaryOrange.withOpacity(0.2),
          ),
        ),
        child: Center(
          child: Text(
            '$page',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton({required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: onTap != null ? AppColors.background : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primaryOrange.withOpacity(0.2)),
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap != null
              ? AppColors.primaryOrange
              : AppColors.textSecondary.withOpacity(0.5),
        ),
      ),
    );
  }
}
