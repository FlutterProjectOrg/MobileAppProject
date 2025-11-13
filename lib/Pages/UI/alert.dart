import 'package:flutter/material.dart';

/// Types de variantes pour Alert
enum AlertVariant { default_, destructive, info, warning, success }

/// Widget Alert pour Flutter - Équivalent de shadcn/ui Alert
class Alert extends StatelessWidget {
  final String? title;
  final String? description;
  final Widget? titleWidget;
  final Widget? descriptionWidget;
  final IconData? icon;
  final AlertVariant variant;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Widget? trailing;
  final VoidCallback? onClose;

  const Alert({
    Key? key,
    this.title,
    this.description,
    this.titleWidget,
    this.descriptionWidget,
    this.icon,
    this.variant = AlertVariant.default_,
    this.padding,
    this.borderRadius,
    this.trailing,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _getVariantColors(context);

    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        border: Border.all(color: colors.borderColor, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icône
          if (icon != null) ...[
            Icon(icon, size: 20, color: colors.iconColor),
            const SizedBox(width: 12),
          ],

          // Contenu
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Titre
                if (titleWidget != null)
                  titleWidget!
                else if (title != null)
                  Text(
                    title!,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                // Espacement si titre et description
                if ((title != null || titleWidget != null) &&
                    (description != null || descriptionWidget != null))
                  const SizedBox(height: 4),

                // Description
                if (descriptionWidget != null)
                  descriptionWidget!
                else if (description != null)
                  Text(
                    description!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.descriptionColor,
                      height: 1.5,
                    ),
                  ),
              ],
            ),
          ),

          // Trailing (action ou bouton de fermeture)
          if (trailing != null || onClose != null) ...[
            const SizedBox(width: 12),
            trailing ??
                IconButton(
                  icon: Icon(Icons.close, size: 18, color: colors.iconColor),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: onClose,
                ),
          ],
        ],
      ),
    );
  }

  _AlertColors _getVariantColors(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    switch (variant) {
      case AlertVariant.destructive:
        return _AlertColors(
          backgroundColor: isDark
              ? Colors.red.shade900.withOpacity(0.2)
              : Colors.red.shade50,
          borderColor: isDark ? Colors.red.shade800 : Colors.red.shade200,
          textColor: isDark ? Colors.red.shade100 : Colors.red.shade900,
          descriptionColor: isDark ? Colors.red.shade200 : Colors.red.shade700,
          iconColor: isDark ? Colors.red.shade300 : Colors.red.shade600,
        );

      case AlertVariant.info:
        return _AlertColors(
          backgroundColor: isDark
              ? Colors.blue.shade900.withOpacity(0.2)
              : Colors.blue.shade50,
          borderColor: isDark ? Colors.blue.shade800 : Colors.blue.shade200,
          textColor: isDark ? Colors.blue.shade100 : Colors.blue.shade900,
          descriptionColor: isDark
              ? Colors.blue.shade200
              : Colors.blue.shade700,
          iconColor: isDark ? Colors.blue.shade300 : Colors.blue.shade600,
        );

      case AlertVariant.warning:
        return _AlertColors(
          backgroundColor: isDark
              ? Colors.orange.shade900.withOpacity(0.2)
              : Colors.orange.shade50,
          borderColor: isDark ? Colors.orange.shade800 : Colors.orange.shade200,
          textColor: isDark ? Colors.orange.shade100 : Colors.orange.shade900,
          descriptionColor: isDark
              ? Colors.orange.shade200
              : Colors.orange.shade700,
          iconColor: isDark ? Colors.orange.shade300 : Colors.orange.shade600,
        );

      case AlertVariant.success:
        return _AlertColors(
          backgroundColor: isDark
              ? Colors.green.shade900.withOpacity(0.2)
              : Colors.green.shade50,
          borderColor: isDark ? Colors.green.shade800 : Colors.green.shade200,
          textColor: isDark ? Colors.green.shade100 : Colors.green.shade900,
          descriptionColor: isDark
              ? Colors.green.shade200
              : Colors.green.shade700,
          iconColor: isDark ? Colors.green.shade300 : Colors.green.shade600,
        );

      case AlertVariant.default_:
        return _AlertColors(
          backgroundColor: theme.cardColor,
          borderColor: theme.dividerColor,
          textColor: theme.textTheme.bodyLarge!.color!,
          descriptionColor: theme.textTheme.bodySmall!.color!,
          iconColor: theme.iconTheme.color!,
        );
    }
  }
}

/// Classe pour stocker les couleurs d'une variante
class _AlertColors {
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final Color descriptionColor;
  final Color iconColor;

  _AlertColors({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.descriptionColor,
    required this.iconColor,
  });
}

/// Alert destructive (erreur)
class DestructiveAlert extends StatelessWidget {
  final String title;
  final String? description;
  final VoidCallback? onClose;

  const DestructiveAlert({
    Key? key,
    required this.title,
    this.description,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Alert(
      title: title,
      description: description,
      icon: Icons.error_outline,
      variant: AlertVariant.destructive,
      onClose: onClose,
    );
  }
}

/// Alert d'information
class InfoAlert extends StatelessWidget {
  final String title;
  final String? description;
  final VoidCallback? onClose;

  const InfoAlert({
    Key? key,
    required this.title,
    this.description,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Alert(
      title: title,
      description: description,
      icon: Icons.info_outline,
      variant: AlertVariant.info,
      onClose: onClose,
    );
  }
}

/// Alert d'avertissement
class WarningAlert extends StatelessWidget {
  final String title;
  final String? description;
  final VoidCallback? onClose;

  const WarningAlert({
    Key? key,
    required this.title,
    this.description,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Alert(
      title: title,
      description: description,
      icon: Icons.warning_amber_outlined,
      variant: AlertVariant.warning,
      onClose: onClose,
    );
  }
}

/// Alert de succès
class SuccessAlert extends StatelessWidget {
  final String title;
  final String? description;
  final VoidCallback? onClose;

  const SuccessAlert({
    Key? key,
    required this.title,
    this.description,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Alert(
      title: title,
      description: description,
      icon: Icons.check_circle_outline,
      variant: AlertVariant.success,
      onClose: onClose,
    );
  }
}

/// Alert dismissible avec animation
class DismissibleAlert extends StatefulWidget {
  final Alert alert;
  final Duration? duration;
  final VoidCallback? onDismissed;

  const DismissibleAlert({
    Key? key,
    required this.alert,
    this.duration,
    this.onDismissed,
  }) : super(key: key);

  @override
  State<DismissibleAlert> createState() => _DismissibleAlertState();
}

class _DismissibleAlertState extends State<DismissibleAlert>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();

    if (widget.duration != null) {
      Future.delayed(widget.duration!, _dismiss);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _controller.reverse();
    if (mounted) {
      setState(() => _visible = false);
      widget.onDismissed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.alert),
    );
  }
}

/// Exemple d'utilisation complète
class AlertExample extends StatefulWidget {
  const AlertExample({Key? key}) : super(key: key);

  @override
  State<AlertExample> createState() => _AlertExampleState();
}

class _AlertExampleState extends State<AlertExample> {
  final List<Widget> _alerts = [];

  void _showAlert(Widget alert) {
    setState(() {
      _alerts.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DismissibleAlert(
            alert: alert as Alert,
            duration: const Duration(seconds: 5),
            onDismissed: () {
              setState(() {
                _alerts.remove(alert);
              });
            },
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alert Examples')),
      body: Column(
        children: [
          // Zone d'affichage des alerts
          if (_alerts.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(children: _alerts),
            ),

          // Boutons pour afficher les alerts
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Alerts statiques',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Alert par défaut
                const Alert(
                  title: 'Information',
                  description: 'Ceci est une alerte par défaut.',
                  icon: Icons.info_outline,
                ),
                const SizedBox(height: 12),

                // Alert destructive
                const DestructiveAlert(
                  title: 'Erreur',
                  description: 'Une erreur s\'est produite lors du traitement.',
                ),
                const SizedBox(height: 12),

                // Alert info
                const InfoAlert(
                  title: 'Astuce',
                  description: 'Vous pouvez personnaliser cette alerte.',
                ),
                const SizedBox(height: 12),

                // Alert warning
                const WarningAlert(
                  title: 'Attention',
                  description: 'Vérifiez vos informations avant de continuer.',
                ),
                const SizedBox(height: 12),

                // Alert success
                const SuccessAlert(
                  title: 'Succès',
                  description: 'L\'opération a été effectuée avec succès.',
                ),
                const SizedBox(height: 12),

                // Alert avec bouton de fermeture
                Alert(
                  title: 'Notification',
                  description: 'Vous avez un nouveau message.',
                  icon: Icons.notifications_outlined,
                  variant: AlertVariant.info,
                  onClose: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Alert fermée')),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Alert avec widget personnalisé
                Alert(
                  titleWidget: const Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Titre personnalisé',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  descriptionWidget: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Description avec widgets personnalisés'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Action'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Boutons pour afficher les alerts temporaires
                const Text(
                  'Alerts temporaires (5 secondes)',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                ElevatedButton.icon(
                  onPressed: () => _showAlert(
                    const InfoAlert(
                      title: 'Information',
                      description: 'Cette alerte disparaîtra dans 5 secondes',
                    ),
                  ),
                  icon: const Icon(Icons.info),
                  label: const Text('Afficher Info'),
                ),
                const SizedBox(height: 8),

                ElevatedButton.icon(
                  onPressed: () => _showAlert(
                    const SuccessAlert(
                      title: 'Succès',
                      description: 'Opération réussie !',
                    ),
                  ),
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Afficher Succès'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),

                ElevatedButton.icon(
                  onPressed: () => _showAlert(
                    const WarningAlert(
                      title: 'Attention',
                      description: 'Soyez prudent !',
                    ),
                  ),
                  icon: const Icon(Icons.warning),
                  label: const Text('Afficher Warning'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),

                ElevatedButton.icon(
                  onPressed: () => _showAlert(
                    const DestructiveAlert(
                      title: 'Erreur',
                      description: 'Quelque chose s\'est mal passé !',
                    ),
                  ),
                  icon: const Icon(Icons.error),
                  label: const Text('Afficher Erreur'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
