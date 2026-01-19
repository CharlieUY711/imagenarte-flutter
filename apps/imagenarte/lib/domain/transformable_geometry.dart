import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Geometría común para objetos transformables (selección ROI, watermark, etc.)
/// 
/// Define la forma, posición, tamaño y rotación de un objeto que puede
/// ser transformado con la misma herramienta unificada.
class TransformableGeometry {
  final TransformableShape shape;
  final Offset center;
  final Size size;
  final double rotation; // en radianes

  const TransformableGeometry({
    required this.shape,
    required this.center,
    required this.size,
    this.rotation = 0.0,
  });

  TransformableGeometry copyWith({
    TransformableShape? shape,
    Offset? center,
    Size? size,
    double? rotation,
  }) {
    return TransformableGeometry(
      shape: shape ?? this.shape,
      center: center ?? this.center,
      size: size ?? this.size,
      rotation: rotation ?? this.rotation,
    );
  }

  /// Obtiene el rectángulo bounding box (sin rotación)
  Rect get boundingBox {
    return Rect.fromCenter(
      center: center,
      width: size.width,
      height: size.height,
    );
  }

  /// Verifica si un punto está dentro de la geometría
  bool containsPoint(Offset point) {
    final rect = boundingBox;
    if (!rect.contains(point)) {
      return false;
    }

    if (shape == TransformableShape.rect) {
      return true;
    } else if (shape == TransformableShape.circle) {
      final radius = math.min(size.width, size.height) / 2;
      final distance = (point - center).distance;
      return distance <= radius;
    }
    return false;
  }
}

enum TransformableShape {
  rect,
  circle,
}
