import 'package:flutter/material.dart';
import 'package:mobile_app_project/Pages/AppScreen.dart';
import 'package:mobile_app_project/Pages/SplashScreen.dart';
import 'package:mobile_app_project/Pages/WelcomeScreen.dart';

class SplashFlow extends StatefulWidget {
  const SplashFlow({Key? key}) : super(key: key);

  @override
  State<SplashFlow> createState() => _SplashFlowState();
}

class _SplashFlowState extends State<SplashFlow> {
  bool _showWelcome = false;

  @override
  Widget build(BuildContext context) {
    if (!_showWelcome) {
      return SplashScreen(
        onComplete: () {
          if (mounted) {
            setState(() {
              _showWelcome = true;
            });
          }
        },
      );
    }

    return WelcomeScreen(
      onGetStarted: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AppScreen()),
        );
      },
    );
  }
}
