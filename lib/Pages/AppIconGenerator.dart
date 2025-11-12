import 'package:flutter/material.dart';
import 'package:mobile_app_project/Pages/UI/AppColors.dart';

/// Widget pour générer l'icône de l'application
/// À utiliser avec un package comme screenshot pour générer le PNG
class AppIconGenerator extends StatelessWidget {
  const AppIconGenerator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1024,
      height: 1024,
      decoration: const BoxDecoration(gradient: AppColors.gradientPrimary),
      child: Center(
        child: Container(
          width: 768,
          height: 768,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(192),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.restaurant_menu,
              size: 512,
              color: AppColors.primaryOrange,
            ),
          ),
        ),
      ),
    );
  }
}
