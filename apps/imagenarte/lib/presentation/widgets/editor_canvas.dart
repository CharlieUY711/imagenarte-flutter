import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:imagenarte/app/theme/app_colors.dart';
import 'package:imagenarte/app/theme/app_spacing.dart';
import 'package:imagenarte/app/theme/app_radius.dart';
import 'package:imagenarte/application/editor_ui_state.dart';
import 'package:imagenarte/domain/transformable_geometry.dart';
import 'package:imagenarte/domain/collage_config.dart';
import 'package:imagenarte/domain/watermark_config.dart';
import 'package:imagenarte/presentation/widgets/transform_tool.dart';
import 'package:imagenarte/presentation/widgets/watermark_transform_overlay.dart';
import 'package:imagenarte/presentation/widgets/editor_overlay_router.dart';
import 'package:imagenarte/presentation/widgets/filtered_image_widget.dart';
import 'package:imagenarte/presentation/widgets/blur_effect_overlay.dart';
import 'package:imagenarte/presentation/widgets/scissors_overlay.dart';
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
  Offset? _geometricSelectionStart; // Estado para creación de selección geométrica

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
        final isCollage = uiState.activeTool == EditorTool.collage;
        // Nota: showSelectionOverlay removido - las selecciones geométricas ya no se usan

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
              // Inicializar selección si es necesario para blur/pixelate
              if (uiState.activeTool == EditorTool.blur ||
                  uiState.activeTool == EditorTool.pixelate) {
                uiState.initializeSelectionIfNeeded(constraints.biggest);
              }
            });

            final isFreeSelection = uiState.activeTool == EditorTool.freeSelection;
            final isGeometricSelection = uiState.activeTool == EditorTool.geometricSelection;
            
            return GestureDetector(
              behavior: HitTestBehavior.translucent, // Permitir que otros widgets capturen eventos
              onTapDown: (details) {
                uiState.resetToolAutoCloseTimer(); // Reiniciar timer al interactuar
                if (isWatermark) {
                  _handleWatermarkTap(details, uiState);
                } else if (isGeometricSelection && uiState.selectionGeometry == null) {
                  // Solo iniciar creación si no hay selección existente
                  _geometricSelectionStart = details.localPosition;
                  uiState.startGeometricSelection(details.localPosition);
                } else if (isGeometricSelection && uiState.selectionGeometry != null) {
                  // Si hay selección y se toca fuera, resetear (comportamiento opcional)
                  // Por ahora, dejamos que TransformTool maneje todo cuando hay selección
                }
              },
              onPanStart: isFreeSelection
                  ? (details) => _handleFreehandPanStart(details.localPosition, uiState)
                  : isGeometricSelection
                      ? (details) {
                          uiState.resetToolAutoCloseTimer(); // Reiniciar timer al interactuar
                          // Solo capturar si no hay selección o el pan está fuera
                          // Si hay selección y el pan está dentro, dejar que TransformTool maneje
                          if (uiState.selectionGeometry == null || 
                              !uiState.selectionGeometry!.containsPoint(details.localPosition)) {
                            _geometricSelectionStart = details.localPosition;
                            uiState.startGeometricSelection(details.localPosition);
                          }
                        }
                      : null,
              onPanUpdate: isFreeSelection
                  ? (details) => _handleFreehandPanUpdate(details.localPosition, uiState)
                  : isGeometricSelection && _geometricSelectionStart != null
                      ? (details) {
                          uiState.updateGeometricSelectionDrag(
                            details.localPosition,
                            _geometricSelectionStart!,
                          );
                        }
                      : null,
              onPanEnd: isFreeSelection
                  ? (details) => _handleFreehandPanEnd(uiState, constraints.biggest, imageSize)
                  : isGeometricSelection && _geometricSelectionStart != null
                      ? (details) {
                          uiState.endGeometricSelectionDrag();
                          _geometricSelectionStart = null;
                        }
                      : null,
              child: Stack(
            children: [
              // Fondo negro (debajo de la imagen para espacios vacíos)
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                ),
              ),
              // Contenido visual zoomable (imagen + overlays)
              // El zoom y pan se aplican solo al contenido visual, limitado al área visible
              ClipRect(
                child: GestureDetector(
                  // Permitir pan solo cuando hay zoom activo y el scale > 1.0
                  onPanStart: (uiState.zoomUiVisible && uiState.zoomScale > 1.0) && 
                              !isFreeSelection && !isGeometricSelection
                      ? (details) {
                          uiState.resetToolAutoCloseTimer(); // Reiniciar timer al interactuar
                        }
                      : null,
                  onPanUpdate: (uiState.zoomUiVisible && uiState.zoomScale > 1.0) && 
                               !isFreeSelection && !isGeometricSelection
                      ? (details) {
                          // Actualizar offset cuando se hace pan (solo en modo zoom)
                          uiState.resetToolAutoCloseTimer(); // Reiniciar timer al interactuar
                          uiState.updateZoomOffset(
                            details.delta,
                            constraints.biggest,
                            imageSize,
                          );
                        }
                      : null,
                  child: Transform.scale(
                    scale: uiState.zoomScale,
                    alignment: Alignment.center,
                    child: Transform.translate(
                      offset: uiState.zoomOffset,
                      child: Stack(
                        children: [
                          // Imagen central (con filtros de color y ajustes clásicos aplicados)
                          // Se ajusta a la mayor medida (ancho o alto) sin deformar
                          Center(
                            child: widget.imagePath != null
                                ? FilteredImageWidget(
                                    imagePath: widget.imagePath!,
                                    colorMode: uiState.colorMode,
                                    colorIntensity: uiState.colorIntensity,
                                    brightness: uiState.activeContext == EditorContext.classicAdjustments 
                                        ? uiState.brightness 
                                        : null,
                                    contrast: uiState.activeContext == EditorContext.classicAdjustments 
                                        ? uiState.contrast 
                                        : null,
                                    saturation: uiState.activeContext == EditorContext.classicAdjustments 
                                        ? uiState.saturation 
                                        : null,
                                    sharpness: uiState.activeContext == EditorContext.classicAdjustments 
                                        ? uiState.sharpness 
                                        : null,
                                    fit: BoxFit.contain, // Ajusta sin deformar, mantiene proporción original
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
                          // Overlay de blur (aplicado solo dentro del ROI)
                          BlurEffectOverlay(
                            uiState: uiState,
                            canvasSize: constraints.biggest,
                          ),
                          // Overlay de selección libre (dibujo en tiempo real)
                          if (isFreeSelection)
                            _buildFreehandDrawingOverlay(uiState, constraints.biggest),
                          // Overlay de selección (path final o geometría)
                          _buildSelectionOverlay(uiState, constraints.biggest),
                          // Renderizar watermark
                          if (isWatermark && uiState.watermarkConfig != null && uiState.watermarkConfig!.enabled)
                            _buildWatermarkOverlay(uiState),
                          // Overlay de collage (guía visual tipo marca de agua)
                          if (isCollage)
                            _buildCollageOverlay(uiState, constraints.biggest),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Botón de lupa en esquina superior izquierda
              Positioned(
                left: 16,
                top: 16,
                child: Consumer<EditorUiState>(
                  builder: (context, uiState, child) {
                    return GestureDetector(
                      onTap: () {
                        uiState.onMagnifierTap();
                      },
                      child: Icon(
                        Icons.zoom_in,
                        color: Colors.white.withOpacity(0.9),
                        size: 32,
                      ),
                    );
                  },
                ),
              ),
              // Botón de tijera en esquina superior derecha (visible cuando hay selección válida)
              Positioned(
                right: 16,
                top: 16,
                child: Consumer<EditorUiState>(
                  builder: (context, uiState, child) {
                    final hasValidSelection = uiState.hasValidSelection;
                    // Mostrar tijera cuando hay selección válida (blur, pixelate, o scissors)
                    final canUseScissors = hasValidSelection && 
                        (uiState.activeTool == EditorTool.blur ||
                         uiState.activeTool == EditorTool.pixelate ||
                         uiState.activeTool == EditorTool.scissors);
                    
                    if (!canUseScissors || widget.imagePath == null) {
                      return const SizedBox.shrink();
                    }
                    
                    return GestureDetector(
                      onTap: () async {
                        // Activar herramienta scissors para mostrar overlay de opciones
                        uiState.setActiveTool(EditorTool.scissors);
                      },
                      child: Icon(
                        Icons.content_cut,
                        color: Colors.white.withOpacity(0.9),
                        size: 32,
                      ),
                    );
                  },
                ),
              ),
              // Botón de invertir selección en esquina inferior izquierda (visible cuando hay selección válida)
              Positioned(
                left: 16,
                bottom: 16,
                child: Consumer<EditorUiState>(
                  builder: (context, uiState, child) {
                    final hasValidSelection = uiState.hasValidSelection;
                    // Mostrar botón de invertir cuando hay selección válida (blur, pixelate, o scissors)
                    final canInvertSelection = hasValidSelection && 
                        (uiState.activeTool == EditorTool.blur ||
                         uiState.activeTool == EditorTool.pixelate ||
                         uiState.activeTool == EditorTool.scissors);
                    
                    if (!canInvertSelection) {
                      return const SizedBox.shrink();
                    }
                    
                    return GestureDetector(
                      onTap: () {
                        uiState.toggleSelectionInverted();
                      },
                      child: Icon(
                        Icons.swap_horiz,
                        color: Colors.white.withOpacity(0.9),
                        size: 32,
                      ),
                    );
                  },
                ),
              ),
              // Botón de undo en esquina inferior derecha
              Positioned(
                right: 16,
                bottom: 16,
                child: Consumer<EditorUiState>(
                  builder: (context, uiState, child) {
                    return GestureDetector(
                      onTap: uiState.canUndo
                          ? () {
                              uiState.setActiveTool(EditorTool.undo);
                            }
                          : null,
                      child: Icon(
                        Icons.undo,
                        color: uiState.canUndo
                            ? Colors.white.withOpacity(0.9)
                            : Colors.white.withOpacity(0.4),
                        size: 32,
                      ),
                    );
                  },
                ),
              ),
              // Transform tool (handles/bounding box) - fuera del zoom
              // Nota: TransformTool legacy mantenido para ROI (blur/pixelate)
              // El nuevo motor se usa para watermark
              const TransformTool(),
              // Nuevo motor de transformaciones para watermark
              const WatermarkTransformOverlay(),
              // Overlay router (panel inferior con controles)
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
    uiState.resetToolAutoCloseTimer(); // Reiniciar timer al interactuar
    uiState.startFreehand();
    uiState.addFreehandPoint(position, _imageDestRect);
  }

  void _handleFreehandPanUpdate(Offset position, EditorUiState uiState) {
    uiState.resetToolAutoCloseTimer(); // Reiniciar timer al interactuar
    uiState.addFreehandPoint(position, _imageDestRect);
  }

  void _handleFreehandPanEnd(EditorUiState uiState, Size canvasSize, Size? imageSize) {
    uiState.resetToolAutoCloseTimer(); // Reiniciar timer al interactuar
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

  Widget _buildWatermarkOverlay(EditorUiState uiState) {
    final config = uiState.watermarkConfig;
    if (config == null || !config.enabled) return const SizedBox.shrink();

    final geometry = config.transform;
    final isLocked = config.locked;

    // Usar Transform con Matrix4 para aplicar todas las transformaciones
    // (posición, rotación, escala si aplica)
    final matrix = Matrix4.identity()
      ..translate(geometry.center.dx, geometry.center.dy)
      ..rotateZ(geometry.rotation)
      ..translate(-geometry.size.width / 2, -geometry.size.height / 2);

    return Positioned(
      left: 0,
      top: 0,
      child: IgnorePointer(
        ignoring: isLocked, // Si está bloqueado, no interceptar gestos
        child: Transform(
          transform: matrix,
          child: config.type == WatermarkType.text
              ? CustomPaint(
                  size: geometry.size,
                  painter: _WatermarkTextPainter(config: config),
                )
              : _WatermarkImageWidget(
                  config: config,
                  size: geometry.size,
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

  Widget _buildCollageOverlay(EditorUiState uiState, Size canvasSize) {
    return IgnorePointer(
      ignoring: true, // No bloquear interacción
      child: CustomPaint(
        painter: _CollageOverlayPainter(
          config: uiState.collageConfig,
          canvasSize: canvasSize,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _CollageOverlayPainter extends CustomPainter {
  final CollageConfig config;
  final Size canvasSize;

  _CollageOverlayPainter({
    required this.config,
    required this.canvasSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Dibujar título "Collage" en la esquina superior izquierda
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Collage',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.foreground.withAlpha(180),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(16, 16));

    // Dibujar layout info
    final layoutPainter = TextPainter(
      text: TextSpan(
        text: '${config.rows}×${config.cols}',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.foreground.withAlpha(150),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    layoutPainter.layout();
    layoutPainter.paint(canvas, const Offset(16, 36));

    // Dibujar grid de guías
    if (config.layoutType == CollageLayoutType.grid) {
      _drawGrid(canvas, size);
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent.withAlpha(100)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final rows = config.rows;
    final cols = config.cols;
    final spacing = config.spacing;
    final padding = config.padding;

    // Calcular tamaño de cada celda
    final availableWidth = size.width - (padding * 2);
    final availableHeight = size.height - (padding * 2);
    
    final cellWidth = (availableWidth - (spacing * (cols - 1))) / cols;
    final cellHeight = (availableHeight - (spacing * (rows - 1))) / rows;

    // Dibujar líneas verticales
    for (int i = 0; i <= cols; i++) {
      final x = padding + (i * (cellWidth + spacing));
      canvas.drawLine(
        Offset(x, padding),
        Offset(x, size.height - padding),
        paint,
      );
    }

    // Dibujar líneas horizontales
    for (int i = 0; i <= rows; i++) {
      final y = padding + (i * (cellHeight + spacing));
      canvas.drawLine(
        Offset(padding, y),
        Offset(size.width - padding, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_CollageOverlayPainter oldDelegate) {
    return config != oldDelegate.config ||
        canvasSize != oldDelegate.canvasSize;
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

class _WatermarkTextPainter extends CustomPainter {
  final WatermarkConfig config;

  _WatermarkTextPainter({
    required this.config,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final text = config.text;
    if (text.isEmpty) return;

    // Calcular tamaño de fuente proporcional al tamaño del watermark
    final fontSize = math.min(size.width / text.length * 1.2, size.height * 0.8);
    
    final textStyle = TextStyle(
      fontSize: fontSize,
      color: config.color.withOpacity(config.opacity),
      fontWeight: FontWeight.w600,
    );

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout(maxWidth: size.width);

    // Aplicar outline si está habilitado
    if (config.outline != null && config.outline!.enabled) {
      final outlineStyle = TextStyle(
        fontSize: fontSize,
        color: config.outline!.color.withOpacity(config.opacity),
        fontWeight: FontWeight.w600,
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = config.outline!.width
          ..color = config.outline!.color.withOpacity(config.opacity),
      );
      final outlinePainter = TextPainter(
        text: TextSpan(text: text, style: outlineStyle),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      outlinePainter.layout(maxWidth: size.width);
      
      // Dibujar outline primero (debajo)
      outlinePainter.paint(
        canvas,
        Offset((size.width - outlinePainter.width) / 2, (size.height - outlinePainter.height) / 2),
      );
    }

    // Aplicar sombra si está habilitada
    if (config.shadow != null && config.shadow!.enabled) {
      canvas.save();
      canvas.translate(config.shadow!.offset.dx, config.shadow!.offset.dy);
      
      final shadowStyle = TextStyle(
        fontSize: fontSize,
        color: config.shadow!.color.withOpacity(config.opacity),
        fontWeight: FontWeight.w600,
      );
      final shadowPainter = TextPainter(
        text: TextSpan(text: text, style: shadowStyle),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      shadowPainter.layout(maxWidth: size.width);
      
      // Aplicar blur a la sombra (simulado con múltiples capas)
      final blurLayers = (config.shadow!.blur / 2).round().clamp(1, 5);
      for (int i = 0; i < blurLayers; i++) {
        shadowPainter.paint(
          canvas,
          Offset((size.width - shadowPainter.width) / 2, (size.height - shadowPainter.height) / 2),
        );
      }
      
      canvas.restore();
    }

    // Dibujar texto principal
    textPainter.paint(
      canvas,
      Offset((size.width - textPainter.width) / 2, (size.height - textPainter.height) / 2),
    );
  }

  @override
  bool shouldRepaint(_WatermarkTextPainter oldDelegate) {
    return config != oldDelegate.config;
  }
}

/// Widget para renderizar watermark de imagen (carga asíncrona)
class _WatermarkImageWidget extends StatefulWidget {
  final WatermarkConfig config;
  final Size size;

  const _WatermarkImageWidget({
    required this.config,
    required this.size,
  });

  @override
  State<_WatermarkImageWidget> createState() => _WatermarkImageWidgetState();
}

class _WatermarkImageWidgetState extends State<_WatermarkImageWidget> {
  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(_WatermarkImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config.imagePath != widget.config.imagePath) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    final imagePath = widget.config.imagePath;
    if (imagePath == null || !File(imagePath).existsSync()) {
      setState(() => _image = null);
      return;
    }

    try {
      final file = File(imagePath);
      final imageBytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(imageBytes);
      final frame = await codec.getNextFrame();
      if (mounted) {
        setState(() => _image = frame.image);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _image = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_image == null) {
      // Placeholder
      return Container(
        width: widget.size.width,
        height: widget.size.height,
        decoration: BoxDecoration(
          color: AppColors.accent.withOpacity(widget.config.opacity * 0.3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            'LOGO',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.accent,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    // Calcular rectángulo de destino manteniendo aspect ratio
    final imageAspect = _image!.width / _image!.height;
    final sizeAspect = widget.size.width / widget.size.height;

    Rect destRect;
    if (imageAspect > sizeAspect) {
      // Imagen más ancha: ajustar al ancho
      final height = widget.size.width / imageAspect;
      destRect = Rect.fromLTWH(0, (widget.size.height - height) / 2, widget.size.width, height);
    } else {
      // Imagen más alta: ajustar al alto
      final width = widget.size.height * imageAspect;
      destRect = Rect.fromLTWH((widget.size.width - width) / 2, 0, width, widget.size.height);
    }

    return CustomPaint(
      size: widget.size,
      painter: _WatermarkImagePainter(
        image: _image!,
        destRect: destRect,
        opacity: widget.config.opacity,
      ),
    );
  }
}

class _WatermarkImagePainter extends CustomPainter {
  final ui.Image image;
  final Rect destRect;
  final double opacity;

  _WatermarkImagePainter({
    required this.image,
    required this.destRect,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..filterQuality = FilterQuality.high
      ..colorFilter = ColorFilter.mode(
        Colors.white.withOpacity(opacity),
        BlendMode.modulate,
      );

    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      destRect,
      paint,
    );
  }

  @override
  bool shouldRepaint(_WatermarkImagePainter oldDelegate) {
    return image != oldDelegate.image ||
        destRect != oldDelegate.destRect ||
        opacity != oldDelegate.opacity;
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