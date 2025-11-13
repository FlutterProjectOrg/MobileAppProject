import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final Widget? title;
  final Widget? description;
  final Widget? content;
  final List<Widget>? actions;

  const CustomDialog({
    Key? key,
    this.title,
    this.description,
    this.content,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header (title + description)
            if (title != null || description != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      DefaultTextStyle(
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        child: title!,
                      ),
                    if (description != null) ...[
                      const SizedBox(height: 8),
                      DefaultTextStyle(
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        child: description!,
                      ),
                    ],
                  ],
                ),
              ),

            // Content
            if (content != null)
              Padding(padding: const EdgeInsets.all(24), child: content!),

            // Footer / Actions
            if (actions != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions!,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Utilisation
void showCustomDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => CustomDialog(
      title: const Text("Dialog Title"),
      description: const Text("This is a description."),
      content: const Text("Here is the main content of the dialog."),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Confirm"),
        ),
      ],
    ),
  );
}
