import 'package:flutter/material.dart';
import 'package:mobile_app_project/Pages/UI/AppColors.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final AlertType type;

  const CustomAlertDialog({
    Key? key,
    required this.title,
    required this.message,
    this.icon,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.type = AlertType.info,
  }) : super(key: key);

  Color _getTypeColor() {
    switch (type) {
      case AlertType.success:
        return AppColors.primaryOrange;
      case AlertType.warning:
        return AppColors.primaryYellow;
      case AlertType.error:
        return Colors.red;
      case AlertType.info:
        return AppColors.primaryOrange;
    }
  }

  IconData _getTypeIcon() {
    if (icon != null) return icon!;
    switch (type) {
      case AlertType.success:
        return Icons.check_circle_outline;
      case AlertType.warning:
        return Icons.warning_amber_outlined;
      case AlertType.error:
        return Icons.error_outline;
      case AlertType.info:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: typeColor.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    typeColor.withOpacity(0.1),
                    typeColor.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(_getTypeIcon(), color: typeColor, size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                if (cancelText != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel ?? () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppColors.primaryOrange.withOpacity(0.3),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        cancelText!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm ?? () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: AppColors.gradientPrimary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        alignment: Alignment.center,
                        child: Text(
                          confirmText ?? 'OK',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum AlertType { success, warning, error, info }

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
              showDialog(
                context: context,
                builder: (context) => const CustomAlertDialog(
                  title: 'Notification',
                  message: 'Ceci est un message d\'information important.',
                  confirmText: 'Compris',
                  type: AlertType.info,
                ),
              );
            },
            child: const Text('Dialog Simple'),
          ),
          const SizedBox(height: 12),

          // Dialog de confirmation
          ElevatedButton(
            onPressed: () async {
              final result = await showDialog<bool>(
                context: context,
                builder: (context) => CustomAlertDialog(
                  title: 'Confirmer l\'action',
                  message: 'Êtes-vous sûr de vouloir continuer ?',
                  icon: Icons.help_outline,
                  confirmText: 'Oui, continuer',
                  cancelText: 'Non, annuler',
                  onConfirm: () => Navigator.of(context).pop(true),
                  onCancel: () => Navigator.of(context).pop(false),
                  type: AlertType.info,
                ),
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
              final result = await showDialog<bool>(
                context: context,
                builder: (context) => CustomAlertDialog(
                  title: 'Supprimer l\'élément',
                  message:
                      'Cette action est irréversible. Êtes-vous sûr de vouloir supprimer cet élément ?',
                  icon: Icons.delete_outline,
                  confirmText: 'Oui, supprimer',
                  cancelText: 'Annuler',
                  onConfirm: () => Navigator.of(context).pop(true),
                  onCancel: () => Navigator.of(context).pop(false),
                  type: AlertType.error,
                ),
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
              showDialog(
                context: context,
                builder: (context) => CustomAlertDialog(
                  title: 'Succès !',
                  message: 'Votre opération a été effectuée avec succès.',
                  confirmText: 'Super !',
                  type: AlertType.success,
                  onConfirm: () => Navigator.of(context).pop(),
                ),
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
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Row(
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
                        const SizedBox(height: 12),
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
                        const SizedBox(height: 12),
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
                    ),
                  ),
                ),
              );
            },
            child: const Text('Dialog Personnalisé'),
          ),
        ],
      ),
    );
  }
}
