import 'package:flutter/material.dart';

enum SidebarState { expanded, collapsed }

class SidebarProvider extends ChangeNotifier {
  SidebarState state = SidebarState.expanded;
  bool isMobileOpen = false;

  void toggle({bool isMobile = false}) {
    if (isMobile) {
      isMobileOpen = !isMobileOpen;
    } else {
      state = state == SidebarState.expanded
          ? SidebarState.collapsed
          : SidebarState.expanded;
    }
    notifyListeners();
  }
}

class Sidebar extends StatelessWidget {
  final Widget child;
  final bool isMobile;
  final SidebarState state;
  final VoidCallback toggle;

  const Sidebar({
    Key? key,
    required this.child,
    required this.isMobile,
    required this.state,
    required this.toggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = state == SidebarState.expanded ? 250 : 70;

    if (isMobile) {
      return AnimatedPositioned(
        duration: Duration(milliseconds: 200),
        left: state == SidebarState.expanded ? 0 : -250,
        top: 0,
        bottom: 0,
        child: _SidebarContent(width: 250, child: child, toggle: toggle),
      );
    }

    return _SidebarContent(width: width, child: child, toggle: toggle);
  }
}

class _SidebarContent extends StatelessWidget {
  final double width;
  final Widget child;
  final VoidCallback toggle;

  const _SidebarContent({
    Key? key,
    required this.width,
    required this.child,
    required this.toggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      child: Container(
        width: width,
        color: Colors.grey[900],
        child: Column(
          children: [
            IconButton(
              icon: Icon(Icons.menu, color: Colors.white),
              onPressed: toggle,
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class SidebarMenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const SidebarMenuItem({
    Key? key,
    required this.title,
    required this.icon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }
}
