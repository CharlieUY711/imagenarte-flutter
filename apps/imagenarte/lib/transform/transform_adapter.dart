import 'package:flutter/material.dart';
import 'package:imagenarte/domain/transformable_geometry.dart';
import 'package:imagenarte/transform/transform_model.dart';

/// Adaptador para convertir entre TransformableGeometry (legacy) y Transform2D (nuevo)
class TransformAdapter {
  /// Convierte TransformableGeometry a Transform2D
  static Transform2D fromTransformableGeometry(TransformableGeometry geometry) {
    return Transform2D(
      position: geometry.center,
      rotation: geometry.rotation,
      scale: const Size(1.0, 1.0), // TransformableGeometry no tiene escala separada
      originalSize: geometry.size,
    );
  }

  /// Convierte Transform2D a TransformableGeometry
  static TransformableGeometry toTransformableGeometry(
    Transform2D transform,
    TransformableShape shape,
  ) {
    // Aplicar escala al tamaño
    final scaledSize = Size(
      transform.originalSize.width * transform.scale.width,
      transform.originalSize.height * transform.scale.height,
    );

    return TransformableGeometry(
      shape: shape,
      center: transform.position,
      size: scaledSize,
      rotation: transform.rotation,
    );
  }
}
