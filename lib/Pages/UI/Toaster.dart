import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:overlay_support/overlay_support.dart'
    show showSimpleNotification;

class CustomToaster {
  static void show(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    Color? backgroundColor,
    Color? textColor,
  }) {
    showSimpleNotification(
      Text(message, style: TextStyle(color: textColor ?? Colors.white)),
      background: backgroundColor ?? Theme.of(context).colorScheme.surface,
      duration: duration,
      slideDismissDirection: DismissDirection.up,
      autoDismiss: true,
    );
  }
}
