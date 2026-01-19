import 'package:flutter/material.dart';

/// Modelo de transformación 2D para overlays
/// 
/// Define posición, rotación y escala (uniforme o no-uniforme) de un overlay transformable.
class Transform2D {
  /// Posición del centro del overlay (en coordenadas del canvas/preview)
  final Offset position;
  
  /// Rotación en radianes
  final double rotation;
  
  /// Escala en X e Y (permite escalado no-uniforme)
  final Size scale;
  
  /// Tamaño original del overlay sin transformar (bounding box local)
  final Size originalSize;

  const Transform2D({
    required this.position,
    this.rotation = 0.0,
    Size? scale,
    required this.originalSize,
  }) : scale = scale ?? const Size(1.0, 1.0);

  Transform2D copyWith({
    Offset? position,
    double? rotation,
    Size? scale,
    Size? originalSize,
  }) {
    return Transform2D(
      position: position ?? this.position,
      rotation: rotation ?? this.rotation,
      scale: scale ?? this.scale,
      originalSize: originalSize ?? this.originalSize,
    );
  }

  /// Obtiene el tamaño actual (escalado)
  Size get currentSize => Size(
    originalSize.width * scale.width,
    originalSize.height * scale.height,
  );

  /// Obtiene el rectángulo bounding box (sin rotación)
  Rect get boundingBox {
    final size = currentSize;
    return Rect.fromCenter(
      center: position,
      width: size.width,
      height: size.height,
    );
  }

  /// Crea una matriz de transformación 4x4 para aplicar con Transform widget
  Matrix4 toMatrix4() {
    return Matrix4.identity()
      ..translate(position.dx, position.dy)
      ..rotateZ(rotation)
      ..scale(scale.width, scale.height)
      ..translate(-originalSize.width / 2, -originalSize.height / 2);
  }

  /// Verifica si un punto está dentro del bounding box transformado
  /// (considera rotación aplicando transformación inversa)
  bool containsPoint(Offset point) {
    final rect = boundingBox;
    if (!rect.contains(point)) {
      return false;
    }

    // Si hay rotación, aplicar transformación inversa
    if (rotation != 0.0) {
      final inverseMatrix = Matrix4.identity()
        ..translate(-position.dx, -position.dy)
        ..rotateZ(-rotation)
        ..translate(position.dx, position.dy);
      
      final transformedPoint = MatrixUtils.transformPoint(inverseMatrix, point);
      final localRect = Rect.fromCenter(
        center: position,
        width: currentSize.width,
        height: currentSize.height,
      );
      return localRect.contains(transformedPoint);
    }

    return true;
  }
}

/// Tipo de item transformable
enum TransformableItemType {
  watermark,
  text,
  logo,
  roi,
}

/// Item transformable con su configuración
class TransformableItem {
  /// Identificador único
  final String id;
  
  /// Transformación 2D
  final Transform2D transform;
  
  /// Tipo de item
  final TransformableItemType type;
  
  /// Payload específico del tipo (ej: image bytes, text style, etc.)
  final dynamic payload;
  
  /// Si está seleccionado
  final bool isSelected;

  const TransformableItem({
    required this.id,
    required this.transform,
    required this.type,
    this.payload,
    this.isSelected = false,
  });

  TransformableItem copyWith({
    String? id,
    Transform2D? transform,
    TransformableItemType? type,
    dynamic payload,
    bool? isSelected,
  }) {
    return TransformableItem(
      id: id ?? this.id,
      transform: transform ?? this.transform,
      type: type ?? this.type,
      payload: payload ?? this.payload,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

/// Configuración de handles para transformación
class TransformHandlesConfig {
  /// Mostrar handles de esquina
  final bool showCornerHandles;
  
  /// Mostrar handles de borde (solo si item permite non-uniform scale)
  final bool showEdgeHandles;
  
  /// Mostrar handle de rotación
  final bool showRotateHandle;
  
  /// Escala mínima permitida
  final double minScale;
  
  /// Escala máxima permitida
  final double maxScale;
  
  /// Si el item debe mantener proporción (uniform scale)
  final bool maintainAspectRatio;

  const TransformHandlesConfig({
    this.showCornerHandles = true,
    this.showEdgeHandles = true,
    this.showRotateHandle = true,
    this.minScale = 0.1,
    this.maxScale = 5.0,
    this.maintainAspectRatio = false,
  });
}
