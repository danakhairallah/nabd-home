import 'package:flutter/material.dart';

class AppGradient extends ThemeExtension<AppGradient> {
  final LinearGradient background;

  const AppGradient({required this.background});

  @override
  AppGradient copyWith({LinearGradient? background}) {
    return AppGradient(background: background ?? this.background);
  }

  @override
  AppGradient lerp(ThemeExtension<AppGradient>? other, double t) {
    if (other is! AppGradient) return this;
    return AppGradient(
      background: LinearGradient.lerp(background, other.background, t)!,
    );
  }
}

class AppTheme {
  static const Color primary = Color(0xFF151922);
  static const Color secondary = Color(0xFF0A286D);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.black87;
  static const Color navSelected = Colors.blue;
  static const Color navUnselected = Colors.grey;

  static const LinearGradient mainGradient = LinearGradient(
    colors: [secondary, primary],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ThemeData lightTheme = ThemeData(
    extensions: <ThemeExtension<dynamic>>[
      const AppGradient(background: mainGradient),
    ],
    scaffoldBackgroundColor: Colors.transparent,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textPrimary),
      bodyMedium: TextStyle(color: textPrimary),
      titleLarge: TextStyle(color: textPrimary),
      titleMedium: TextStyle(color: textPrimary),
      labelLarge: TextStyle(color: textPrimary),
    ),
    iconTheme: const IconThemeData(color: textPrimary),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: textPrimary),
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      selectedItemColor: navSelected,
      unselectedItemColor: navUnselected,
      type: BottomNavigationBarType.fixed,
    ),
  );
}
