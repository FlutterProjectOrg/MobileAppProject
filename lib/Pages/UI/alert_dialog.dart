import 'package:flutter/material.dart';

/// AlertDialog personnalisé pour Flutter - Équivalent de Radix UI AlertDialog
class CustomAlertDialog extends StatelessWidget {
  final String? title;
  final String? description;
  final Widget? titleWidget;
  final Widget? descriptionWidget;
  final String? actionLabel;
  final String? cancelLabel;
  final VoidCallback? onAction;
  final VoidCallback? onCancel;
  final Widget? header;
  final Widget? footer;
  final List<Widget>? actions;
  final bool barrierDismissible;
  final Color? actionColor;
  final Color? cancelColor;
  final IconData? icon;
  final Color? iconColor;

  const CustomAlertDialog({
    Key? key,
    this.title,
    this.description,
    this.titleWidget,
    this.descriptionWidget,
    this.actionLabel,
    this.cancelLabel,
    this.onAction,
    this.onCancel,
    this.header,
    this.footer,
    this.actions,
    this.barrierDismissible = true,
    this.actionColor,
    this.cancelColor,
    this.icon,
    this.iconColor,
  }) : super(key: key);

  /// Affiche l'AlertDialog
  static Future<bool?> show({
    required BuildContext context,
    String? title,
    String? description,
    Widget? titleWidget,
    Widget? descriptionWidget,
    String? actionLabel,
    String? cancelLabel,
    VoidCallback? onAction,
    VoidCallback? onCancel,
    Widget? header,
    Widget? footer,
    List<Widget>? actions,
    bool barrierDismissible = true,
    Color? actionColor,
    Color? cancelColor,
    IconData? icon,
    Color? iconColor,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => CustomAlertDialog(
        title: title,
        description: description,
        titleWidget: titleWidget,
        descriptionWidget: descriptionWidget,
        actionLabel: actionLabel,
        cancelLabel: cancelLabel,
        onAction: onAction,
        onCancel: onCancel,
        header: header,
        footer: footer,
        actions: actions,
        actionColor: actionColor,
        cancelColor: cancelColor,
        icon: icon,
        iconColor: iconColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header personnalisé ou par défaut
            if (header != null)
              header!
            else
              _buildDefaultHeader(context, theme),

            // Actions personnalisées ou par défaut
            if (footer != null)
              footer!
            else if (actions != null)
              _buildCustomActions(context)
            else
              _buildDefaultActions(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultHeader(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Icône optionnelle
        if (icon != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (iconColor ?? theme.primaryColor).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: iconColor ?? theme.primaryColor),
          ),
          const SizedBox(height: 16),
        ],

        // Titre
        if (titleWidget != null)
          titleWidget!
        else if (title != null)
          Text(
            title!,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

        const SizedBox(height: 12),

        // Description
        if (descriptionWidget != null)
          descriptionWidget!
        else if (description != null)
          Text(
            description!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
            textAlign: TextAlign.center,
          ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDefaultActions(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Bouton d'action principal
        if (actionLabel != null)
          ElevatedButton(
            onPressed: () {
              onAction?.call();
              Navigator.of(context).pop(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: actionColor ?? theme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(actionLabel!),
          ),

        const SizedBox(height: 12),

        // Bouton d'annulation
        if (cancelLabel != null)
          OutlinedButton(
            onPressed: () {
              onCancel?.call();
              Navigator.of(context).pop(false);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: cancelColor ?? theme.textTheme.bodyLarge?.color,
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: theme.dividerColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(cancelLabel!),
          ),
      ],
    );
  }

  Widget _buildCustomActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: actions!,
    );
  }
}

/// AlertDialog de confirmation
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String description;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Color? confirmColor;
  final IconData? icon;

  const ConfirmationDialog({
    Key? key,
    required this.title,
    required this.description,
    this.confirmLabel = 'Confirmer',
    this.cancelLabel = 'Annuler',
    this.onConfirm,
    this.onCancel,
    this.confirmColor,
    this.icon,
  }) : super(key: key);

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String description,
    String confirmLabel = 'Confirmer',
    String cancelLabel = 'Annuler',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    Color? confirmColor,
    IconData? icon,
  }) {
    return CustomAlertDialog.show(
      context: context,
      title: title,
      description: description,
      actionLabel: confirmLabel,
      cancelLabel: cancelLabel,
      onAction: onConfirm,
      onCancel: onCancel,
      actionColor: confirmColor,
      icon: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      title: title,
      description: description,
      actionLabel: confirmLabel,
      cancelLabel: cancelLabel,
      onAction: onConfirm,
      onCancel: onCancel,
      actionColor: confirmColor,
      icon: icon,
    );
  }
}

/// AlertDialog destructif (pour les actions dangereuses)
class DestructiveDialog extends StatelessWidget {
  final String title;
  final String description;
  final String actionLabel;
  final String cancelLabel;
  final VoidCallback? onAction;
  final VoidCallback? onCancel;

  const DestructiveDialog({
    Key? key,
    required this.title,
    required this.description,
    this.actionLabel = 'Supprimer',
    this.cancelLabel = 'Annuler',
    this.onAction,
    this.onCancel,
  }) : super(key: key);

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String description,
    String actionLabel = 'Supprimer',
    String cancelLabel = 'Annuler',
    VoidCallback? onAction,
    VoidCallback? onCancel,
  }) {
    return CustomAlertDialog.show(
      context: context,
      title: title,
      description: description,
      actionLabel: actionLabel,
      cancelLabel: cancelLabel,
      onAction: onAction,
      onCancel: onCancel,
      actionColor: Colors.red,
      icon: Icons.warning_rounded,
      iconColor: Colors.red,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      title: title,
      description: description,
      actionLabel: actionLabel,
      cancelLabel: cancelLabel,
      onAction: onAction,
      onCancel: onCancel,
      actionColor: Colors.red,
      icon: Icons.warning_rounded,
      iconColor: Colors.red,
    );
  }
}

/// AlertDialog de succès
class SuccessDialog extends StatelessWidget {
  final String title;
  final String description;
  final String actionLabel;

  const SuccessDialog({
    Key? key,
    required this.title,
    required this.description,
    this.actionLabel = 'OK',
  }) : super(key: key);

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String description,
    String actionLabel = 'OK',
  }) {
    return CustomAlertDialog.show(
      context: context,
      title: title,
      description: description,
      actionLabel: actionLabel,
      actionColor: Colors.green,
      icon: Icons.check_circle_rounded,
      iconColor: Colors.green,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      title: title,
      description: description,
      actionLabel: actionLabel,
      actionColor: Colors.green,
      icon: Icons.check_circle_rounded,
      iconColor: Colors.green,
    );
  }
}

/// Exemple d'utilisation complète
class AlertDialogExample extends StatelessWidget {
  const AlertDialogExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alert Dialog Examples')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Dialog simple
          ElevatedButton(
            onPressed: () {
              CustomAlertDialog.show(
                context: context,
                title: 'Notification',
                description: 'Ceci est un message d\'information important.',
                actionLabel: 'Compris',
              );
            },
            child: const Text('Dialog Simple'),
          ),
          const SizedBox(height: 12),

          // Dialog de confirmation
          ElevatedButton(
            onPressed: () async {
              final result = await ConfirmationDialog.show(
                context: context,
                title: 'Confirmer l\'action',
                description: 'Êtes-vous sûr de vouloir continuer ?',
                confirmLabel: 'Oui, continuer',
                cancelLabel: 'Non, annuler',
                icon: Icons.help_outline,
              );

              if (result == true && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Action confirmée')),
                );
              }
            },
            child: const Text('Dialog de Confirmation'),
          ),
          const SizedBox(height: 12),

          // Dialog destructif
          ElevatedButton(
            onPressed: () async {
              final result = await DestructiveDialog.show(
                context: context,
                title: 'Supprimer l\'élément',
                description:
                    'Cette action est irréversible. Êtes-vous sûr de vouloir supprimer cet élément ?',
                actionLabel: 'Oui, supprimer',
                cancelLabel: 'Annuler',
              );

              if (result == true && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Élément supprimé'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Dialog Destructif'),
          ),
          const SizedBox(height: 12),

          // Dialog de succès
          ElevatedButton(
            onPressed: () {
              SuccessDialog.show(
                context: context,
                title: 'Succès !',
                description: 'Votre opération a été effectuée avec succès.',
                actionLabel: 'Super !',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Dialog de Succès'),
          ),
          const SizedBox(height: 12),

          // Dialog personnalisé
          ElevatedButton(
            onPressed: () {
              CustomAlertDialog.show(
                context: context,
                titleWidget: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: Colors.amber),
                    SizedBox(width: 8),
                    Text(
                      'Titre personnalisé',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                descriptionWidget: Column(
                  children: [
                    const Text('Description avec widgets personnalisés'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Information complémentaire'),
                    ),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Action 1'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Action 2'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuler'),
                  ),
                ],
              );
            },
            child: const Text('Dialog Personnalisé'),
          ),
        ],
      ),
    );
  }
}
