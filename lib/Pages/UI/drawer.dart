import 'package:flutter/material.dart';

enum DrawerDirection { left, right, top, bottom }

class CustomDrawer extends StatelessWidget {
  final Widget child;
  final DrawerDirection direction;
  final double width;
  final double height;

  const CustomDrawer({
    Key? key,
    required this.child,
    this.direction = DrawerDirection.right,
    this.width = 300,
    this.height = 400,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: _getAlignment(),
      child: Material(
        color: Colors.transparent,
        child: Container(
          width:
              direction == DrawerDirection.left ||
                  direction == DrawerDirection.right
              ? width
              : double.infinity,
          height:
              direction == DrawerDirection.top ||
                  direction == DrawerDirection.bottom
              ? height
              : double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).dialogBackgroundColor,
            borderRadius: _getBorderRadius(),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: child,
        ),
      ),
    );
  }

  Alignment _getAlignment() {
    switch (direction) {
      case DrawerDirection.left:
        return Alignment.centerLeft;
      case DrawerDirection.right:
        return Alignment.centerRight;
      case DrawerDirection.top:
        return Alignment.topCenter;
      case DrawerDirection.bottom:
        return Alignment.bottomCenter;
    }
  }

  BorderRadius _getBorderRadius() {
    switch (direction) {
      case DrawerDirection.left:
        return const BorderRadius.horizontal(right: Radius.circular(12));
      case DrawerDirection.right:
        return const BorderRadius.horizontal(left: Radius.circular(12));
      case DrawerDirection.top:
        return const BorderRadius.vertical(bottom: Radius.circular(12));
      case DrawerDirection.bottom:
        return const BorderRadius.vertical(top: Radius.circular(12));
    }
  }
}

// Exemple d'utilisation
void showCustomDrawer(BuildContext context, DrawerDirection direction) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Drawer',
    barrierColor: Colors.black54,
    pageBuilder: (context, _, __) {
      return CustomDrawer(
        direction: direction,
        width: 300,
        height: 400,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                "Drawer Header",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(),
            Expanded(child: Center(child: Text("Drawer Content"))),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Close"),
              ),
            ),
          ],
        ),
      );
    },
  );
}
