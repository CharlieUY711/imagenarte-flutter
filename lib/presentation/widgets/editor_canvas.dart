import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:imagenarte/app/theme/app_colors.dart';
import 'package:imagenarte/app/theme/app_spacing.dart';
import 'package:imagenarte/app/theme/app_radius.dart';
import 'package:imagenarte/application/editor_ui_state.dart';
import 'package:imagenarte/domain/transformable_geometry.dart';
import 'package:imagenarte/presentation/widgets/transform_tool.dart';
import 'package:imagenarte/presentation/widgets/editor_overlay_router.dart';
import 'package:provider/provider.dart';

class EditorCanvas extends StatefulWidget {
  final String? imagePath;

  const EditorCanvas({
    super.key,
    this.imagePath,
  });

  @override
  State<EditorCanvas> createState() => _EditorCanvasState();
}

class _EditorCanvasState extends State<EditorCanvas> {
  final GlobalKey _canvasKey = GlobalKey();
  Size? _actualImageSize;
  Rect? _imageDestRect;

  @override
  void initState() {
    super.initState();
    _loadImageSize();
  }

  @override
  void didUpdateWidget(EditorCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagePath != widget.imagePath) {
      _loadImageSize();
    }
  }

  Future<void> _loadImageSize() async {
    if (widget.imagePath == null) {
      setState(() {
        _actualImageSize = null;
        _imageDestRect = null;
      });
      return;
    }

    try {
      final file = File(widget.imagePath!);
      final imageBytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(imageBytes);
      final frame = await codec.getNextFrame();
      if (mounted) {
        setState(() {
          _actualImageSize = Size(frame.image.width.toDouble(), frame.image.height.toDouble());
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _actualImageSize = null;
          _imageDestRect = null;
        });
      }
    }
  }

  Rect? _calculateImageDestRect(Size canvasSize, Size? imageSize) {
    if (imageSize == null || imageSize.width <= 0 || imageSize.height <= 0) {
      return null;
    }

    final imageAspect = imageSize.width / imageSize.height;
    final canvasAspect = canvasSize.width / canvasSize.height;

    double width, height;
    if (imageAspect > canvasAspect) {
      width = canvasSize.width;
      height = width / imageAspect;
    } else {
      height = canvasSize.height;
      width = height * imageAspect;
    }

    final left = (canvasSize.width - width) / 2;
    final top = (canvasSize.height - height) / 2;

    return Rect.fromLTWH(left, top, width, height);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EditorUiState>(
      builder: (context, uiState, child) {
        debugPrint("canvas sees ctx=${uiState.activeContext} stateHash=${identityHashCode(uiState)}");
        final isWatermark = uiState.activeTool == EditorTool.watermark;
        final isGeometricSelection = uiState.activeTool == EditorTool.geometricSelection;
        final isFreeSelection = uiState.activeTool == EditorTool.freeSelection;
        final showSelectionOverlay = (isGeometricSelection || isFreeSelection) &&
            (uiState.selectionGeometry != null || uiState.freehandPathCanvas != null);

        return LayoutBuilder(
          key: _canvasKey,
          builder: (context, constraints) {
            // Actualizar tamaño del canvas en el estado para mapeo
            uiState.setCanvasSize(constraints.biggest);
            
            // Calcular destRect de la imagen
            final canvasSize = constraints.biggest;
            _imageDestRect = _calculateImageDestRect(canvasSize, _actualImageSize);
            
            // Obtener tamaño de imagen
            final imageSize = _actualImageSize;

            // Inicializar watermark si es necesario
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (isWatermark) {
                uiState.initializeWatermarkIfNeeded(constraints.biggest);
              }
              // Inicializar selección geométrica si es necesario
              if (isGeometricSelection && uiState.selectionGeometry == null) {
                uiState.initializeGeometricSelection(constraints.biggest, imageSize);
              }
              // Inicializar selección si es necesario para blur/pixelate
              if (uiState.activeTool == EditorTool.blur ||
                  uiState.activeTool == EditorTool.pixelate) {
                uiState.initializeSelectionIfNeeded(constraints.biggest);
              }
            });

            return GestureDetector(
              onPanStart: isFreeSelection
                  ? (details) {
                      _handleFreehandPanStart(details.localPosition, uiState);
                    }
                  : null,
              onPanUpdate: isFreeSelection
                  ? (details) {
                      _handleFreehandPanUpdate(details.localPosition, uiState);
                    }
                  : null,
              onPanEnd: isFreeSelection
                  ? (details) {
                      _handleFreehandPanEnd(uiState, canvasSize, imageSize);
                    }
                  : null,
              onTapDown: (details) {
                if (isWatermark) {
                  _handleWatermarkTap(details, uiState);
                }
              },
              child: Stack(
            children: [
              // Imagen central
              Center(
                child: widget.imagePath != null
                    ? Image.file(
                        File(widget.imagePath!),
                        fit: BoxFit.contain,
                      )
                    : const Center(
                        child: Text(
                          'Preview',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.foreground,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
              ),
              // Overlay de selección (dim fuera, normal dentro)
              if (showSelectionOverlay)
                _buildSelectionOverlay(uiState, constraints.biggest),
              // Overlay de selección libre en tiempo real (durante dibujo)
              if (isFreeSelection && uiState.isDrawingFreehand && uiState.freehandPointsCanvas.isNotEmpty)
                _buildFreehandDrawingOverlay(uiState, constraints.biggest),
              // Renderizar watermark (stub visual)
              if (isWatermark && uiState.watermarkVisible && uiState.watermarkGeometry != null)
                _buildWatermarkPlaceholder(uiState),
              // Transform tool (handles/bounding box)
              const TransformTool(),
              // Router único de overlays (SINGLE SOURCE OF TRUTH)
              EditorOverlayRouter(imagePath: widget.imagePath),
            ],
          ),
        );
          },
        );
      },
    );
  }

  void _handleFreehandPanStart(Offset position, EditorUiState uiState) {
    uiState.startFreehand();
    uiState.addFreehandPoint(position, _imageDestRect);
  }

  void _handleFreehandPanUpdate(Offset position, EditorUiState uiState) {
    uiState.addFreehandPoint(position, _imageDestRect);
  }

  void _handleFreehandPanEnd(EditorUiState uiState, Size canvasSize, Size? imageSize) {
    uiState.endFreehand(
      canvasSize: canvasSize,
      imageSize: imageSize,
    );
  }

  Widget _buildFreehandDrawingOverlay(EditorUiState uiState, Size canvasSize) {
    final points = uiState.freehandPointsCanvas;
    if (points.isEmpty) return const SizedBox.shrink();
    
    return CustomPaint(
      painter: _FreehandDrawingPainter(
        points: points,
        canvasSize: canvasSize,
      ),
      child: const SizedBox.expand(),
    );
  }

  void _handleWatermarkTap(TapDownDetails details, EditorUiState uiState) {
    if (uiState.watermarkGeometry == null) return;

    final localPosition = details.localPosition;
    final geometry = uiState.watermarkGeometry!;

    // Hit testing: verificar si el tap está sobre el watermark
    if (geometry.containsPoint(localPosition)) {
      // Seleccionar watermark como target de transformación
      uiState.setActiveTransformTarget(
        uiState.watermarkIsText 
            ? TransformTarget.watermarkText 
            : TransformTarget.watermarkLogo,
      );
    } else {
      // Tap fuera: deseleccionar (comportamiento simple y consistente)
      uiState.setActiveTransformTarget(TransformTarget.none);
    }
  }

  Widget _buildWatermarkPlaceholder(EditorUiState uiState) {
    final geometry = uiState.watermarkGeometry;
    if (geometry == null) return const SizedBox.shrink();

    return Positioned(
      left: geometry.boundingBox.left,
      top: geometry.boundingBox.top,
      child: IgnorePointer(
        ignoring: false,
        child: Container(
          width: geometry.size.width,
          height: geometry.size.height,
          decoration: BoxDecoration(
            color: AppColors.accent.withAlpha(51),
            border: Border.all(
              color: AppColors.accent.withAlpha(102),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              uiState.watermarkIsText ? 'TEXTO' : 'LOGO',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.accent,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionOverlay(EditorUiState uiState, Size canvasSize) {
    // Si hay path de selección libre, usar ese
    if (uiState.freehandPathCanvas != null) {
      return CustomPaint(
        painter: _FreeSelectionOverlayPainter(
          path: uiState.freehandPathCanvas!,
          canvasSize: canvasSize,
          inverted: uiState.selectionInverted,
        ),
        child: const SizedBox.expand(),
      );
    }
    
    // Si hay geometría de selección, usar esa
    if (uiState.selectionGeometry != null) {
      return CustomPaint(
        painter: _SelectionOverlayPainter(
          geometry: uiState.selectionGeometry!,
          canvasSize: canvasSize,
          inverted: uiState.selectionInverted,
        ),
        child: const SizedBox.expand(),
      );
    }
    
    return const SizedBox.shrink();
  }
}

class _SelectionOverlayPainter extends CustomPainter {
  final TransformableGeometry geometry;
  final Size canvasSize;
  final bool inverted;

  _SelectionOverlayPainter({
    required this.geometry,
    required this.canvasSize,
    required this.inverted,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Crear path para el overlay completo
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height));

    // Crear path para la selección
    Path selectionPath;
    if (geometry.shape == TransformableShape.circle) {
      final radius = math.min(geometry.size.width, geometry.size.height) / 2;
      selectionPath = Path()
        ..addOval(Rect.fromCircle(center: geometry.center, radius: radius));
    } else {
      // Rectángulo
      selectionPath = Path()
        ..addRect(geometry.boundingBox);
    }

    // Dibujar overlay oscuro
    final paint = Paint()
      ..color = AppColors.background.withAlpha(200)
      ..style = PaintingStyle.fill;

    if (inverted) {
      // Invertido: sombrear solo el área de selección
      canvas.drawPath(selectionPath, paint);
    } else {
      // Normal: sombrear todo excepto el área de selección
      final combinedPath = Path.combine(
        PathOperation.difference,
        overlayPath,
        selectionPath,
      );
      canvas.drawPath(combinedPath, paint);
    }
  }

  @override
  bool shouldRepaint(_SelectionOverlayPainter oldDelegate) {
    return geometry != oldDelegate.geometry ||
        canvasSize != oldDelegate.canvasSize ||
        inverted != oldDelegate.inverted;
  }
}

class _FreehandDrawingPainter extends CustomPainter {
  final List<Offset> points;
  final Size canvasSize;

  _FreehandDrawingPainter({
    required this.points,
    required this.canvasSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    
    // Crear path desde los puntos
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    
    // Dibujar trazo naranja semi-transparente
    final strokePaint = Paint()
      ..color = AppColors.accent.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;
    
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(_FreehandDrawingPainter oldDelegate) {
    return points.length != oldDelegate.points.length ||
        (points.isNotEmpty && oldDelegate.points.isNotEmpty && 
         points.last != oldDelegate.points.last);
  }
}

class _FreeSelectionOverlayPainter extends CustomPainter {
  final Path path;
  final Size canvasSize;
  final bool inverted;

  _FreeSelectionOverlayPainter({
    required this.path,
    required this.canvasSize,
    required this.inverted,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Crear path para el overlay completo
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height));

    // Dibujar overlay oscuro
    final paint = Paint()
      ..color = AppColors.background.withAlpha(200)
      ..style = PaintingStyle.fill;

    if (inverted) {
      // Invertido: sombrear solo el área de selección
      canvas.drawPath(path, paint);
    } else {
      // Normal: sombrear todo excepto el área de selección
      final combinedPath = Path.combine(
        PathOperation.difference,
        overlayPath,
        path,
      );
      canvas.drawPath(combinedPath, paint);
    }
  }

  @override
  bool shouldRepaint(_FreeSelectionOverlayPainter oldDelegate) {
    return path != oldDelegate.path ||
        canvasSize != oldDelegate.canvasSize ||
        inverted != oldDelegate.inverted;
  }
}