import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:imagenarte/transform/transform_model.dart';

/// Tipo de handle detectado
enum HandleType {
  corner,
  edge,
  rotate,
  center,
  none,
}

/// Información sobre el handle detectado
class HandleInfo {
  final HandleType type;
  final Offset position;
  final int? cornerIndex; // 0-3 para esquinas
  final String? edgeSide; // 'top', 'right', 'bottom', 'left'

  HandleInfo({
    required this.type,
    required this.position,
    this.cornerIndex,
    this.edgeSide,
  });
}

/// Detector de gestos para transformaciones
/// 
/// Maneja hit testing y detección de handles para drag/scale/rotate.
class TransformGestureDetector {
  /// Radio táctil mínimo para handles (18-24dp recomendado)
  static const double handleTouchRadius = 20.0;

  /// Deadzone para handles de borde (5% del lado)
  static const double edgeDeadzone = 0.05;

  /// Detecta qué tipo de handle fue tocado en un punto dado
  static HandleInfo detectHandle({
    required Offset point,
    required Transform2D transform,
    required TransformHandlesConfig config,
  }) {
    final rect = transform.boundingBox;
    final center = transform.position;
    final size = transform.currentSize;

    // 1. Verificar handle de rotación (arriba del centro)
    if (config.showRotateHandle) {
      final rotateHandle = Offset(center.dx, rect.top - 30);
      if ((point - rotateHandle).distance < handleTouchRadius) {
        return HandleInfo(
          type: HandleType.rotate,
          position: rotateHandle,
        );
      }
    }

    // 2. Verificar handles de esquina
    if (config.showCornerHandles) {
      final corners = _getCornerHandles(rect);
      for (int i = 0; i < corners.length; i++) {
        if ((point - corners[i]).distance < handleTouchRadius) {
          return HandleInfo(
            type: HandleType.corner,
            position: corners[i],
            cornerIndex: i,
          );
        }
      }
    }

    // 3. Verificar handles de borde (solo si está habilitado y no-uniform scale)
    if (config.showEdgeHandles && !config.maintainAspectRatio) {
      final edgeInfo = _detectEdgeHandle(point, rect, size);
      if (edgeInfo != null) {
        return edgeInfo;
      }
    }

    // 4. Verificar si está dentro del bounding box (centro para mover)
    if (transform.containsPoint(point)) {
      return HandleInfo(
        type: HandleType.center,
        position: center,
      );
    }

    return HandleInfo(
      type: HandleType.none,
      position: point,
    );
  }

  /// Obtiene las posiciones de los handles de esquina
  static List<Offset> _getCornerHandles(Rect rect) {
    return [
      Offset(rect.left, rect.top),
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.bottom),
      Offset(rect.left, rect.bottom),
    ];
  }

  /// Detecta si el punto está en un handle de borde (con deadzone)
  static HandleInfo? _detectEdgeHandle(
    Offset point,
    Rect rect,
    Size size,
  ) {
    final deadzoneSize = math.min(size.width, size.height) * edgeDeadzone;

    // Top edge
    if ((point.dy - rect.top).abs() < handleTouchRadius &&
        point.dx >= rect.left + deadzoneSize &&
        point.dx <= rect.right - deadzoneSize) {
      return HandleInfo(
        type: HandleType.edge,
        position: Offset(rect.center.dx, rect.top),
        edgeSide: 'top',
      );
    }

    // Right edge
    if ((point.dx - rect.right).abs() < handleTouchRadius &&
        point.dy >= rect.top + deadzoneSize &&
        point.dy <= rect.bottom - deadzoneSize) {
      return HandleInfo(
        type: HandleType.edge,
        position: Offset(rect.right, rect.center.dy),
        edgeSide: 'right',
      );
    }

    // Bottom edge
    if ((point.dy - rect.bottom).abs() < handleTouchRadius &&
        point.dx >= rect.left + deadzoneSize &&
        point.dx <= rect.right - deadzoneSize) {
      return HandleInfo(
        type: HandleType.edge,
        position: Offset(rect.center.dx, rect.bottom),
        edgeSide: 'bottom',
      );
    }

    // Left edge
    if ((point.dx - rect.left).abs() < handleTouchRadius &&
        point.dy >= rect.top + deadzoneSize &&
        point.dy <= rect.bottom - deadzoneSize) {
      return HandleInfo(
        type: HandleType.edge,
        position: Offset(rect.left, rect.center.dy),
        edgeSide: 'left',
      );
    }

    return null;
  }

  /// Calcula la nueva transformación después de un drag
  static Transform2D applyDrag({
    required Transform2D currentTransform,
    required Offset startPoint,
    required Offset currentPoint,
    required HandleInfo handleInfo,
    required TransformHandlesConfig config,
  }) {
    switch (handleInfo.type) {
      case HandleType.center:
        // Mover (translate)
        final delta = currentPoint - startPoint;
        return currentTransform.copyWith(
          position: currentTransform.position + delta,
        );

      case HandleType.corner:
        // Escalar desde esquina (uniforme si maintainAspectRatio, sino no-uniforme)
        return _applyCornerScale(
          currentTransform: currentTransform,
          startPoint: startPoint,
          currentPoint: currentPoint,
          cornerIndex: handleInfo.cornerIndex!,
          config: config,
        );

      case HandleType.edge:
        // Escalar desde borde (no-uniforme, perpendicular al borde)
        return _applyEdgeScale(
          currentTransform: currentTransform,
          startPoint: startPoint,
          currentPoint: currentPoint,
          edgeSide: handleInfo.edgeSide!,
          config: config,
        );

      case HandleType.rotate:
        // Rotar
        return _applyRotation(
          currentTransform: currentTransform,
          startPoint: startPoint,
          currentPoint: currentPoint,
        );

      case HandleType.none:
        return currentTransform;
    }
  }

  /// Aplica escalado desde esquina
  static Transform2D _applyCornerScale({
    required Transform2D currentTransform,
    required Offset startPoint,
    required Offset currentPoint,
    required int cornerIndex,
    required TransformHandlesConfig config,
  }) {
    final center = currentTransform.position;
    final startDistance = (startPoint - center).distance;
    final currentDistance = (currentPoint - center).distance;

    if (startDistance == 0) return currentTransform;

    final scaleFactor = currentDistance / startDistance;
    final newScale = Size(
      (currentTransform.scale.width * scaleFactor).clamp(config.minScale, config.maxScale),
      config.maintainAspectRatio
          ? (currentTransform.scale.width * scaleFactor).clamp(config.minScale, config.maxScale)
          : (currentTransform.scale.height * scaleFactor).clamp(config.minScale, config.maxScale),
    );

    return currentTransform.copyWith(scale: newScale);
  }

  /// Aplica escalado desde borde (no-uniforme)
  static Transform2D _applyEdgeScale({
    required Transform2D currentTransform,
    required Offset startPoint,
    required Offset currentPoint,
    required String edgeSide,
    required TransformHandlesConfig config,
  }) {
    final rect = currentTransform.boundingBox;
    final deadzoneSize = math.min(rect.width, rect.height) * edgeDeadzone;

    double delta;
    switch (edgeSide) {
      case 'top':
        delta = startPoint.dy - currentPoint.dy; // Invertido porque Y crece hacia abajo
        if ((startPoint.dx - rect.left).abs() < deadzoneSize ||
            (startPoint.dx - rect.right).abs() < deadzoneSize) {
          return currentTransform; // En deadzone
        }
        final newHeight = (currentTransform.scale.height * currentTransform.originalSize.height + delta)
            .clamp(config.minScale * currentTransform.originalSize.height, config.maxScale * currentTransform.originalSize.height);
        final newScaleY = newHeight / currentTransform.originalSize.height;
        return currentTransform.copyWith(
          scale: Size(currentTransform.scale.width, newScaleY),
        );

      case 'bottom':
        delta = currentPoint.dy - startPoint.dy;
        if ((startPoint.dx - rect.left).abs() < deadzoneSize ||
            (startPoint.dx - rect.right).abs() < deadzoneSize) {
          return currentTransform;
        }
        final newHeight = (currentTransform.scale.height * currentTransform.originalSize.height + delta)
            .clamp(config.minScale * currentTransform.originalSize.height, config.maxScale * currentTransform.originalSize.height);
        final newScaleY = newHeight / currentTransform.originalSize.height;
        return currentTransform.copyWith(
          scale: Size(currentTransform.scale.width, newScaleY),
        );

      case 'left':
        delta = startPoint.dx - currentPoint.dx;
        if ((startPoint.dy - rect.top).abs() < deadzoneSize ||
            (startPoint.dy - rect.bottom).abs() < deadzoneSize) {
          return currentTransform;
        }
        final newWidth = (currentTransform.scale.width * currentTransform.originalSize.width + delta)
            .clamp(config.minScale * currentTransform.originalSize.width, config.maxScale * currentTransform.originalSize.width);
        final newScaleX = newWidth / currentTransform.originalSize.width;
        return currentTransform.copyWith(
          scale: Size(newScaleX, currentTransform.scale.height),
        );

      case 'right':
        delta = currentPoint.dx - startPoint.dx;
        if ((startPoint.dy - rect.top).abs() < deadzoneSize ||
            (startPoint.dy - rect.bottom).abs() < deadzoneSize) {
          return currentTransform;
        }
        final newWidth = (currentTransform.scale.width * currentTransform.originalSize.width + delta)
            .clamp(config.minScale * currentTransform.originalSize.width, config.maxScale * currentTransform.originalSize.width);
        final newScaleX = newWidth / currentTransform.originalSize.width;
        return currentTransform.copyWith(
          scale: Size(newScaleX, currentTransform.scale.height),
        );

      default:
        return currentTransform;
    }
  }

  /// Aplica rotación
  static Transform2D _applyRotation({
    required Transform2D currentTransform,
    required Offset startPoint,
    required Offset currentPoint,
  }) {
    final center = currentTransform.position;
    final startAngle = math.atan2(
      startPoint.dy - center.dy,
      startPoint.dx - center.dx,
    );
    final currentAngle = math.atan2(
      currentPoint.dy - center.dy,
      currentPoint.dx - center.dx,
    );
    final deltaAngle = currentAngle - startAngle;
    final newRotation = (currentTransform.rotation + deltaAngle) % (2 * math.pi);

    return currentTransform.copyWith(rotation: newRotation);
  }
}
