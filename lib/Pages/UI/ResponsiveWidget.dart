import 'package:flutter/material.dart';

class ResponsiveWidget extends StatefulWidget {
  final Widget mobile;
  final Widget desktop;

  const ResponsiveWidget({
    required this.mobile,
    required this.desktop,
    Key? key,
  }) : super(key: key);

  @override
  _ResponsiveWidgetState createState() => _ResponsiveWidgetState();
}

class _ResponsiveWidgetState extends State<ResponsiveWidget>
    with WidgetsBindingObserver {
  static const int mobileBreakpoint = 768;
  bool isMobile = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _updateIsMobile();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    _updateIsMobile();
  }

  void _updateIsMobile() {
    final width = MediaQuery.of(context).size.width;
    final mobile = width < mobileBreakpoint;
    if (mobile != isMobile) {
      setState(() {
        isMobile = mobile;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isMobile ? widget.mobile : widget.desktop;
  }
}
