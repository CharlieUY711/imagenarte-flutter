import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import 'package:imagenarte/app/theme/app_colors.dart';
import 'package:imagenarte/presentation/theme/editor_tokens.dart';
import 'package:imagenarte/application/editor_ui_state.dart';
import 'package:imagenarte/application/editor_state.dart';
import 'package:imagenarte/domain/transformable_geometry.dart';
import 'package:imagenarte/infrastructure/file_versioning.dart';
import 'package:imagenarte/presentation/screens/editor_screen.dart';
import 'package:imagenarte/presentation/screens/home_screen.dart';

class InfoBar extends StatefulWidget {
  final String? imagePath;
  final EditorState? editorState;

  const InfoBar({
    super.key,
    this.imagePath,
    this.editorState,
  });

  @override
  State<InfoBar> createState() => _InfoBarState();
}

class _InfoBarState extends State<InfoBar> {
  // Variables solo para métricas de la barra blanca (no para la barra naranja)
  int? _imageWidth;
  int? _imageHeight;
  double? _originalFileSizeMB;
  Uint8List? _originalImageBytes;
  Size? _canvasSize;
  
  // Control de recálculo de métricas para evitar llamadas excesivas
  EditorTool? _lastActiveTool;
  bool _lastSelectionInverted = false;
  ColorMode? _lastColorMode;
  TransformableGeometry? _lastSelectionGeometry;
  Path? _lastFreehandPathImage;

  @override
  void initState() {
    super.initState();
    // Cargar info solo para la barra blanca (métricas)
    // La barra naranja ahora lee de EditorState.imageInfo
    _loadFileInfoForMetrics();
    // Inicializar valores de seguimiento
    _lastActiveTool = null;
    _lastSelectionInverted = false;
    _lastColorMode = null;
    _lastSelectionGeometry = null;
    _lastFreehandPathImage = null;
  }

  @override
  void didUpdateWidget(InfoBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Solo recargar métricas si el imagePath cambió realmente
    if (oldWidget.imagePath != widget.imagePath) {
      _loadFileInfoForMetrics();
    }
    // Si el imagePath es el mismo pero los valores se perdieron, recargar
    else if (widget.imagePath != null && _imageWidth == null && _imageHeight == null) {
      _loadFileInfoForMetrics();
    }
  }

  void _ensureSelectionNameInitialized(EditorUiState uiState) {
    if (widget.imagePath == null) return;
    
    final fileName = widget.imagePath!.split(Platform.pathSeparator).last;
    if (fileName.isEmpty) return;
    
    // Inicializar inmediatamente si no está inicializado
    if (uiState.originalFileExtension == null || uiState.selectionVersionBaseName == null) {
      uiState.setOriginalFileExtension(_getFileExtension(fileName));
      uiState.initializeSelectionVersionNameIfNeeded(fileName);
    }
  }

  /// Carga información solo para métricas de la barra blanca (no para la barra naranja)
  /// La barra naranja ahora lee de EditorState.imageInfo (snapshot fijo)
  Future<void> _loadFileInfoForMetrics() async {
    if (widget.imagePath == null) {
      setState(() {
        _imageWidth = null;
        _imageHeight = null;
        _originalFileSizeMB = null;
        _originalImageBytes = null;
      });
      return;
    }

    // Obtener uiState antes del async gap
    final uiState = mounted ? Provider.of<EditorUiState>(context, listen: false) : null;
    final fileNameFromPath = widget.imagePath!.split(Platform.pathSeparator).last;
    
    // Inicializar extensión y nombre base INMEDIATAMENTE (síncrono) antes de operaciones async
    if (mounted && uiState != null && fileNameFromPath.isNotEmpty) {
      uiState.setOriginalFileExtension(_getFileExtension(fileNameFromPath));
      uiState.initializeSelectionVersionNameIfNeeded(fileNameFromPath);
    }

    try {
      final file = File(widget.imagePath!);
      
      // Obtener tamaño del archivo
      final fileSizeBytes = await file.length();
      _originalFileSizeMB = fileSizeBytes / (1024 * 1024);

      // Obtener resolución de la imagen
      final imageBytes = await file.readAsBytes();
      _originalImageBytes = imageBytes;
      final codec = await ui.instantiateImageCodec(imageBytes);
      final frame = await codec.getNextFrame();
      _imageWidth = frame.image.width;
      _imageHeight = frame.image.height;

      // Verificar inicialización por si acaso
      if (mounted && uiState != null && fileNameFromPath.isNotEmpty) {
        if (uiState.originalFileExtension == null) {
          uiState.setOriginalFileExtension(_getFileExtension(fileNameFromPath));
        }
        if (uiState.selectionVersionBaseName == null) {
          uiState.initializeSelectionVersionNameIfNeeded(fileNameFromPath);
        }
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      // Si hay error, limpiar valores
      if (mounted) {
        setState(() {
          _imageWidth = null;
          _imageHeight = null;
          _originalFileSizeMB = null;
          _originalImageBytes = null;
        });
      }
    }
  }

  String _getFileExtension(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex > 0 && dotIndex < fileName.length - 1) {
      return fileName.substring(dotIndex);
    }
    return '';
  }

  String _truncateFileNameFromIndex(String fileName) {
    if (fileName.length > 34) {
      // substring(33) toma desde el índice 33, que es el carácter número 34 (índices empiezan en 0)
      final truncated = fileName.substring(33);
      // Eliminar espacios en blanco al inicio si los hay
      return truncated.trimLeft();
    }
    return fileName;
  }

  /// Verifica si realmente es necesario recalcular métricas
  bool _shouldTriggerMetricsRecalc(EditorUiState uiState) {
    // Verificar si cambió algo relevante
    final toolChanged = _lastActiveTool != uiState.activeTool;
    final selectionInvertedChanged = _lastSelectionInverted != uiState.selectionInverted;
    final colorModeChanged = _lastColorMode != uiState.colorMode;
    
    // Verificar si cambió la geometría de selección (comparar por valores, no referencia)
    final selectionGeometryChanged = _hasSelectionGeometryChanged(
      _lastSelectionGeometry, 
      uiState.selectionGeometry
    );
    
    // Verificar si cambió el path libre
    final freehandPathChanged = _lastFreehandPathImage != uiState.freehandPathImage;
    
    // Solo recalcular si cambió algo relevante
    return toolChanged || 
           selectionInvertedChanged || 
           colorModeChanged || 
           selectionGeometryChanged ||
           freehandPathChanged;
  }
  
  /// Compara si la geometría de selección cambió (por valores, no por referencia)
  bool _hasSelectionGeometryChanged(
    TransformableGeometry? oldGeometry,
    TransformableGeometry? newGeometry,
  ) {
    if (oldGeometry == null && newGeometry == null) return false;
    if (oldGeometry == null || newGeometry == null) return true;
    
    // Comparar valores relevantes
    return oldGeometry.shape != newGeometry.shape ||
           (oldGeometry.center.dx - newGeometry.center.dx).abs() > 0.1 ||
           (oldGeometry.center.dy - newGeometry.center.dy).abs() > 0.1 ||
           (oldGeometry.size.width - newGeometry.size.width).abs() > 0.1 ||
           (oldGeometry.size.height - newGeometry.size.height).abs() > 0.1 ||
           (oldGeometry.rotation - newGeometry.rotation).abs() > 0.01;
  }

  /// Dispara el recálculo de métricas aproximadas cuando cambia la selección o el color preset
  void _triggerMetricsRecalc(EditorUiState uiState) {
    if (!mounted) return;
    
    if (widget.imagePath == null || 
        _originalImageBytes == null || 
        _imageWidth == null || 
        _imageHeight == null) {
      return;
    }

    final extension = _getFileExtension(widget.imagePath!);
    if (extension.isEmpty) {
      return;
    }

    // Obtener tamaño del canvas desde el estado (actualizado por editor_canvas)
    final canvasSize = uiState.canvasSize ?? Size(_imageWidth!.toDouble(), _imageHeight!.toDouble());

    // Determinar tipo de métrica según el estado actual
    final isSelectionTool = uiState.activeTool == EditorTool.geometricSelection || 
                            uiState.activeTool == EditorTool.freeSelection ||
                            uiState.activeTool == EditorTool.scissors;
    
    if (isSelectionTool && uiState.hasValidSelection) {
      // SELECTION: usar updateSelectionApproxMetrics
      uiState.updateSelectionApproxMetrics(
        imgW: _imageWidth,
        imgH: _imageHeight,
        originalBytes: _originalImageBytes!.length,
        extensionLower: extension.toLowerCase(),
        canvasSize: canvasSize,
      );
    } else if (uiState.activeTool == EditorTool.color && uiState.colorMode != ColorMode.color) {
      // COLOR PRESET: usar updateColorApproxMetrics
      uiState.updateColorApproxMetrics(
        imgW: _imageWidth,
        imgH: _imageHeight,
        originalBytes: _originalImageBytes!.length,
        extensionLower: extension.toLowerCase(),
        preset: uiState.colorMode,
      );
    } else {
      // Limpiar métricas
      uiState.updateSelectionApproxMetrics(
        imgW: null,
        imgH: null,
        originalBytes: null,
        extensionLower: null,
        canvasSize: null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Construir la barra naranja usando EditorState.imageInfo (snapshot fijo)
    // No depende de EditorUiState, solo de EditorState
    final orangeBar = _buildOrangeBar();
    
    return Consumer<EditorUiState>(
      builder: (context, uiState, child) {
        // Asegurar que el nombre base y extensión estén inicializados cuando se activa herramienta de selección
        final isSelectionTool = uiState.activeTool == EditorTool.geometricSelection ||
            uiState.activeTool == EditorTool.freeSelection ||
            uiState.activeTool == EditorTool.scissors;
        if (isSelectionTool) {
          _ensureSelectionNameInitialized(uiState);
        }
        
        // Disparar recálculo de métricas SOLO cuando cambia algo relevante
        final shouldRecalc = _shouldTriggerMetricsRecalc(uiState);
        if (shouldRecalc && mounted) {
          // Usar addPostFrameCallback solo cuando realmente es necesario
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _triggerMetricsRecalc(uiState);
              // Actualizar estado de seguimiento
              _lastActiveTool = uiState.activeTool;
              _lastSelectionInverted = uiState.selectionInverted;
              _lastColorMode = uiState.colorMode;
              _lastSelectionGeometry = uiState.selectionGeometry;
            }
          });
        }
        
        return Transform.translate(
          offset: const Offset(0, -2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Barra naranja superior (25dp) - Info archivo original
              // SIEMPRE visible, independientemente del estado de selección
              orangeBar,
              // Barra blanca inferior (25dp) - Info selección/versión o mensaje de estado
              SizedBox(
                height: EditorTokens.kBarHeight,
                width: double.infinity,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: _buildWhiteBar(uiState),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Construye la barra naranja superior con la información del archivo original
  /// Esta barra lee SIEMPRE de EditorState.imageInfo (snapshot fijo, no cambia con tools/overlays)
  Widget _buildOrangeBar() {
    return Container(
      height: EditorTokens.kBarHeight,
      decoration: const BoxDecoration(
        color: AppColors.accent,
      ),
      child: widget.editorState != null
          ? ListenableBuilder(
              listenable: widget.editorState!,
              builder: (context, _) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return _buildOrangeBarContent(constraints);
                  },
                );
              },
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                return _buildOrangeBarContent(constraints);
              },
            ),
    );
  }

  /// Contenido de la barra naranja (sin el Container wrapper)
  Widget _buildOrangeBarContent(BoxConstraints constraints) {
    final barWidth = constraints.maxWidth;
    if (barWidth <= 0 || !barWidth.isFinite) {
      // Si no hay ancho válido, mostrar solo el icono de home como fallback
      return Stack(
        children: [
          Positioned(
            left: 15.0, // 15px según contrato
            top: 0,
            bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false,
                  );
                },
                child: const Icon(
                  Icons.home,
                  color: AppColors.foreground,
                  size: EditorTokens.kIconSize,
                ),
              ),
            ),
          ),
        ],
      );
    }
    
    // Divisores según contrato: 40px izquierda, 50%, 75%, 40px derecha
    final divisor1Position = 40.0; // 40px desde izquierda
    final divisor2Position = barWidth * 0.5; // 50%
    final divisor3Position = barWidth * 0.75; // 75%
    final divisor4Position = barWidth - 40.0; // 40px desde derecha
    
    // Iconos extremos: Home a 15px izquierda, Save a 15px derecha
    final homeIconLeft = 15.0;
    final saveIconRight = 15.0;
    
    // Leer información de la imagen activa visible en el preview
    final activePreviewName = widget.editorState?.activePreviewName ?? '';
    final activePreviewW = widget.editorState?.activePreviewW ?? 0;
    final activePreviewH = widget.editorState?.activePreviewH ?? 0;
    final activePreviewBytes = widget.editorState?.activePreviewBytes ?? 0;
    
    // Construir resolución y tamaño desde valores activos
    final resolution = (activePreviewW > 0 && activePreviewH > 0) 
        ? '$activePreviewW×$activePreviewH px' 
        : '';
    final fileSize = activePreviewBytes > 0
        ? (activePreviewBytes >= 1024 * 1024
            ? '${(activePreviewBytes / (1024 * 1024)).toStringAsFixed(2)} MB'
            : '${(activePreviewBytes / 1024).toStringAsFixed(2)} KB')
        : '';
          
          return Stack(
            children: [
              // Home icon: borde izquierdo a 15px del borde izquierdo
              Positioned(
                left: homeIconLeft,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                        (route) => false,
                      );
                    },
                    child: const Icon(
                      Icons.home,
                      color: AppColors.foreground,
                      size: EditorTokens.kIconSize,
                    ),
                  ),
                ),
              ),
              // Save icon: borde derecho a 15px del borde derecho
              Positioned(
                right: saveIconRight,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Consumer<EditorUiState>(
                    builder: (context, uiState, child) {
                      return GestureDetector(
                        onTap: () {
                          uiState.setActiveTool(EditorTool.save);
                        },
                        child: const Icon(
                          Icons.save,
                          color: AppColors.foreground,
                          size: EditorTokens.kIconSize,
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Divisor 1: 40px desde izquierda (invisible, mismo color que barra)
              Positioned(
                left: divisor1Position,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    width: 0.5,
                    height: 12.0,
                    color: AppColors.accent, // Mismo color que barra (invisible)
                  ),
                ),
              ),
              // Divisor 2: 50% del ancho total
              Positioned(
                left: divisor2Position,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    width: 0.5,
                    height: 12.0,
                    color: AppColors.accent, // Mismo color que barra (invisible)
                  ),
                ),
              ),
              // Divisor 3: 75% del ancho total
              Positioned(
                left: divisor3Position,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    width: 0.5,
                    height: 12.0,
                    color: AppColors.accent, // Mismo color que barra (invisible)
                  ),
                ),
              ),
              // Divisor 4: 40px desde derecha (invisible, mismo color que barra)
              Positioned(
                left: divisor4Position,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    width: 0.5,
                    height: 12.0,
                    color: AppColors.accent, // Mismo color que barra (invisible)
                  ),
                ),
              ),
              // Campo 1: entre Divisor 1 (40px) y Divisor 2 (50%) - Nombre del archivo
              Positioned(
                left: divisor1Position,
                right: barWidth - divisor2Position,
                top: 0,
                bottom: 0,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Builder(
                    builder: (context) {
                      // Obtener nombre de la imagen activa visible
                      final displayName = activePreviewName.isNotEmpty
                          ? activePreviewName
                          : (widget.imagePath != null 
                              ? widget.imagePath!.split(Platform.pathSeparator).last 
                              : 'imagen.jpg');
                      return Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.foreground,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      );
                    },
                  ),
                ),
              ),
              // Campo 2: entre Divisor 2 (50%) y Divisor 3 (75%) - Resolución
              Positioned(
                left: divisor2Position,
                right: barWidth - divisor3Position,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Builder(
                    builder: (context) {
                      // Leer resolución de la imagen activa visible
                      if (resolution.isNotEmpty) {
                        return Text(
                          resolution,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.foreground,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
              // Campo 3: entre Divisor 3 (75%) y Divisor 4 (40px desde derecha) - Tamaño
              Positioned(
                left: divisor3Position,
                right: barWidth - divisor4Position,
                top: 0,
                bottom: 0,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Builder(
                    builder: (context) {
                      // Leer tamaño de la imagen activa visible
                      if (fileSize.isNotEmpty) {
                        return Text(
                          fileSize,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.foreground,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ],
          );
  }

  Widget _buildWhiteBar(EditorUiState uiState) {
    // Actualizar textos estructurados y de soporte
    _updateWhiteBarTexts(uiState);

    // Verificar si la herramienta activa es una herramienta de selección
    final isSelectionTool = uiState.activeTool == EditorTool.geometricSelection ||
        uiState.activeTool == EditorTool.freeSelection ||
        uiState.activeTool == EditorTool.scissors;

    // Verificar si hay color preset activo (no color normal)
    final isColorPresetActive = uiState.activeTool == EditorTool.color && 
                                uiState.colorMode != ColorMode.color;

    // Verificar si hay selección válida para mostrar iconos
    final hasValidSelection = uiState.hasValidSelection;

    // Modo structured: cuando hay herramienta de selección activa o color preset, usar layout de tres espacios
    if (isSelectionTool || isColorPresetActive) {
      return LayoutBuilder(
        builder: (context, constraints) {
          // Validar que tenemos un ancho válido
          final barWidth = constraints.maxWidth;
          if (barWidth <= 0 || !barWidth.isFinite) {
            return const SizedBox.shrink();
          }
          
          // Divisores según contrato: 40px izquierda, 50%, 75%, 40px derecha (misma grilla que TopBar)
          final divisor1Position = 40.0; // 40px desde izquierda
          final divisor2Position = barWidth * 0.5; // 50%
          final divisor3Position = barWidth * 0.75; // 75%
          final divisor4Position = barWidth - 40.0; // 40px desde derecha
          
          // Iconos extremos: a 15px según contrato
          final iconLeft = 15.0;
          final iconRight = 15.0;
          
          // Validar posiciones
          if (divisor1Position <= 0 || divisor2Position <= 0 || divisor3Position <= 0 || divisor4Position <= 0 ||
              divisor1Position >= barWidth || divisor2Position >= barWidth || divisor3Position >= barWidth || divisor4Position >= barWidth ||
              divisor1Position >= divisor2Position || divisor2Position >= divisor3Position || divisor3Position >= divisor4Position) {
            return const SizedBox.shrink();
          }
          
          // Obtener nombre base, suffix y extensión
          String baseName;
          String versionSuffix = '_V01'; // Default
          String extension;
          
          if (uiState.selectionVersionBaseName != null && uiState.originalFileExtension != null) {
            // Extraer nombre base y suffix del texto guardado
            final savedText = uiState.selectionVersionBaseName!;
            extension = uiState.originalFileExtension!;
            
            // Buscar si contiene "_V" seguido de algo
            final vPattern = RegExp(r'_V\d+$');
            final match = vPattern.firstMatch(savedText);
            
            if (match != null) {
              // Contiene "_V01", "_V02", etc.
              baseName = savedText.substring(0, match.start);
              versionSuffix = savedText.substring(match.start);
            } else {
              // No contiene suffix, usar el texto completo como nombre base
              baseName = savedText;
              versionSuffix = '_V01'; // Default
            }
          } else {
            // Usar nombre del archivo original (fallback)
            final originalFileName = widget.imagePath != null 
                ? widget.imagePath!.split(Platform.pathSeparator).last 
                : 'imagen.jpg';
            final dotIndex = originalFileName.lastIndexOf('.');
            if (dotIndex > 0 && dotIndex < originalFileName.length - 1) {
              baseName = originalFileName.substring(0, dotIndex);
              extension = originalFileName.substring(dotIndex);
            } else {
              baseName = originalFileName;
              extension = '';
            }
            versionSuffix = '_V01'; // Default
          }
          
          String? labelLeft;
          String? selectionDef;
          String? approxSize;
          
          if (isSelectionTool) {
            // Selección: usar nombre editable y definición de selección
            labelLeft = uiState.approxLabelLeft ?? 'Selección: ${baseName}${extension}';
            selectionDef = _getSelectionDefinition(uiState);
            approxSize = _getApproxSize(uiState);
          } else if (isColorPresetActive) {
            // Color preset: usar label y dimensiones de métricas aproximadas
            labelLeft = uiState.approxLabelLeft ?? 'Color: ${_getColorPresetName(uiState.colorMode)}';
            if (uiState.approxWidthPx > 0 && uiState.approxHeightPx > 0) {
              selectionDef = '${uiState.approxWidthPx}×${uiState.approxHeightPx} px';
            } else if (_imageWidth != null && _imageHeight != null) {
              selectionDef = '$_imageWidth×$_imageHeight px';
            } else {
              selectionDef = null;
            }
            approxSize = _getApproxSize(uiState);
          }
          
          return Stack(
            children: [
              // Divisor 1: 40px desde izquierda (invisible, mismo color que barra)
              Positioned(
                left: divisor1Position,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    width: 0.5,
                    height: 12.0,
                    color: Colors.white, // Mismo color que barra (invisible)
                  ),
                ),
              ),
              // Divisor 2: 50% del ancho total
              Positioned(
                left: divisor2Position,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    width: 0.5,
                    height: 12.0,
                    color: Colors.white, // Mismo color que barra (invisible)
                  ),
                ),
              ),
              // Divisor 3: 75% del ancho total
              Positioned(
                left: divisor3Position,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    width: 0.5,
                    height: 12.0,
                    color: Colors.white, // Mismo color que barra (invisible)
                  ),
                ),
              ),
              // Divisor 4: 40px desde derecha (invisible, mismo color que barra)
              Positioned(
                left: divisor4Position,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    width: 0.5,
                    height: 12.0,
                    color: Colors.white, // Mismo color que barra (invisible)
                  ),
                ),
              ),
              // Icono de inversión (izquierda) - a 15px según contrato
              if (hasValidSelection)
                Positioned(
                  left: iconLeft,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        uiState.toggleSelectionInverted();
                      },
                      child: Icon(
                        Icons.swap_horiz,
                        color: AppColors.accent,
                        size: EditorTokens.kIconSize,
                      ),
                    ),
                  ),
                ),
              // Campo 1: entre Divisor 1 (40px) y Divisor 2 (50%) - Label izquierdo
              Positioned(
                left: divisor1Position,
                right: barWidth - divisor2Position,
                top: 0,
                bottom: 0,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: isSelectionTool
                      ? _EditableNameField(
                          baseName: baseName,
                          extension: extension,
                          versionSuffix: versionSuffix,
                          onChanged: (editedText) {
                            final trimmedText = editedText.trim();
                            if (trimmedText.isEmpty) {
                              // Si está vacío, restaurar el nombre base original
                              uiState.setSelectionVersionBaseName(baseName);
                              return;
                            }
                            
                            // Guardar el texto completo editado (nombre + suffix)
                            // Esto permite que el usuario edite tanto el nombre como el suffix
                            uiState.setSelectionVersionBaseName(trimmedText);
                          },
                        )
                      : (labelLeft != null
                          ? Text(
                              labelLeft,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.accent,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            )
                          : const SizedBox.shrink()),
                ),
              ),
              // Campo 2: entre Divisor 2 (50%) y Divisor 3 (75%) - Definición de la selección
              Positioned(
                left: divisor2Position,
                right: barWidth - divisor3Position,
                top: 0,
                bottom: 0,
                child: Center(
                  child: selectionDef != null
                      ? Text(
                          selectionDef,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.accent,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        )
                      : const SizedBox.shrink(),
                ),
              ),
              // Campo 3: entre Divisor 3 (75%) y Divisor 4 (40px desde derecha) - Tamaño estimado
              Positioned(
                left: divisor3Position,
                right: barWidth - divisor4Position,
                top: 0,
                bottom: 0,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: approxSize != null
                      ? Text(
                          approxSize,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.accent,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        )
                      : const SizedBox.shrink(),
                ),
              ),
              // Icono de tijera (derecha) - a 15px según contrato, solo para selección
              if (hasValidSelection && isSelectionTool)
                Positioned(
                  right: iconRight,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        // Mostrar overlay de tijera (Interior/Exterior) en lugar de ejecutar directamente
                        uiState.setContext(EditorContext.scissors);
                      },
                      child: Icon(
                        Icons.content_cut,
                        color: AppColors.accent,
                        size: EditorTokens.kIconSize,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      );
    }

    // Modo support (InfoBarHelp): mensajes circulan de derecha a izquierda
    // entre 40px desde la izquierda y 40px desde la derecha
    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth;
        if (barWidth <= 0 || !barWidth.isFinite) {
          return const SizedBox.shrink();
        }
        
        // Área delimitada: 40px desde izquierda, 40px desde derecha
        final leftMargin = 40.0;
        final rightMargin = 40.0;
        
        return Stack(
          children: [
            Positioned(
              left: leftMargin,
              right: rightMargin,
              top: 0,
              bottom: 0,
              child: Align(
                alignment: Alignment.centerRight, // Derecha a izquierda: empezar desde la derecha
                child: _buildSupportContent(uiState),
              ),
            ),
          ],
        );
      },
    );
  }

  void _updateWhiteBarTexts(EditorUiState uiState) {
    // Construir mensaje de soporte
    final statusMessage = uiState.statusMessage;
    if (statusMessage != null && statusMessage.isNotEmpty) {
      uiState.setSupportMessageText(statusMessage);
    } else {
      uiState.setSupportMessageText('Selecciona una herramienta para comenzar');
    }
  }

  Widget _buildSupportContent(EditorUiState uiState) {
    final supportMessage = uiState.supportMessageText ?? 'Selecciona una herramienta para comenzar';
    return _TickerText(
      text: supportMessage,
    );
  }

  String? _getSelectionDefinition(EditorUiState uiState) {
    // Usar métricas aproximadas REALES si están disponibles
    if (uiState.approxWidthPx > 0 && uiState.approxHeightPx > 0) {
      return '${uiState.approxWidthPx}×${uiState.approxHeightPx} px';
    }
    
    // Si hay herramienta de selección activa pero métricas son 0, selección inválida
    final isSelectionTool = uiState.activeTool == EditorTool.geometricSelection ||
        uiState.activeTool == EditorTool.freeSelection ||
        uiState.activeTool == EditorTool.scissors;
    if (isSelectionTool && (uiState.selectionGeometry != null || uiState.freeSelectionPath != null)) {
      // Selección inválida (fuera de imagen o sin intersección)
      return '—';
    }
    
    // No hay selección válida o métricas no disponibles
    return null;
  }

  String? _getApproxSize(EditorUiState uiState) {
    // Usar métricas aproximadas REALES si están disponibles
    if (uiState.approxBytes > 0) {
      final sizeMB = uiState.approxBytes / (1024 * 1024);
      if (sizeMB.isFinite && sizeMB >= 0) {
        if (sizeMB >= 1.0) {
          return '~${sizeMB.toStringAsFixed(2)} MB';
        } else {
          // Mostrar en KB si es menor a 1 MB
          final sizeKB = uiState.approxBytes / 1024;
          return '~${sizeKB.toStringAsFixed(2)} KB';
        }
      }
    }
    
    // Si hay herramienta de selección activa pero métricas son 0, selección inválida
    final isSelectionTool = uiState.activeTool == EditorTool.geometricSelection ||
        uiState.activeTool == EditorTool.freeSelection ||
        uiState.activeTool == EditorTool.scissors;
    if (isSelectionTool && (uiState.selectionGeometry != null || uiState.freeSelectionPath != null)) {
      // Selección inválida (fuera de imagen o sin intersección)
      return '—';
    }
    
    // Fallback: no mostrar nada si no hay métricas
    return null;
  }

  String _getColorPresetName(ColorMode mode) {
    switch (mode) {
      case ColorMode.grayscale:
        return 'Grises';
      case ColorMode.sepia:
        return 'Sepia';
      case ColorMode.blackAndWhite:
        return 'B&N';
      case ColorMode.color:
        return 'Color';
    }
  }

  String? _getEstimatedSize(EditorUiState uiState) {
    // DEPRECATED: usar _getExactSize en su lugar
    // Mantenido por compatibilidad temporal
    if (_originalFileSizeMB == null || _imageWidth == null || _imageHeight == null) {
      return null;
    }

    double selectionArea = 0.0;
    double imageArea = _imageWidth! * _imageHeight!.toDouble();

    if (uiState.freeSelectionPath != null) {
      // Freehand: usar área del bounding box como aproximación
      final bounds = uiState.freeSelectionPath!.getBounds();
      selectionArea = bounds.width * bounds.height;
    } else if (uiState.selectionGeometry != null) {
      final geometry = uiState.selectionGeometry!;
      if (geometry.shape == TransformableShape.circle) {
        // Circle: π * r²
        final radius = geometry.size.width / 2;
        selectionArea = math.pi * radius * radius;
      } else {
        // Rect: width * height
        selectionArea = geometry.size.width * geometry.size.height;
      }
    } else {
      return null;
    }

    if (imageArea <= 0) return null;

    // Estimación: (areaSelection/areaImage) * originalSizeMB
    double estimatedMB = (selectionArea / imageArea) * _originalFileSizeMB!;
    estimatedMB = estimatedMB.clamp(0.01, _originalFileSizeMB!);
    
    return '~ ${estimatedMB.toStringAsFixed(2)} MB';
  }

  Future<void> _executeScissors(BuildContext context, EditorUiState uiState) async {
    if (widget.imagePath == null || !uiState.hasValidSelection) {
      return;
    }

    try {
      // Leer imagen original
      final originalFile = File(widget.imagePath!);
      final imageBytes = await originalFile.readAsBytes();
      final originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        return;
      }

      // Obtener geometría de selección o path libre
      final geometry = uiState.selectionGeometry;
      final freehandPathImage = uiState.freehandPathImage;
      
      if (geometry == null && freehandPathImage == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No hay selección válida'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
        return;
      }
      
      // Si hay path libre, usar ese (delegar a scissors_overlay)
      if (freehandPathImage != null) {
        // Por ahora, mostrar mensaje de que use el overlay de tijera
        // En producción, podríamos llamar directamente al método de scissors_overlay
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Use el icono de tijera en la barra blanca para selección libre'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
        return;
      }
      
      // Verificar que tenemos geometría válida
      if (geometry == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No hay selección válida'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
        return;
      }
      
      // Convertir coordenadas del canvas a coordenadas de la imagen
      final imageWidth = originalImage.width.toDouble();
      final imageHeight = originalImage.height.toDouble();
      final canvasSize = Size(imageWidth, imageHeight);
      
      // Escalar geometría a coordenadas de imagen
      final scaleX = imageWidth / canvasSize.width;
      final scaleY = imageHeight / canvasSize.height;
      
      final scaledCenter = Offset(
        geometry.center.dx * scaleX,
        geometry.center.dy * scaleY,
      );
      final scaledSize = Size(
        geometry.size.width * scaleX,
        geometry.size.height * scaleY,
      );
      
      final scaledGeometry = TransformableGeometry(
        shape: geometry.shape,
        center: scaledCenter,
        size: scaledSize,
        rotation: geometry.rotation,
      );
      
      final selectionRect = scaledGeometry.boundingBox;

      // Obtener estado de inversión
      final isInterior = !uiState.selectionInverted;

      // Aplicar recorte según modo
      img.Image? resultImage;
      if (isInterior) {
        // Interior: recortar a la selección
        final x = selectionRect.left.toInt().clamp(0, originalImage.width);
        final y = selectionRect.top.toInt().clamp(0, originalImage.height);
        final w = selectionRect.width.toInt().clamp(0, originalImage.width - x);
        final h = selectionRect.height.toInt().clamp(0, originalImage.height - y);
        
        if (scaledGeometry.shape == TransformableShape.circle) {
          // Recortar círculo: crear máscara circular
          final radius = math.min(scaledGeometry.size.width, scaledGeometry.size.height) / 2;
          final centerX = scaledGeometry.center.dx.toInt().clamp(0, originalImage.width);
          final centerY = scaledGeometry.center.dy.toInt().clamp(0, originalImage.height);
          
          resultImage = img.copyCrop(
            originalImage,
            x: (centerX - radius).toInt().clamp(0, originalImage.width),
            y: (centerY - radius).toInt().clamp(0, originalImage.height),
            width: (radius * 2).toInt().clamp(0, originalImage.width),
            height: (radius * 2).toInt().clamp(0, originalImage.height),
          );
          
          // Aplicar máscara circular
          for (var py = 0; py < resultImage.height; py++) {
            for (var px = 0; px < resultImage.width; px++) {
              final dx = px - radius;
              final dy = py - radius;
              if (dx * dx + dy * dy > radius * radius) {
                resultImage.setPixelRgba(px, py, 0, 0, 0, 0);
              }
            }
          }
        } else {
          resultImage = img.copyCrop(originalImage, x: x, y: y, width: w, height: h);
        }
      } else {
        // Exterior: conservar exterior, eliminar interior
        resultImage = img.copyResize(originalImage, width: originalImage.width, height: originalImage.height);
        
        if (scaledGeometry.shape == TransformableShape.circle) {
          final radius = math.min(scaledGeometry.size.width, scaledGeometry.size.height) / 2;
          final centerX = scaledGeometry.center.dx.toInt().clamp(0, originalImage.width);
          final centerY = scaledGeometry.center.dy.toInt().clamp(0, originalImage.height);
          
          for (var py = 0; py < resultImage.height; py++) {
            for (var px = 0; px < resultImage.width; px++) {
              final dx = px - centerX;
              final dy = py - centerY;
              if (dx * dx + dy * dy <= radius * radius) {
                final ext = widget.imagePath!.toLowerCase();
                if (ext.endsWith('.png')) {
                  resultImage.setPixelRgba(px, py, 0, 0, 0, 0);
                } else {
                  resultImage.setPixelRgba(px, py, 0, 0, 0, 255);
                }
              }
            }
          }
        } else {
          final x = selectionRect.left.toInt();
          final y = selectionRect.top.toInt();
          final w = selectionRect.width.toInt();
          final h = selectionRect.height.toInt();
          final ext = widget.imagePath!.toLowerCase();
          
          for (var py = y; py < y + h && py < resultImage.height; py++) {
            for (var px = x; px < x + w && px < resultImage.width; px++) {
              if (ext.endsWith('.png')) {
                resultImage.setPixelRgba(px, py, 0, 0, 0, 0);
              } else {
                resultImage.setPixelRgba(px, py, 0, 0, 0, 255);
              }
            }
          }
        }
      }

      // Generar nombre versionado
      final newPath = await FileVersioning.buildVersionedName(widget.imagePath!);
      
      // Guardar imagen
      final ext = widget.imagePath!.toLowerCase();
      Uint8List? outputBytes;
      if (ext.endsWith('.png')) {
        outputBytes = Uint8List.fromList(img.encodePng(resultImage));
      } else if (ext.endsWith('.jpg') || ext.endsWith('.jpeg')) {
        outputBytes = Uint8List.fromList(img.encodeJpg(resultImage));
      } else {
        outputBytes = Uint8List.fromList(img.encodePng(resultImage));
      }
      
      final newFile = File(newPath);
      await newFile.writeAsBytes(outputBytes);

      // Actualizar estado y navegar al nuevo archivo
      // No llamamos a setActiveTool aquí porque navegamos a una nueva pantalla
      // que creará su propio estado
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => EditorScreen(imagePath: newPath),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al aplicar tijera: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }
}

/// Widget de ticker horizontal que desplaza texto de derecha a izquierda
/// Acotado entre 40px izquierda y 40px derecha según UI_CONTRACT.md
class _TickerText extends StatefulWidget {
  final String text;

  const _TickerText({
    required this.text,
  });

  @override
  State<_TickerText> createState() => _TickerTextState();
}

class _TickerTextState extends State<_TickerText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20), // Duración del ciclo completo
      vsync: this,
    )..repeat(); // Repetir continuamente

    // Animación que va de 1.0 a -1.0 (derecha a izquierda)
    _animation = Tween<double>(begin: 1.0, end: -1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportWidth = constraints.maxWidth;
        if (viewportWidth <= 0 || !viewportWidth.isFinite) {
          return const SizedBox.shrink();
        }

        // Medir el ancho del texto
        final textPainter = TextPainter(
          text: TextSpan(
            text: widget.text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.accent,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        final textWidth = textPainter.size.width;

        // Si el texto cabe en el viewport, no necesita animación
        if (textWidth <= viewportWidth) {
          return Center(
            child: Text(
              widget.text,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.accent,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          );
        }

        // Calcular el rango de desplazamiento
        // El texto debe moverse desde viewportWidth (derecha) hasta -textWidth (izquierda)
        // Cuando animation = 1.0: texto empieza desde la derecha (offsetX = viewportWidth)
        // Cuando animation = -1.0: texto termina completamente fuera por la izquierda (offsetX = -textWidth)
        final startOffset = viewportWidth; // Texto empieza desde la derecha
        final endOffset = -textWidth; // Texto termina completamente fuera por la izquierda

        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            // Calcular la posición X basada en la animación
            // _animation.value va de 1.0 a -1.0, necesitamos mapearlo a startOffset..endOffset
            final t = (_animation.value + 1.0) / 2.0; // Normalizar a 0.0..1.0
            final offsetX = startOffset + t * (endOffset - startOffset);

            return ClipRect(
              child: Transform.translate(
                offset: Offset(offsetX, 0),
                child: Text(
                  widget.text,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.accent,
                  ),
                  overflow: TextOverflow.visible,
                  maxLines: 1,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Widget para nombre editable inline
class _EditableNameField extends StatefulWidget {
  final String baseName;
  final String extension;
  final String? versionSuffix; // "_V01" o null
  final ValueChanged<String> onChanged;

  const _EditableNameField({
    required this.baseName,
    required this.extension,
    this.versionSuffix,
    required this.onChanged,
  });

  @override
  State<_EditableNameField> createState() => _EditableNameFieldState();
}

class _EditableNameFieldState extends State<_EditableNameField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isEditing = false;

  String get _fullName {
    final versionSuffix = widget.versionSuffix ?? '';
    return '${widget.baseName}$versionSuffix${widget.extension}';
  }

  String get _editablePart {
    // Parte editable: nombre base + "_V01" (sin extensión)
    final versionSuffix = widget.versionSuffix ?? '';
    return '${widget.baseName}$versionSuffix';
  }

  @override
  void initState() {
    super.initState();
    // El controlador contiene el nombre base + "_V01" (sin extensión)
    _controller = TextEditingController(text: _editablePart);
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isEditing) {
        _isEditing = false;
        // Pasar el texto completo editado (nombre + "_V01") al callback
        widget.onChanged(_controller.text);
      }
    });
  }

  @override
  void didUpdateWidget(_EditableNameField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Actualizar si el nombre base o el suffix cambió y no estamos editando
    final newEditablePart = _editablePart;
    final oldEditablePart = '${oldWidget.baseName}${oldWidget.versionSuffix ?? ''}';
    if (newEditablePart != oldEditablePart && !_isEditing) {
      _controller.text = newEditablePart;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 150,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.accent,
              ),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.accent, width: 1),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.accent, width: 1),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.accent, width: 1),
                ),
              ),
              onSubmitted: (value) {
                _isEditing = false;
                _focusNode.unfocus();
                widget.onChanged(value);
              },
              onEditingComplete: () {
                _isEditing = false;
                _focusNode.unfocus();
                widget.onChanged(_controller.text);
              },
            ),
          ),
          // Extensión fija (no editable)
          Text(
            widget.extension,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.accent,
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _isEditing = true;
        });
        Future.delayed(const Duration(milliseconds: 50), () {
          _focusNode.requestFocus();
          _controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: _controller.text.length,
          );
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _editablePart,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.accent,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.accent,
            ),
          ),
          // Extensión fija (no editable)
          Text(
            widget.extension,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}
