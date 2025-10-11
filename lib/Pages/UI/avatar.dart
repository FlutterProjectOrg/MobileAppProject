import 'package:flutter/material.dart';

/// Widget Avatar personnalisé - Équivalent de Radix UI Avatar
class CustomAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final Widget? fallback;
  final double size;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final BoxShape shape;
  final double? borderRadius;
  final Border? border;
  final VoidCallback? onTap;
  final Widget? badge;
  final bool showInitials;

  const CustomAvatar({
    Key? key,
    this.imageUrl,
    this.name,
    this.fallback,
    this.size = 40,
    this.backgroundColor,
    this.foregroundColor,
    this.shape = BoxShape.circle,
    this.borderRadius,
    this.border,
    this.onTap,
    this.badge,
    this.showInitials = true,
  }) : super(key: key);

  /// Avatar avec image
  const CustomAvatar.image({
    Key? key,
    required String imageUrl,
    String? name,
    Widget? fallback,
    double size = 40,
    Color? backgroundColor,
    BoxShape shape = BoxShape.circle,
    double? borderRadius,
    Border? border,
    VoidCallback? onTap,
    Widget? badge,
  }) : this(
         key: key,
         imageUrl: imageUrl,
         name: name,
         fallback: fallback,
         size: size,
         backgroundColor: backgroundColor,
         shape: shape,
         borderRadius: borderRadius,
         border: border,
         onTap: onTap,
         badge: badge,
       );

  /// Avatar avec initiales
  const CustomAvatar.text({
    Key? key,
    required String name,
    double size = 40,
    Color? backgroundColor,
    Color? foregroundColor,
    BoxShape shape = BoxShape.circle,
    double? borderRadius,
    Border? border,
    VoidCallback? onTap,
    Widget? badge,
  }) : this(
         key: key,
         name: name,
         size: size,
         backgroundColor: backgroundColor,
         foregroundColor: foregroundColor,
         shape: shape,
         borderRadius: borderRadius,
         border: border,
         onTap: onTap,
         badge: badge,
         showInitials: true,
       );

  /// Avatar avec icône
  factory CustomAvatar.icon({
    Key? key,
    required IconData icon,
    double size = 40,
    Color? backgroundColor,
    Color? foregroundColor,
    BoxShape shape = BoxShape.circle,
    double? borderRadius,
    Border? border,
    VoidCallback? onTap,
    Widget? badge,
  }) {
    return CustomAvatar(
      key: key,
      fallback: Icon(icon, size: size * 0.5),
      size: size,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      shape: shape,
      borderRadius: borderRadius,
      border: border,
      onTap: onTap,
      badge: badge,
      showInitials: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.primaryColor;
    final fgColor = foregroundColor ?? Colors.white;

    Widget avatarContent = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: shape,
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.circular(borderRadius ?? size * 0.2)
            : null,
        border: border,
      ),
      child: imageUrl != null
          ? ClipRRect(
              borderRadius: shape == BoxShape.circle
                  ? BorderRadius.circular(size / 2)
                  : BorderRadius.circular(borderRadius ?? size * 0.2),
              child: Image.network(
                imageUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildFallback(context, bgColor, fgColor);
                },
                errorBuilder: (context, error, stackTrace) {
                  return _buildFallback(context, bgColor, fgColor);
                },
              ),
            )
          : _buildFallback(context, bgColor, fgColor),
    );

    // Ajouter le badge si présent
    if (badge != null) {
      avatarContent = Stack(
        clipBehavior: Clip.none,
        children: [
          avatarContent,
          Positioned(right: 0, bottom: 0, child: badge!),
        ],
      );
    }

    // Ajouter l'interactivité si onTap est défini
    if (onTap != null) {
      avatarContent = InkWell(
        onTap: onTap,
        borderRadius: shape == BoxShape.circle
            ? BorderRadius.circular(size / 2)
            : BorderRadius.circular(borderRadius ?? size * 0.2),
        child: avatarContent,
      );
    }

    return avatarContent;
  }

  Widget _buildFallback(BuildContext context, Color bgColor, Color fgColor) {
    if (fallback != null) {
      return Center(
        child: IconTheme(
          data: IconThemeData(color: fgColor),
          child: DefaultTextStyle(
            style: TextStyle(color: fgColor),
            child: fallback!,
          ),
        ),
      );
    }

    if (showInitials && name != null && name!.isNotEmpty) {
      return Center(
        child: Text(
          _getInitials(name!),
          style: TextStyle(
            color: fgColor,
            fontSize: size * 0.4,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Center(
      child: Icon(Icons.person, color: fgColor, size: size * 0.5),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return (parts[0].substring(0, 1) + parts[parts.length - 1].substring(0, 1))
        .toUpperCase();
  }
}

/// Badge pour avatar (indicateur de statut)
class AvatarBadge extends StatelessWidget {
  final Color color;
  final double size;
  final Border? border;

  const AvatarBadge({
    Key? key,
    this.color = Colors.green,
    this.size = 12,
    this.border,
  }) : super(key: key);

  const AvatarBadge.online({Key? key}) : this(key: key, color: Colors.green);

  const AvatarBadge.offline({Key? key}) : this(key: key, color: Colors.grey);

  const AvatarBadge.busy({Key? key}) : this(key: key, color: Colors.red);

  const AvatarBadge.away({Key? key}) : this(key: key, color: Colors.orange);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: border ?? Border.all(color: Colors.white, width: 2),
      ),
    );
  }
}

/// Groupe d'avatars empilés
class AvatarGroup extends StatelessWidget {
  final List<CustomAvatar> avatars;
  final double size;
  final double overlap;
  final int? maxCount;
  final Widget? moreWidget;

  const AvatarGroup({
    Key? key,
    required this.avatars,
    this.size = 40,
    this.overlap = 0.3,
    this.maxCount,
    this.moreWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final displayCount = maxCount != null && avatars.length > maxCount!
        ? maxCount!
        : avatars.length;
    final remaining = avatars.length - displayCount;

    return SizedBox(
      height: size,
      child: Stack(
        children: [
          ...List.generate(displayCount, (index) {
            return Positioned(
              left: index * size * (1 - overlap),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: avatars[index],
              ),
            );
          }),
          if (remaining > 0)
            Positioned(
              left: displayCount * size * (1 - overlap),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child:
                    moreWidget ??
                    CustomAvatar.text(
                      name: '+$remaining',
                      size: size,
                      backgroundColor: Colors.grey[400]!,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Avatar avec différentes tailles prédéfinies
class AvatarSize {
  static const double xs = 24;
  static const double sm = 32;
  static const double md = 40;
  static const double lg = 56;
  static const double xl = 80;
  static const double xxl = 120;
}

/// Exemple d'utilisation complète
class AvatarExample extends StatelessWidget {
  const AvatarExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Avatar Examples')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Avatars avec images',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              CustomAvatar.image(
                imageUrl: 'https://i.pravatar.cc/150?img=1',
                name: 'John Doe',
                size: AvatarSize.lg,
              ),
              CustomAvatar.image(
                imageUrl: 'https://i.pravatar.cc/150?img=2',
                name: 'Jane Smith',
                size: AvatarSize.lg,
                badge: const AvatarBadge.online(),
              ),
              CustomAvatar.image(
                imageUrl: 'https://i.pravatar.cc/150?img=3',
                name: 'Bob Wilson',
                size: AvatarSize.lg,
                badge: const AvatarBadge.busy(),
              ),
            ],
          ),
          const SizedBox(height: 32),

          const Text(
            'Avatars avec initiales',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              CustomAvatar.text(
                name: 'Alice Cooper',
                size: AvatarSize.lg,
                backgroundColor: Colors.blue,
              ),
              CustomAvatar.text(
                name: 'Bob Dylan',
                size: AvatarSize.lg,
                backgroundColor: Colors.purple,
              ),
              CustomAvatar.text(
                name: 'Charlie Brown',
                size: AvatarSize.lg,
                backgroundColor: Colors.orange,
              ),
              CustomAvatar.text(
                name: 'Diana Prince',
                size: AvatarSize.lg,
                backgroundColor: Colors.pink,
              ),
            ],
          ),
          const SizedBox(height: 32),

          const Text(
            'Avatars avec icônes',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              CustomAvatar.icon(
                icon: Icons.person,
                size: AvatarSize.lg,
                backgroundColor: Colors.grey,
              ),
              CustomAvatar.icon(
                icon: Icons.group,
                size: AvatarSize.lg,
                backgroundColor: Colors.teal,
              ),
              CustomAvatar.icon(
                icon: Icons.settings,
                size: AvatarSize.lg,
                backgroundColor: Colors.indigo,
              ),
            ],
          ),
          const SizedBox(height: 32),

          const Text(
            'Différentes tailles',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              CustomAvatar.text(
                name: 'XS',
                size: AvatarSize.xs,
                backgroundColor: Colors.blue,
              ),
              CustomAvatar.text(
                name: 'SM',
                size: AvatarSize.sm,
                backgroundColor: Colors.green,
              ),
              CustomAvatar.text(
                name: 'MD',
                size: AvatarSize.md,
                backgroundColor: Colors.orange,
              ),
              CustomAvatar.text(
                name: 'LG',
                size: AvatarSize.lg,
                backgroundColor: Colors.red,
              ),
              CustomAvatar.text(
                name: 'XL',
                size: AvatarSize.xl,
                backgroundColor: Colors.purple,
              ),
              CustomAvatar.text(
                name: 'XXL',
                size: AvatarSize.xxl,
                backgroundColor: Colors.pink,
              ),
            ],
          ),
          const SizedBox(height: 32),

          const Text(
            'Avatars carrés',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              CustomAvatar.text(
                name: 'Square 1',
                size: AvatarSize.lg,
                backgroundColor: Colors.cyan,
                shape: BoxShape.rectangle,
                borderRadius: 12,
              ),
              CustomAvatar.text(
                name: 'Square 2',
                size: AvatarSize.lg,
                backgroundColor: Colors.lime,
                shape: BoxShape.rectangle,
                borderRadius: 8,
              ),
              CustomAvatar.icon(
                icon: Icons.business,
                size: AvatarSize.lg,
                backgroundColor: Colors.brown,
                shape: BoxShape.rectangle,
                borderRadius: 16,
              ),
            ],
          ),
          const SizedBox(height: 32),

          const Text(
            'Avatars avec bordure',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              CustomAvatar.text(
                name: 'Border 1',
                size: AvatarSize.lg,
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue,
                border: Border.all(color: Colors.blue, width: 3),
              ),
              CustomAvatar.image(
                imageUrl: 'https://i.pravatar.cc/150?img=5',
                size: AvatarSize.lg,
                border: Border.all(color: Colors.amber, width: 3),
              ),
            ],
          ),
          const SizedBox(height: 32),

          const Text(
            'Groupe d\'avatars',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          AvatarGroup(
            size: AvatarSize.md,
            avatars: [
              CustomAvatar.image(
                imageUrl: 'https://i.pravatar.cc/150?img=10',
                size: AvatarSize.md,
              ),
              CustomAvatar.image(
                imageUrl: 'https://i.pravatar.cc/150?img=11',
                size: AvatarSize.md,
              ),
              CustomAvatar.image(
                imageUrl: 'https://i.pravatar.cc/150?img=12',
                size: AvatarSize.md,
              ),
              CustomAvatar.image(
                imageUrl: 'https://i.pravatar.cc/150?img=13',
                size: AvatarSize.md,
              ),
              CustomAvatar.image(
                imageUrl: 'https://i.pravatar.cc/150?img=14',
                size: AvatarSize.md,
              ),
            ],
            maxCount: 3,
          ),
          const SizedBox(height: 32),

          const Text(
            'Avatars interactifs',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              CustomAvatar.text(
                name: 'Click Me',
                size: AvatarSize.lg,
                backgroundColor: Colors.deepPurple,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Avatar clicked!')),
                  );
                },
              ),
              CustomAvatar.image(
                imageUrl: 'https://i.pravatar.cc/150?img=20',
                size: AvatarSize.lg,
                badge: const AvatarBadge.online(),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile opened!')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 32),

          const Text(
            'Statuts (badges)',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              CustomAvatar.text(
                name: 'Online',
                size: AvatarSize.lg,
                backgroundColor: Colors.blue,
                badge: const AvatarBadge.online(),
              ),
              CustomAvatar.text(
                name: 'Busy',
                size: AvatarSize.lg,
                backgroundColor: Colors.blue,
                badge: const AvatarBadge.busy(),
              ),
              CustomAvatar.text(
                name: 'Away',
                size: AvatarSize.lg,
                backgroundColor: Colors.blue,
                badge: const AvatarBadge.away(),
              ),
              CustomAvatar.text(
                name: 'Offline',
                size: AvatarSize.lg,
                backgroundColor: Colors.blue,
                badge: const AvatarBadge.offline(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
