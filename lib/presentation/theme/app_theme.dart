import 'package:flutter/material.dart';

/// Tokens de diseño según Figma
/// Extraídos de figma_extracted/src/styles/theme.css
class AppTokens {
  // Alturas
  static const double toolbarHeight = 25.0;
  static const double dialButtonHeight = 30.0;
  
  // Colores del sistema de diseño Figma
  // Basados en theme.css - modo claro
  static const Color background = Color(0xFFFFFFFF); // --background: #ffffff
  static const Color foreground = Color(0xFF1A1A1A); // --foreground: #1a1a1a
  static const Color card = Color(0xFFFFFFFF); // --card: #ffffff
  static const Color cardForeground = Color(0xFF1A1A1A); // --card-foreground: #1a1a1a
  static const Color popover = Color(0xFFFFFFFF); // --popover: #ffffff
  static const Color popoverForeground = Color(0xFF1A1A1A); // --popover-foreground: #1a1a1a
  static const Color primary = Color(0xFF1A1A1A); // --primary: #1a1a1a
  static const Color primaryForeground = Color(0xFFFFFFFF); // --primary-foreground: #ffffff
  static const Color secondary = Color(0xFFF5F5F5); // --secondary: #f5f5f5
  static const Color secondaryForeground = Color(0xFF1A1A1A); // --secondary-foreground: #1a1a1a
  static const Color muted = Color(0xFFF5F5F5); // --muted: #f5f5f5
  static const Color mutedForeground = Color(0xFF737373); // --muted-foreground: #737373
  static const Color accent = Color(0xFFF5F5F5); // --accent: #f5f5f5
  static const Color accentForeground = Color(0xFF1A1A1A); // --accent-foreground: #1a1a1a
  static const Color destructive = Color(0xFFDC2626); // --destructive: #dc2626
  static const Color destructiveForeground = Color(0xFFFFFFFF); // --destructive-foreground: #ffffff
  static const Color border = Color(0xFFE5E5E5); // --border: #e5e5e5
  static const Color input = Colors.transparent; // --input: transparent
  static const Color inputBackground = Color(0xFFF5F5F5); // --input-background: #f5f5f5
  static const Color switchBackground = Color(0xFFD4D4D4); // --switch-background: #d4d4d4
  static const Color ring = Color(0xFFA3A3A3); // --ring: #a3a3a3
  
  // Color naranja de acento (usado en DialButton y componentes activos)
  static const Color accentOrange = Color(0xFFF97316); // #f97316 (orange-500)
  
  // Colores específicos del editor (modo oscuro para que la imagen destaque)
  static const Color editorBackground = Color(0xFF000000); // fondo negro para que la imagen destaque
  static const Color editorSurface = Color(0xFF1C1C1E); // #1C1C1E (usado en DialButton)
  static const Color editorSurfaceHover = Color(0xFF2C2C2E); // #2C2C2E (hover state)
  
  // Colores neutrales para paneles y overlays
  static const Color neutralDark = Color(0xFF1C1C1E); // Similar a editorSurface, para paneles oscuros
  static const Color neutralMedium = Color(0xFF737373); // Similar a mutedForeground, para elementos secundarios
  
  // Border radius
  static const double radius = 12.0; // --radius: 0.75rem (12px)
  static const double radiusSm = 8.0; // --radius-sm: calc(var(--radius) - 4px)
  static const double radiusMd = 10.0; // --radius-md: calc(var(--radius) - 2px)
  static const double radiusLg = 12.0; // --radius-lg: var(--radius)
  static const double radiusXl = 16.0; // --radius-xl: calc(var(--radius) + 4px)
  
  // Tipografía
  static const double fontSizeBase = 16.0; // --font-size: 16px
  static const FontWeight fontWeightNormal = FontWeight.w400; // --font-weight-normal: 400
  static const FontWeight fontWeightMedium = FontWeight.w500; // --font-weight-medium: 500
  
  // Espaciado
  static const double spacingBase = 16.0; // 1rem
  static const double spacingGap = 12.0; // 0.75rem
}

/// Tema de la aplicación para el Editor
/// Basado en el sistema de diseño de Figma
class AppThemeEditor {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppTokens.primary,
        onPrimary: AppTokens.primaryForeground,
        secondary: AppTokens.secondary,
        onSecondary: AppTokens.secondaryForeground,
        surface: AppTokens.card,
        onSurface: AppTokens.cardForeground,
        background: AppTokens.background,
        onBackground: AppTokens.foreground,
        error: AppTokens.destructive,
        onError: AppTokens.destructiveForeground,
        outline: AppTokens.border,
      ),
      scaffoldBackgroundColor: AppTokens.background,
      cardTheme: CardThemeData(
        color: AppTokens.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppTokens.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radius),
          borderSide: BorderSide(color: AppTokens.border),
        ),
      ),
    );
  }
  
  /// Tema oscuro para el editor (donde se muestra la imagen)
  static ThemeData get darkEditorTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: AppTokens.accentOrange,
        onPrimary: Colors.white,
        surface: AppTokens.editorSurface,
        background: AppTokens.editorBackground,
        onSurface: Colors.white,
        onBackground: Colors.white,
      ),
      scaffoldBackgroundColor: AppTokens.editorBackground,
    );
  }
}
