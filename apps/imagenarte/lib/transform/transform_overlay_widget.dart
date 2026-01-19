import 'package:flutter/material.dart';
import 'package:imagenarte/app/theme/app_colors.dart';
import 'package:imagenarte/transform/transform_model.dart';
import 'package:imagenarte/transform/transform_gesture_detector.dart';
import 'package:imagenarte/transform/transform_controller.dart';

/// Widget overlay para mostrar handles y bounding box de items transformables
/// 
/// Renderiza los handles de transformación y maneja los gestos de drag/scale/rotate.
class TransformOverlayWidget extends StatefulWidget {
  final TransformController controller;
  final String itemId;

  const TransformOverlayWidget({
    super.key,
    required this.controller,
    required this.itemId,
  });

  @override
  State<TransformOverlayWidget> createState() => _TransformOverlayWidgetState();
}

class _TransformOverlayWidgetState extends State<TransformOverlayWidget> {
  HandleInfo? _activeHandle;
  Offset? _dragStartPoint;
  Transform2D? _dragStartTransform;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    setState(() {});
  }

  TransformableItem? get _item {
    try {
      return widget.controller.items.firstWhere(
        (item) => item.id == widget.itemId,
      );
    } catch (e) {
      return null;
    }
  }

  void _handlePointerDown(Offset localPosition, Transform2D transform, TransformHandlesConfig config) {
    final handleInfo = TransformGestureDetector.detectHandle(
      point: localPosition,
      transform: transform,
      config: config,
    );

    if (handleInfo.type != HandleType.none) {
      setState(() {
        _activeHandle = handleInfo;
        _dragStartPoint = localPosition;
        _dragStartTransform = transform;
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_activeHandle == null || _dragStartPoint == null || _dragStartTransform == null) {
      return;
    }

    final item = _item;
    if (item == null) return;

    final newTransform = TransformGestureDetector.applyDrag(
      currentTransform: item.transform,
      startPoint: _dragStartPoint!,
      currentPoint: details.localPosition,
      handleInfo: _activeHandle!,
      config: widget.controller.handlesConfig,
    );

    widget.controller.updateTransform(widget.itemId, newTransform);
  }

  void _onPanEnd(DragEndDetails details) {
    if (_activeHandle != null) {
      widget.controller.commitTransform(widget.itemId);
    }

    setState(() {
      _activeHandle = null;
      _dragStartPoint = null;
      _dragStartTransform = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = _item;
    if (item == null || !item.isSelected) {
      return const SizedBox.shrink();
    }

    final transform = item.transform;
    final config = widget.controller.handlesConfig;
    final rect = transform.boundingBox;

    // Usar Listener para no bloquear gestos del canvas cuando no hay hit en handles
    return Listener(
      onPointerDown: (event) {
        _handlePointerDown(event.localPosition, transform, config);
      },
      onPointerMove: (event) {
        if (_activeHandle != null && _dragStartPoint != null) {
          _onPanUpdate(DragUpdateDetails(
            globalPosition: event.position,
            localPosition: event.localPosition,
            delta: event.localPosition - _dragStartPoint!,
          ));
        }
      },
      onPointerUp: (event) {
        if (_activeHandle != null) {
          _onPanEnd(DragEndDetails(
            velocity: Velocity.zero,
          ));
        }
      },
      behavior: HitTestBehavior.translucent, // Permite que gestos pasen cuando no hay hit
      child: CustomPaint(
        painter: _TransformOverlayPainter(
          transform: transform,
          config: config,
          rect: rect,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

/// Painter para renderizar el overlay de transformación
class _TransformOverlayPainter extends CustomPainter {
  final Transform2D transform;
  final TransformHandlesConfig config;
  final Rect rect;

  _TransformOverlayPainter({
    required this.transform,
    required this.config,
    required this.rect,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final center = transform.position;

    // Dibujar bounding box
    canvas.drawRect(rect, paint);

    // Dibujar handles de esquina
    if (config.showCornerHandles) {
      final corners = _getCornerHandles(rect);
      for (final corner in corners) {
        canvas.drawCircle(corner, 6, paint);
        canvas.drawCircle(
          corner,
          6,
          Paint()..color = AppColors.background..style = PaintingStyle.fill,
        );
      }
    }

    // Dibujar handles de borde
    if (config.showEdgeHandles && !config.maintainAspectRatio) {
      final edges = _getEdgeHandles(rect);
      for (final edge in edges) {
        canvas.drawCircle(edge, 6, paint);
        canvas.drawCircle(
          edge,
          6,
          Paint()..color = AppColors.background..style = PaintingStyle.fill,
        );
      }
    }

    // Dibujar handle de rotación
    if (config.showRotateHandle) {
      final rotateHandle = Offset(center.dx, rect.top - 30);
      canvas.drawLine(center, rotateHandle, paint);
      canvas.drawCircle(rotateHandle, 6, paint);
      canvas.drawCircle(
        rotateHandle,
        6,
        Paint()..color = AppColors.background..style = PaintingStyle.fill,
      );
    }
  }

  List<Offset> _getCornerHandles(Rect rect) {
    return [
      Offset(rect.left, rect.top),
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.bottom),
      Offset(rect.left, rect.bottom),
    ];
  }

  List<Offset> _getEdgeHandles(Rect rect) {
    return [
      Offset(rect.center.dx, rect.top),
      Offset(rect.right, rect.center.dy),
      Offset(rect.center.dx, rect.bottom),
      Offset(rect.left, rect.center.dy),
    ];
  }

  @override
  bool shouldRepaint(_TransformOverlayPainter oldDelegate) {
    return transform != oldDelegate.transform ||
        config != oldDelegate.config ||
        rect != oldDelegate.rect;
  }
}
