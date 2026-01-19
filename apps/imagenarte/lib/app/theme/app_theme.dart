import 'package:flutter/material.dart';
import 'package:imagenarte/app/theme/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.dark(
        primary: AppColors.accent,
        surface: AppColors.background,
        onSurface: AppColors.foreground,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppColors.foreground),
        displayMedium: TextStyle(color: AppColors.foreground),
        displaySmall: TextStyle(color: AppColors.foreground),
        headlineLarge: TextStyle(color: AppColors.foreground),
        headlineMedium: TextStyle(color: AppColors.foreground),
        headlineSmall: TextStyle(color: AppColors.foreground),
        titleLarge: TextStyle(color: AppColors.foreground),
        titleMedium: TextStyle(color: AppColors.foreground),
        titleSmall: TextStyle(color: AppColors.foreground),
        bodyLarge: TextStyle(color: AppColors.foreground),
        bodyMedium: TextStyle(color: AppColors.foreground),
        bodySmall: TextStyle(color: AppColors.foreground),
        labelLarge: TextStyle(color: AppColors.foreground),
        labelMedium: TextStyle(color: AppColors.foreground),
        labelSmall: TextStyle(color: AppColors.foreground),
      ),
    );
  }
}
