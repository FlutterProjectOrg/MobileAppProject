import 'package:flutter/material.dart';

class AppTheme {
  // Couleurs principales - Mode clair
  static const Color primaryLight = Color(0xFFFF6B35);
  static const Color primaryForegroundLight = Color(0xFFFFFFFF);
  static const Color secondaryLight = Color(0xFFFEF3E2);
  static const Color secondaryForegroundLight = Color(0xFF1A1A1A);
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color foregroundLight = Color(0xFF1A1A1A);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardForegroundLight = Color(0xFF1A1A1A);
  static const Color mutedLight = Color(0xFFF5F5F5);
  static const Color mutedForegroundLight = Color(0xFF737373);
  static const Color accentLight = Color(0xFFFFF4E6);
  static const Color accentForegroundLight = Color(0xFF1A1A1A);
  static const Color destructiveLight = Color(0xFFEF4444);
  static const Color destructiveForegroundLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0x14000000); // rgba(0,0,0,0.08)
  static const Color inputBackgroundLight = Color(0xFFF9F9F9);
  static const Color switchBackgroundLight = Color(0xFFE5E5E5);

  // Couleurs principales - Mode sombre
  static const Color primaryDark = Color(0xFFFCFCFC);
  static const Color primaryForegroundDark = Color(0xFF343434);
  static const Color secondaryDark = Color(0xFF444444);
  static const Color secondaryForegroundDark = Color(0xFFFCFCFC);
  static const Color backgroundDark = Color(0xFF252525);
  static const Color foregroundDark = Color(0xFFFCFCFC);
  static const Color cardDark = Color(0xFF252525);
  static const Color cardForegroundDark = Color(0xFFFCFCFC);
  static const Color mutedDark = Color(0xFF444444);
  static const Color mutedForegroundDark = Color(0xFFB5B5B5);
  static const Color accentDark = Color(0xFF444444);
  static const Color accentForegroundDark = Color(0xFFFCFCFC);
  static const Color destructiveDark = Color(0xFFB93F3F);
  static const Color destructiveForegroundDark = Color(0xFFD89898);
  static const Color borderDark = Color(0xFF444444);
  static const Color inputBackgroundDark = Color(0xFF343434);
  static const Color switchBackgroundDark = Color(0xFF555555);

  // Couleurs des graphiques
  static const Color chart1 = Color(0xFFFF6B35);
  static const Color chart2 = Color(0xFF4ECDC4);
  static const Color chart3 = Color(0xFFF7B731);
  static const Color chart4 = Color(0xFF5F27CD);
  static const Color chart5 = Color(0xFFEE5A6F);

  // Radius
  static const double radiusLg = 16.0;
  static const double radiusMd = 14.0;
  static const double radiusSm = 12.0;
  static const double radiusXl = 20.0;

  // Thème clair
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primaryLight,
      onPrimary: primaryForegroundLight,
      secondary: secondaryLight,
      onSecondary: secondaryForegroundLight,
      surface: cardLight,
      onSurface: cardForegroundLight,
      error: destructiveLight,
      onError: destructiveForegroundLight,
      outline: borderLight,
    ),
    scaffoldBackgroundColor: backgroundLight,
    cardTheme: CardThemeData(
      color: cardLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        side: const BorderSide(color: borderLight, width: 1),
      ),
      shadowColor: Colors.black.withOpacity(0.04),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundLight,
      foregroundColor: foregroundLight,
      elevation: 0,
      centerTitle: false,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryLight,
        foregroundColor: primaryForegroundLight,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: foregroundLight,
        side: const BorderSide(color: borderLight, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: foregroundLight,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: inputBackgroundLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: const BorderSide(color: borderLight, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: const BorderSide(color: borderLight, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: const BorderSide(color: primaryLight, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: foregroundLight,
        height: 1.5,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: foregroundLight,
        height: 1.5,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: foregroundLight,
        height: 1.5,
      ),
      headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: foregroundLight,
        height: 1.5,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: foregroundLight,
        height: 1.5,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: foregroundLight,
        height: 1.5,
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: foregroundLight,
        height: 1.5,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: foregroundLight,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: foregroundLight,
        height: 1.5,
      ),
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: foregroundLight,
        height: 1.5,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: secondaryLight,
      labelStyle: const TextStyle(
        color: secondaryForegroundLight,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusSm),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    dividerTheme: const DividerThemeData(
      color: borderLight,
      thickness: 1,
      space: 1,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight;
        }
        return Colors.white;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight.withOpacity(0.5);
        }
        return switchBackgroundLight;
      }),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryLight,
      linearTrackColor: mutedLight,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: primaryForegroundLight,
      unselectedLabelColor: foregroundLight,
      indicator: BoxDecoration(
        color: primaryLight,
        borderRadius: BorderRadius.circular(radiusLg),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: Colors.transparent,
      labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    ),
  );

  // Thème sombre
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primaryDark,
      onPrimary: primaryForegroundDark,
      secondary: secondaryDark,
      onSecondary: secondaryForegroundDark,
      surface: cardDark,
      onSurface: cardForegroundDark,
      error: destructiveDark,
      onError: destructiveForegroundDark,
      outline: borderDark,
    ),
    scaffoldBackgroundColor: backgroundDark,
    cardTheme: CardThemeData(
      color: cardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        side: const BorderSide(color: borderDark, width: 1),
      ),
      shadowColor: Colors.black.withOpacity(0.2),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundDark,
      foregroundColor: foregroundDark,
      elevation: 0,
      centerTitle: false,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryDark,
        foregroundColor: primaryForegroundDark,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: foregroundDark,
        side: const BorderSide(color: borderDark, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: foregroundDark,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: inputBackgroundDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: const BorderSide(color: borderDark, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: const BorderSide(color: borderDark, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: const BorderSide(color: primaryDark, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w500,
        color: foregroundDark,
        height: 1.5,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w500,
        color: foregroundDark,
        height: 1.5,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: foregroundDark,
        height: 1.5,
      ),
      headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: foregroundDark,
        height: 1.5,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: foregroundDark,
        height: 1.5,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: foregroundDark,
        height: 1.5,
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: foregroundDark,
        height: 1.5,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: foregroundDark,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: foregroundDark,
        height: 1.5,
      ),
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: foregroundDark,
        height: 1.5,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: secondaryDark,
      labelStyle: const TextStyle(
        color: secondaryForegroundDark,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusSm),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    dividerTheme: const DividerThemeData(
      color: borderDark,
      thickness: 1,
      space: 1,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryDark;
        }
        return Colors.white;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryDark.withOpacity(0.5);
        }
        return switchBackgroundDark;
      }),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryDark,
      linearTrackColor: mutedDark,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: primaryForegroundDark,
      unselectedLabelColor: foregroundDark,
      indicator: BoxDecoration(
        color: primaryDark,
        borderRadius: BorderRadius.circular(radiusLg),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: Colors.transparent,
      labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      unselectedLabelStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    ),
  );

  // Utilitaires pour les effets personnalisés
  static BoxDecoration glassEffect(bool isDark) {
    return BoxDecoration(
      color: isDark
          ? const Color(0xB31A1A1A) // rgba(26, 26, 26, 0.7)
          : const Color(0xB3FFFFFF), // rgba(255, 255, 255, 0.7)
      borderRadius: BorderRadius.circular(radiusLg),
      border: Border.all(
        color: isDark
            ? Colors.white.withOpacity(0.1)
            : Colors.white.withOpacity(0.18),
        width: 1,
      ),
    );
  }

  static BoxShadow cardShadow = BoxShadow(
    color: Colors.black.withOpacity(0.04),
    blurRadius: 8,
    offset: const Offset(0, 2),
    spreadRadius: 0,
  );

  static BoxShadow cardShadowHover = BoxShadow(
    color: Colors.black.withOpacity(0.08),
    blurRadius: 24,
    offset: const Offset(0, 8),
    spreadRadius: 0,
  );

  static LinearGradient gradientPrimary = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
  );

  static LinearGradient gradientSecondary = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4ECDC4), Color(0xFF44A6A0)],
  );

  static LinearGradient gradientAccent = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF7B731), Color(0xFFF39C12)],
  );
}

// Extension pour faciliter l'utilisation
extension ThemeExtension on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get primaryColor => Theme.of(this).colorScheme.primary;
  Color get secondaryColor => Theme.of(this).colorScheme.secondary;
  Color get backgroundColor => Theme.of(this).scaffoldBackgroundColor;
  Color get cardColor => Theme.of(this).cardTheme.color!;
  Color get textColor => Theme.of(this).textTheme.bodyLarge!.color!;
}
