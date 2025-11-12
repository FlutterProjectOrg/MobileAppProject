import 'package:flutter/material.dart';
import 'package:mobile_app_project/Pages/UI/AppColors.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool withGlow;
  final bool withShadow;

  const AppLogo({
    Key? key,
    this.size = 120,
    this.withGlow = true,
    this.withShadow = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow (optionnel)
        if (withGlow)
          Container(
            width: size + 20,
            height: size + 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 8,
                ),
              ],
            ),
          ),

        // Logo container
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(size * 0.25),
            boxShadow: withShadow
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Icon(
              Icons.restaurant_menu,
              size: size * 0.5,
              color: AppColors.primaryOrange,
            ),
          ),
        ),
      ],
    );
  }
}
