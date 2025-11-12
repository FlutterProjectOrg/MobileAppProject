import 'package:flutter/material.dart';
import 'package:mobile_app_project/Pages/UI/AppColors.dart';

class CustomAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double size;
  final bool showBadge;
  final Color? badgeColor;

  const CustomAvatar({
    Key? key,
    this.imageUrl,
    this.name,
    this.size = 40,
    this.showBadge = false,
    this.badgeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: imageUrl == null ? AppColors.gradientPrimary : null,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primaryOrange.withOpacity(0.2),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryOrange.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: imageUrl != null
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildInitials();
                    },
                  )
                : _buildInitials(),
          ),
        ),
        if (showBadge)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.3,
              height: size * 0.3,
              decoration: BoxDecoration(
                color: badgeColor ?? AppColors.primaryOrange,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInitials() {
    final initials = name != null && name!.isNotEmpty
        ? name!.substring(0, 1).toUpperCase()
        : '?';

    return Center(
      child: Text(
        initials,
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

class AvatarGroup extends StatelessWidget {
  final List<String?> imageUrls;
  final int maxVisible;
  final double size;

  const AvatarGroup({
    Key? key,
    required this.imageUrls,
    this.maxVisible = 3,
    this.size = 40,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final visibleCount = imageUrls.length > maxVisible
        ? maxVisible
        : imageUrls.length;
    final remaining = imageUrls.length - maxVisible;

    return SizedBox(
      height: size,
      width: size * 0.7 * visibleCount + (remaining > 0 ? size * 0.7 : 0),
      child: Stack(
        children: [
          ...List.generate(visibleCount, (index) {
            return Positioned(
              left: index * size * 0.7,
              child: CustomAvatar(imageUrl: imageUrls[index], size: size),
            );
          }),
          if (remaining > 0)
            Positioned(
              left: visibleCount * size * 0.7,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    '+$remaining',
                    style: TextStyle(
                      fontSize: size * 0.3,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
