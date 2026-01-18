import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:imagenarte/app/theme/app_colors.dart';
import 'package:imagenarte/application/editor_ui_state.dart';
import 'package:imagenarte/domain/transformable_geometry.dart';
import 'package:provider/provider.dart';

/// Widget unificado para renderizar handles y bounding box de objetos transformables
/// 
/// Funciona tanto para selección ROI como para watermark.
/// La renderización depende de activeTransformTarget, no del tipo de objeto.
class TransformTool extends StatelessWidget {
  const TransformTool({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EditorUiState>(
      builder: (context, uiState, child) {
        // Solo mostrar si hay un target activo de transformación
        if (uiState.activeTransformTarget == TransformTarget.none) {
          return const SizedBox.shrink();
        }

        TransformableGeometry? geometry;
        
        // Obtener geometría según el target
        switch (uiState.activeTransformTarget) {
          case TransformTarget.selection:
            geometry = uiState.selectionGeometry;
            break;
          case TransformTarget.watermarkText:
          case TransformTarget.watermarkLogo:
            geometry = uiState.watermarkGeometry;
            break;
          case TransformTarget.none:
            return const SizedBox.shrink();
        }

        if (geometry == null) {
          return const SizedBox.shrink();
        }

        return _TransformHandles(
          geometry: geometry,
          onGeometryChanged: (newGeometry) {
            if (uiState.activeTransformTarget == TransformTarget.selection) {
              uiState.updateSelectionGeometry(newGeometry);
            } else {
              uiState.updateWatermarkGeometry(newGeometry);
            }
          },
        );
      },
    );
  }
}

class _TransformHandles extends StatefulWidget {
  final TransformableGeometry geometry;
  final ValueChanged<TransformableGeometry> onGeometryChanged;

  const _TransformHandles({
    required this.geometry,
    required this.onGeometryChanged,
  });

  @override
  State<_TransformHandles> createState() => _TransformHandlesState();
}

class _TransformHandlesState extends State<_TransformHandles> {
  late TransformableGeometry _currentGeometry;
  Offset? _dragStart;
  Offset? _dragStartCenter;
  Size? _dragStartSize;
  double? _dragStartRotation;
  bool _isDragging = false;
  bool _isResizing = false;
  bool _isRotating = false;
  _SideHandleType? _resizeHandle;

  @override
  void initState() {
    super.initState();
    _currentGeometry = widget.geometry;
  }

  @override
  void didUpdateWidget(_TransformHandles oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.geometry != oldWidget.geometry) {
      _currentGeometry = widget.geometry;
    }
  }

  void _onPanStart(DragStartDetails details) {
    final localPosition = details.localPosition;
    final rect = _currentGeometry.boundingBox;
    final isCircle = _currentGeometry.shape == TransformableShape.circle;
    
    // Verificar si está en un handle de esquina (resize) - solo para rect
    if (!isCircle) {
      const handleSize = 12.0;
      final handles = _getCornerHandles(rect);
      
      for (final handle in handles) {
        if ((localPosition - handle).distance < handleSize) {
          _isResizing = true;
          _dragStart = localPosition;
          _dragStartCenter = _currentGeometry.center;
          _dragStartSize = _currentGeometry.size;
          return;
        }
      }
      
      // Verificar handles de lado (resize 1D) para rect
      final sideHandles = _getSideHandles(rect);
      for (final handle in sideHandles) {
        if ((localPosition - handle.position).distance < handleSize) {
          _isResizing = true;
          _dragStart = localPosition;
          _dragStartCenter = _currentGeometry.center;
          _dragStartSize = _currentGeometry.size;
          _resizeHandle = handle.type;
          return;
        }
      }
    } else {
      // Para círculo: verificar si está cerca del borde (resize proporcional)
      final radius = math.min(_currentGeometry.size.width, _currentGeometry.size.height) / 2;
      final distanceFromCenter = (localPosition - _currentGeometry.center).distance;
      const handleSize = 12.0;
      
      if ((distanceFromCenter - radius).abs() < handleSize) {
        _isResizing = true;
        _dragStart = localPosition;
        _dragStartCenter = _currentGeometry.center;
        _dragStartSize = _currentGeometry.size;
        return;
      }
    }
    
    // Verificar si está en el handle de rotación (solo para rect)
    if (!isCircle) {
      final rotationHandle = _getRotationHandle(rect);
      const handleSize = 12.0;
      if ((localPosition - rotationHandle).distance < handleSize) {
        _isRotating = true;
        _dragStart = localPosition;
        _dragStartRotation = _currentGeometry.rotation;
        return;
      }
    }
    
    // Si está dentro de la geometría, mover
    if (_currentGeometry.containsPoint(localPosition)) {
      _isDragging = true;
      _dragStart = localPosition;
      _dragStartCenter = _currentGeometry.center;
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDragging && !_isResizing && !_isRotating) return;

    final delta = details.localPosition - _dragStart!;
    final isCircle = _currentGeometry.shape == TransformableShape.circle;

    if (_isDragging) {
      final newCenter = _dragStartCenter! + delta;
      setState(() {
        _currentGeometry = _currentGeometry.copyWith(center: newCenter);
      });
      widget.onGeometryChanged(_currentGeometry);
    } else if (_isResizing) {
      if (isCircle) {
        // Resize círculo: mantener proporción (siempre círculo)
        final startDistance = (_dragStart! - _dragStartCenter!).distance;
        final currentDistance = (details.localPosition - _dragStartCenter!).distance;
        final scale = currentDistance / startDistance;
        final newRadius = math.min(_dragStartSize!.width, _dragStartSize!.height) / 2 * scale;
        final clampedRadius = newRadius.clamp(30.0, 500.0);
        final newSize = Size(clampedRadius * 2, clampedRadius * 2);
        setState(() {
          _currentGeometry = _currentGeometry.copyWith(size: newSize);
        });
        widget.onGeometryChanged(_currentGeometry);
      } else {
        // Resize rectángulo
        if (_resizeHandle == null) {
          // Resize desde esquina: scale proporcional
          final scale = 1.0 + (delta.dx + delta.dy) / 100.0;
          final newSize = Size(
            (_dragStartSize!.width * scale).clamp(50.0, 500.0),
            (_dragStartSize!.height * scale).clamp(50.0, 500.0),
          );
          setState(() {
            _currentGeometry = _currentGeometry.copyWith(size: newSize);
          });
          widget.onGeometryChanged(_currentGeometry);
        } else {
          // Resize desde lado: 1D perpendicular con deadzone
          final rect = Rect.fromCenter(
            center: _dragStartCenter!,
            width: _dragStartSize!.width,
            height: _dragStartSize!.height,
          );
          final deadzone = 0.05; // 5%
          
          switch (_resizeHandle!) {
            case _SideHandleType.top:
            case _SideHandleType.bottom:
              final sideLength = rect.width;
              final deadzoneSize = sideLength * deadzone;
              final effectiveStart = _dragStart!.dx;
              if ((effectiveStart - rect.left).abs() < deadzoneSize ||
                  (effectiveStart - rect.right).abs() < deadzoneSize) {
                return; // En deadzone, no hacer resize
              }
              final newHeight = (_dragStartSize!.height + delta.dy).clamp(50.0, 500.0);
              setState(() {
                _currentGeometry = _currentGeometry.copyWith(size: Size(_dragStartSize!.width, newHeight));
              });
              widget.onGeometryChanged(_currentGeometry);
              break;
            case _SideHandleType.left:
            case _SideHandleType.right:
              final sideLength = rect.height;
              final deadzoneSize = sideLength * deadzone;
              final effectiveStart = _dragStart!.dy;
              if ((effectiveStart - rect.top).abs() < deadzoneSize ||
                  (effectiveStart - rect.bottom).abs() < deadzoneSize) {
                return; // En deadzone, no hacer resize
              }
              final newWidth = (_dragStartSize!.width + delta.dx).clamp(50.0, 500.0);
              setState(() {
                _currentGeometry = _currentGeometry.copyWith(size: Size(newWidth, _dragStartSize!.height));
              });
              widget.onGeometryChanged(_currentGeometry);
              break;
          }
        }
      }
    } else if (_isRotating) {
      final center = _currentGeometry.center;
      final angle1 = math.atan2(
        _dragStart!.dy - center.dy,
        _dragStart!.dx - center.dx,
      );
      final angle2 = math.atan2(
        details.localPosition.dy - center.dy,
        details.localPosition.dx - center.dx,
      );
      final newRotation = (_dragStartRotation! + (angle2 - angle1)) % (2 * math.pi);
      setState(() {
        _currentGeometry = _currentGeometry.copyWith(rotation: newRotation);
      });
      widget.onGeometryChanged(_currentGeometry);
    }
  }

  void _onPanEnd(DragEndDetails details) {
    _isDragging = false;
    _isResizing = false;
    _isRotating = false;
    _resizeHandle = null;
    _dragStart = null;
  }

  List<Offset> _getCornerHandles(Rect rect) {
    return [
      Offset(rect.left, rect.top),
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.bottom),
      Offset(rect.left, rect.bottom),
    ];
  }

  List<_SideHandle> _getSideHandles(Rect rect) {
    return [
      _SideHandle(Offset(rect.center.dx, rect.top), _SideHandleType.top),
      _SideHandle(Offset(rect.right, rect.center.dy), _SideHandleType.right),
      _SideHandle(Offset(rect.center.dx, rect.bottom), _SideHandleType.bottom),
      _SideHandle(Offset(rect.left, rect.center.dy), _SideHandleType.left),
    ];
  }

  Offset _getRotationHandle(Rect rect) {
    return Offset(rect.center.dx, rect.top - 30);
  }

  @override
  Widget build(BuildContext context) {
    final rect = _currentGeometry.boundingBox;
    final isCircle = _currentGeometry.shape == TransformableShape.circle;
    final handles = isCircle ? <Offset>[] : _getCornerHandles(rect);
    final sideHandles = isCircle ? <_SideHandle>[] : _getSideHandles(rect);
    final rotationHandle = isCircle ? null : _getRotationHandle(rect);

    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: CustomPaint(
        painter: _TransformPainter(
          shape: _currentGeometry.shape,
          rect: rect,
          center: _currentGeometry.center,
          radius: isCircle ? math.min(_currentGeometry.size.width, _currentGeometry.size.height) / 2 : null,
          handles: handles,
          sideHandles: sideHandles,
          rotationHandle: rotationHandle,
          rotation: _currentGeometry.rotation,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _SideHandle {
  final Offset position;
  final _SideHandleType type;
  
  _SideHandle(this.position, this.type);
}

enum _SideHandleType {
  top,
  right,
  bottom,
  left,
}

class _TransformPainter extends CustomPainter {
  final TransformableShape shape;
  final Rect rect;
  final Offset? center;
  final double? radius;
  final List<Offset> handles;
  final List<_SideHandle> sideHandles;
  final Offset? rotationHandle;
  final double rotation;

  _TransformPainter({
    required this.shape,
    required this.rect,
    this.center,
    this.radius,
    required this.handles,
    required this.sideHandles,
    this.rotationHandle,
    required this.rotation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    if (shape == TransformableShape.circle && center != null && radius != null) {
      // Dibujar círculo
      canvas.drawCircle(center!, radius!, paint);
      
      // Dibujar handle de resize en el borde (4 puntos cardinales)
      final handles = [
        Offset(center!.dx, center!.dy - radius!),
        Offset(center!.dx + radius!, center!.dy),
        Offset(center!.dx, center!.dy + radius!),
        Offset(center!.dx - radius!, center!.dy),
      ];
      for (final handle in handles) {
        canvas.drawCircle(handle, 6, paint);
        canvas.drawCircle(handle, 6, Paint()..color = AppColors.background..style = PaintingStyle.fill);
      }
    } else {
      // Dibujar bounding box
      canvas.drawRect(rect, paint);

      // Dibujar handles de esquina
      for (final handle in handles) {
        canvas.drawCircle(handle, 6, paint);
        canvas.drawCircle(handle, 6, Paint()..color = AppColors.background..style = PaintingStyle.fill);
      }

      // Dibujar handles de lado
      for (final sideHandle in sideHandles) {
        canvas.drawCircle(sideHandle.position, 6, paint);
        canvas.drawCircle(sideHandle.position, 6, Paint()..color = AppColors.background..style = PaintingStyle.fill);
      }

      // Dibujar línea y handle de rotación
      if (rotationHandle != null) {
        canvas.drawLine(rect.center, rotationHandle!, paint);
        canvas.drawCircle(rotationHandle!, 6, paint);
        canvas.drawCircle(rotationHandle!, 6, Paint()..color = AppColors.background..style = PaintingStyle.fill);
      }
    }
  }

  @override
  bool shouldRepaint(_TransformPainter oldDelegate) {
    return shape != oldDelegate.shape ||
        rect != oldDelegate.rect ||
        center != oldDelegate.center ||
        radius != oldDelegate.radius ||
        handles != oldDelegate.handles ||
        sideHandles != oldDelegate.sideHandles ||
        rotationHandle != oldDelegate.rotationHandle ||
        rotation != oldDelegate.rotation;
  }
}
