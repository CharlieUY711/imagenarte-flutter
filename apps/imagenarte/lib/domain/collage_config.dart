import 'package:flutter/material.dart';

/// Configuración de collage
class CollageConfig {
  final CollageLayoutType layoutType;
  final int rows;
  final int cols;
  final double spacing; // Espaciado entre celdas (en píxeles)
  final double padding; // Padding alrededor del collage (en píxeles)
  final Color? backgroundColor; // Color de fondo (opcional)

  const CollageConfig({
    required this.layoutType,
    required this.rows,
    required this.cols,
    this.spacing = 4.0,
    this.padding = 0.0,
    this.backgroundColor,
  });

  CollageConfig copyWith({
    CollageLayoutType? layoutType,
    int? rows,
    int? cols,
    double? spacing,
    double? padding,
    Color? backgroundColor,
  }) {
    return CollageConfig(
      layoutType: layoutType ?? this.layoutType,
      rows: rows ?? this.rows,
      cols: cols ?? this.cols,
      spacing: spacing ?? this.spacing,
      padding: padding ?? this.padding,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }
}

enum CollageLayoutType {
  grid, // Grid regular
  // Futuros: masonry, staggered, etc.
}
