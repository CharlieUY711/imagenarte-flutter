import 'dart:io';
import 'dart:math' as math;
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
  Path? _currentFreeSelectionPath;
  Offset? _lastFreeSelectionPoint;

  @override
  Widget build(BuildContext context) {
    return Consumer<EditorUiState>(
      builder: (context, uiState, child) {
        debugPrint("canvas sees ctx=${uiState.activeContext} stateHash=${identityHashCode(uiState)}");
        // Barra negra eliminada - no mostrar hint
        final showHint = false;
        final isWatermark = uiState.activeTool == EditorTool.watermark;
        final isGeometricSelection = uiState.activeTool == EditorTool.geometricSelection;
        final isFreeSelection = uiState.activeTool == EditorTool.freeSelection;
        final showSelectionOverlay = (isGeometricSelection || isFreeSelection) &&
            (uiState.selectionGeometry != null || uiState.freeSelectionPath != null);

        return LayoutBuilder(
          key: _canvasKey,
          builder: (context, constraints) {
            // Obtener tamaño de imagen si está disponible
            Size? imageSize;
            if (widget.imagePath != null) {
              // Por ahora usamos el tamaño del canvas como aproximación
              // En producción deberíamos obtener el tamaño real de la imagen
              imageSize = constraints.biggest;
            }

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
              onTapDown: (details) {
                if (isWatermark) {
                  _handleWatermarkTap(details, uiState);
                } else if (isFreeSelection) {
                  _startFreeSelection(details.localPosition, uiState);
                }
              },
              onPanUpdate: isFreeSelection
                  ? (details) {
                      _updateFreeSelection(details.localPosition, uiState);
                    }
                  : null,
              onPanEnd: isFreeSelection
                  ? (details) {
                      _endFreeSelection(uiState);
                    }
                  : null,
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
              // Overlay de selección libre
              if (isFreeSelection && _currentFreeSelectionPath != null)
                _buildFreeSelectionOverlay(constraints.biggest),
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

  void _startFreeSelection(Offset position, EditorUiState uiState) {
    setState(() {
      _currentFreeSelectionPath = Path()..moveTo(position.dx, position.dy);
      _lastFreeSelectionPoint = position;
    });
  }

  void _updateFreeSelection(Offset position, EditorUiState uiState) {
    if (_currentFreeSelectionPath == null || _lastFreeSelectionPoint == null) return;
    
    setState(() {
      _currentFreeSelectionPath!.lineTo(position.dx, position.dy);
      _lastFreeSelectionPoint = position;
    });
  }

  void _endFreeSelection(EditorUiState uiState) {
    if (_currentFreeSelectionPath != null) {
      // Cerrar el path si es necesario
      if (_lastFreeSelectionPoint != null) {
        _currentFreeSelectionPath!.lineTo(_lastFreeSelectionPoint!.dx, _lastFreeSelectionPoint!.dy);
      }
      uiState.setFreeSelectionPath(_currentFreeSelectionPath);
    }
    setState(() {
      _currentFreeSelectionPath = null;
      _lastFreeSelectionPoint = null;
    });
  }

  Widget _buildFreeSelectionOverlay(Size canvasSize) {
    if (_currentFreeSelectionPath == null) return const SizedBox.shrink();
    
    return CustomPaint(
      painter: _FreeSelectionOverlayPainter(
        path: _currentFreeSelectionPath!,
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
    if (uiState.freeSelectionPath != null) {
      return CustomPaint(
        painter: _FreeSelectionOverlayPainter(
          path: uiState.freeSelectionPath!,
          canvasSize: canvasSize,
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

  _SelectionOverlayPainter({
    required this.geometry,
    required this.canvasSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Crear path para el overlay completo
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height));

    // Crear path para el "hole" (selección)
    Path holePath;
    if (geometry.shape == TransformableShape.circle) {
      final radius = math.min(geometry.size.width, geometry.size.height) / 2;
      holePath = Path()
        ..addOval(Rect.fromCircle(center: geometry.center, radius: radius));
    } else {
      // Rectángulo
      holePath = Path()
        ..addRect(geometry.boundingBox);
    }

    // Combinar: overlay - hole (difference)
    final combinedPath = Path.combine(
      PathOperation.difference,
      overlayPath,
      holePath,
    );

    // Dibujar overlay oscuro
    final paint = Paint()
      ..color = AppColors.background.withAlpha(200)
      ..style = PaintingStyle.fill;
    canvas.drawPath(combinedPath, paint);
  }

  @override
  bool shouldRepaint(_SelectionOverlayPainter oldDelegate) {
    return geometry != oldDelegate.geometry ||
        canvasSize != oldDelegate.canvasSize;
  }
}

class _FreeSelectionOverlayPainter extends CustomPainter {
  final Path path;
  final Size canvasSize;

  _FreeSelectionOverlayPainter({
    required this.path,
    required this.canvasSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Crear path para el overlay completo
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height));

    // Combinar: overlay - hole (difference)
    final combinedPath = Path.combine(
      PathOperation.difference,
      overlayPath,
      path,
    );

    // Dibujar overlay oscuro
    final paint = Paint()
      ..color = AppColors.background.withAlpha(200)
      ..style = PaintingStyle.fill;
    canvas.drawPath(combinedPath, paint);
    
    // Dibujar borde de la selección
    final borderPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(_FreeSelectionOverlayPainter oldDelegate) {
    return path != oldDelegate.path ||
        canvasSize != oldDelegate.canvasSize;
  }
}
