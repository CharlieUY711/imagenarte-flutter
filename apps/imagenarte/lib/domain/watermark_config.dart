import 'package:flutter/material.dart';
import 'package:imagenarte/domain/transformable_geometry.dart';

/// Configuración completa de marca de agua
/// 
/// Modelo puro en domain que define todos los parámetros de la marca de agua.
class WatermarkConfig {
  final bool enabled;
  final WatermarkType type;
  final String text; // Si type == text
  final String? imagePath; // Si type == image, ruta local del logo
  final double opacity; // 0.0 - 1.0
  final Color color; // Para texto
  final WatermarkOutline? outline; // Opcional
  final WatermarkShadow? shadow; // Opcional
  final TransformableGeometry transform; // Posición, tamaño, rotación
  final bool locked; // Bloquear transformaciones
  final WatermarkAnchorPreset anchorPreset; // Preset de posición
  final double safeMargin; // Margen seguro normalizado (0.0 - 1.0)

  const WatermarkConfig({
    required this.enabled,
    required this.type,
    this.text = '@imagenarte',
    this.imagePath,
    this.opacity = 0.35,
    this.color = const Color(0xFFFFFFFF), // Blanco por defecto
    this.outline,
    this.shadow,
    required this.transform,
    this.locked = false,
    this.anchorPreset = WatermarkAnchorPreset.custom,
    this.safeMargin = 0.03, // 3% de margen
  });

  WatermarkConfig copyWith({
    bool? enabled,
    WatermarkType? type,
    String? text,
    String? imagePath,
    double? opacity,
    Color? color,
    WatermarkOutline? outline,
    WatermarkShadow? shadow,
    TransformableGeometry? transform,
    bool? locked,
    WatermarkAnchorPreset? anchorPreset,
    double? safeMargin,
  }) {
    return WatermarkConfig(
      enabled: enabled ?? this.enabled,
      type: type ?? this.type,
      text: text ?? this.text,
      imagePath: imagePath ?? this.imagePath,
      opacity: opacity ?? this.opacity,
      color: color ?? this.color,
      outline: outline ?? this.outline,
      shadow: shadow ?? this.shadow,
      transform: transform ?? this.transform,
      locked: locked ?? this.locked,
      anchorPreset: anchorPreset ?? this.anchorPreset,
      safeMargin: safeMargin ?? this.safeMargin,
    );
  }
}

/// Tipo de marca de agua
enum WatermarkType {
  text,
  image,
}

/// Configuración de outline (contorno) para texto
class WatermarkOutline {
  final bool enabled;
  final Color color;
  final double width; // En píxeles

  const WatermarkOutline({
    required this.enabled,
    this.color = const Color(0xFF000000), // Negro por defecto
    this.width = 2.0,
  });

  WatermarkOutline copyWith({
    bool? enabled,
    Color? color,
    double? width,
  }) {
    return WatermarkOutline(
      enabled: enabled ?? this.enabled,
      color: color ?? this.color,
      width: width ?? this.width,
    );
  }
}

/// Configuración de sombra para texto
class WatermarkShadow {
  final bool enabled;
  final double blur; // Radio de blur en píxeles
  final Offset offset; // Offset de la sombra
  final Color color;

  const WatermarkShadow({
    required this.enabled,
    this.blur = 4.0,
    this.offset = const Offset(2.0, 2.0),
    this.color = const Color(0x80000000), // Negro semi-transparente
  });

  WatermarkShadow copyWith({
    bool? enabled,
    double? blur,
    Offset? offset,
    Color? color,
  }) {
    return WatermarkShadow(
      enabled: enabled ?? this.enabled,
      blur: blur ?? this.blur,
      offset: offset ?? this.offset,
      color: color ?? this.color,
    );
  }
}

/// Presets de posición (9-grid)
enum WatermarkAnchorPreset {
  topLeft,
  topCenter,
  topRight,
  middleLeft,
  center,
  middleRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
  custom, // Posición manual
}
