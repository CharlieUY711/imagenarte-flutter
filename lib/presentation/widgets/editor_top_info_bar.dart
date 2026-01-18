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
import 'package:imagenarte/domain/transformable_geometry.dart';
import 'package:imagenarte/infrastructure/file_versioning.dart';
import 'package:imagenarte/presentation/screens/editor_screen.dart';
import 'package:imagenarte/presentation/screens/home_screen.dart';

class EditorTopInfoBar extends StatefulWidget {
  final String? imagePath;

  const EditorTopInfoBar({
    super.key,
    this.imagePath,
  });

  @override
  State<EditorTopInfoBar> createState() => _EditorTopInfoBarState();
}

class _EditorTopInfoBarState extends State<EditorTopInfoBar> {
  String? _fileName;
  String? _resolution;
  String? _fileSize;
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
    _loadFileInfo();
    // Inicializar valores de seguimiento
    _lastActiveTool = null;
    _lastSelectionInverted = false;
    _lastColorMode = null;
    _lastSelectionGeometry = null;
    _lastFreehandPathImage = null;
  }

  @override
  void didUpdateWidget(EditorTopInfoBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Solo recargar si el imagePath cambió realmente
    if (oldWidget.imagePath != widget.imagePath) {
      _loadFileInfo();
    }
    // Si el imagePath es el mismo pero los valores se perdieron, recargar
    else if (widget.imagePath != null && _fileName == null && _resolution == null) {
      _loadFileInfo();
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

  Future<void> _loadFileInfo() async {
    if (widget.imagePath == null) {
      setState(() {
        _fileName = null;
        _resolution = null;
        _fileSize = null;
        _imageWidth = null;
        _imageHeight = null;
        _originalFileSizeMB = null;
      });
      return;
    }

    // Establecer nombre del archivo inmediatamente (síncrono)
    final fileNameFromPath = widget.imagePath!.split(Platform.pathSeparator).last;
    if (mounted) {
      setState(() {
        _fileName = fileNameFromPath;
      });
    }

    // Obtener uiState antes del async gap
    final uiState = mounted ? Provider.of<EditorUiState>(context, listen: false) : null;
    
    // Inicializar extensión y nombre base INMEDIATAMENTE (síncrono) antes de operaciones async
    if (mounted && uiState != null && fileNameFromPath.isNotEmpty) {
      uiState.setOriginalFileExtension(_getFileExtension(fileNameFromPath));
      uiState.initializeSelectionVersionNameIfNeeded(fileNameFromPath);
    }

    try {
      final file = File(widget.imagePath!);
      // El nombre ya está establecido arriba, pero lo actualizamos por si acaso
      _fileName = file.uri.pathSegments.last;
      
      // Obtener tamaño del archivo
      final fileSizeBytes = await file.length();
      _originalFileSizeMB = fileSizeBytes / (1024 * 1024);
      _fileSize = '${_originalFileSizeMB!.toStringAsFixed(2)} MB';

      // Obtener resolución de la imagen
      final imageBytes = await file.readAsBytes();
      _originalImageBytes = imageBytes;
      final codec = await ui.instantiateImageCodec(imageBytes);
      final frame = await codec.getNextFrame();
      _imageWidth = frame.image.width;
      _imageHeight = frame.image.height;
      _resolution = '$_imageWidth×$_imageHeight px';

      // La inicialización ya se hizo arriba de forma síncrona, pero verificamos por si acaso
      if (mounted && uiState != null && _fileName != null) {
        // Solo actualizar si no estaba inicializado antes
        if (uiState.originalFileExtension == null) {
          uiState.setOriginalFileExtension(_getFileExtension(_fileName!));
        }
        if (uiState.selectionVersionBaseName == null) {
          uiState.initializeSelectionVersionNameIfNeeded(_fileName!);
        }
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      // Si hay error, mostrar valores por defecto
      if (mounted) {
        setState(() {
          _fileName = widget.imagePath?.split(Platform.pathSeparator).last;
          _resolution = null;
          _fileSize = null;
          _imageWidth = null;
          _imageHeight = null;
          _originalFileSizeMB = null;
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
    // Asegurar que la información del archivo esté cargada antes de renderizar
    if (widget.imagePath != null && _fileName == null && _resolution == null) {
      // Si tenemos imagePath pero no tenemos datos, cargar la información
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadFileInfo();
        }
      });
    }
    
    // Construir la barra naranja fuera del Consumer para que no se reconstruya
    // cuando cambia el estado de selección - esto asegura que siempre esté visible
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
        
        return Column(
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
        );
      },
    );
  }

  /// Construye la barra naranja superior con la información del archivo original
  /// Esta barra NO depende del estado de selección y siempre debe estar visible
  Widget _buildOrangeBar() {
    return Container(
      height: EditorTokens.kBarHeight,
      decoration: const BoxDecoration(
        color: AppColors.accent,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final barWidth = constraints.maxWidth;
          if (barWidth <= 0 || !barWidth.isFinite) {
            // Si no hay ancho válido, mostrar solo el icono de home como fallback
            return Stack(
              children: [
                Positioned(
                  left: EditorTokens.kContentHPad,
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
          
          final divisor1Position = barWidth * 0.5; // Divisor del centro (50%)
          final divisor2Position = barWidth * 0.75; // Divisor a 3/4 (75%)
          final iconSlotWidth = EditorTokens.kContentHPad + EditorTokens.kIconSize + EditorTokens.kIconGap;
          
          return Stack(
            children: [
              // Casita fija a 16dp desde la izquierda, centrada verticalmente
              // SIEMPRE visible, incluso durante reconstrucciones
              Positioned(
                left: EditorTokens.kContentHPad,
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
              // Disco fijo a 16dp desde la derecha, centrado verticalmente
              Positioned(
                right: EditorTokens.kContentHPad,
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
              // Divisor 1: a la mitad de la barra (50%) - FIJO
              Positioned(
                left: divisor1Position,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    width: 0.5,
                    height: 12.0,
                    color: Colors.black,
                  ),
                ),
              ),
              // Divisor 2: a 3/4 de la barra (75%) - FIJO
              Positioned(
                left: divisor2Position,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    width: 0.5,
                    height: 12.0,
                    color: Colors.black,
                  ),
                ),
              ),
              // ESPACIO 1: Nombre del archivo (entre casita y divisor del centro)
              // Alineado al margen izquierdo
              // SIEMPRE mostrar el nombre del archivo, incluso si _fileName es null temporalmente
              Positioned(
                left: iconSlotWidth,
                right: barWidth - divisor1Position,
                top: 0,
                bottom: 0,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Builder(
                    builder: (context) {
                      // Obtener nombre del archivo de forma segura
                      final displayName = _fileName ?? 
                          (widget.imagePath != null 
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
              // ESPACIO 2: Definición/resolución (entre divisor del centro y divisor a 3/4)
              // Centrado entre los divisores
              // SIEMPRE intentar mostrar la resolución si está disponible
              Positioned(
                left: divisor1Position,
                right: barWidth - divisor2Position,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Builder(
                    builder: (context) {
                      // Si tenemos imagePath pero no tenemos _resolution, intentar obtenerla del path
                      if (widget.imagePath != null && _resolution != null) {
                        return Text(
                          _resolution!,
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
              // ESPACIO 3: Tamaño del archivo (entre divisor a 3/4 y disco)
              // Alineado al margen derecho
              // SIEMPRE intentar mostrar el tamaño si está disponible
              Positioned(
                left: divisor2Position,
                right: iconSlotWidth,
                top: 0,
                bottom: 0,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Builder(
                    builder: (context) {
                      if (widget.imagePath != null && _fileSize != null) {
                        return Text(
                          _fileSize!,
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
        },
      ),
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
          
          final divisor1Position = barWidth * 0.5; // Divisor del centro (50%)
          final divisor2Position = barWidth * 0.75; // Divisor a 3/4 (75%)
          final iconSlotWidth = EditorTokens.kContentHPad + EditorTokens.kIconSize + EditorTokens.kIconGap;
          
          // Validar posiciones
          if (divisor1Position <= 0 || divisor2Position <= 0 || 
              divisor1Position >= barWidth || divisor2Position >= barWidth ||
              divisor1Position >= divisor2Position) {
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
              // Icono de inversión abajo de la casita (izquierda)
              if (hasValidSelection)
                Positioned(
                  left: EditorTokens.kContentHPad,
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
              // ESPACIO 1: Label izquierdo (nombre editable para selección, label para color)
              Positioned(
                left: iconSlotWidth,
                right: barWidth - divisor1Position,
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
              // ESPACIO 2: Definición de la selección (entre divisor del centro y divisor a 3/4)
              // Centrado entre los divisores (sin divisores visibles)
              Positioned(
                left: divisor1Position,
                right: barWidth - divisor2Position,
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
              // ESPACIO 3: Tamaño estimado (entre divisor a 3/4 y disco/tijera)
              // Alineado al margen derecho (misma posición que barra naranja)
              Positioned(
                left: divisor2Position,
                right: iconSlotWidth,
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
              // Icono de tijera abajo del disco (derecha) - solo para selección
              if (hasValidSelection && isSelectionTool)
                Positioned(
                  right: EditorTokens.kContentHPad,
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

    // Modo support: mensajes y tips alineados al margen izquierdo (mismo que barra superior)
    return LayoutBuilder(
      builder: (context, constraints) {
        final iconSlotWidth = EditorTokens.kContentHPad + EditorTokens.kIconSize + EditorTokens.kIconGap;
        
        return Stack(
          children: [
            Positioned(
              left: iconSlotWidth,
              right: 0,
              top: 0,
              bottom: 0,
              child: Align(
                alignment: Alignment.centerLeft,
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
    return Text(
      supportMessage,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.accent,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }


  String? _getSelectionDefinition(EditorUiState uiState) {
    // Usar métricas aproximadas si están disponibles
    if (uiState.approxWidthPx > 0 && uiState.approxHeightPx > 0) {
      return '${uiState.approxWidthPx}×${uiState.approxHeightPx} px';
    }
    
    // Fallback: usar geometría del canvas (solo para visualización temporal)
    if (uiState.freeSelectionPath != null) {
      try {
        // Freehand: usar bounding box
        final bounds = uiState.freeSelectionPath!.getBounds();
        if (bounds.width.isFinite && bounds.height.isFinite &&
            bounds.width > 0 && bounds.height > 0) {
          final width = bounds.width.toInt();
          final height = bounds.height.toInt();
          if (width > 0 && height > 0) {
            return '$width×$height px';
          }
        }
      } catch (e) {
        // Si hay error al calcular bounds, retornar null
        return null;
      }
    }
    
    if (uiState.selectionGeometry != null) {
      try {
        final geometry = uiState.selectionGeometry!;
        if (geometry.size.width.isFinite && geometry.size.height.isFinite &&
            geometry.size.width > 0 && geometry.size.height > 0) {
          if (geometry.shape == TransformableShape.circle) {
            // Circle: usar diámetro
            final diameter = geometry.size.width.toInt();
            if (diameter > 0) {
              return 'Ø $diameter px';
            }
          } else {
            // Rect: W×H px
            final width = geometry.size.width.toInt();
            final height = geometry.size.height.toInt();
            if (width > 0 && height > 0) {
              return '$width×$height px';
            }
          }
        }
      } catch (e) {
        // Si hay error al procesar geometría, retornar null
        return null;
      }
    }
    
    return null;
  }

  String? _getApproxSize(EditorUiState uiState) {
    // Usar métricas aproximadas si están disponibles
    if (uiState.approxBytes > 0) {
      final sizeMB = uiState.approxBytes / (1024 * 1024);
      if (sizeMB.isFinite && sizeMB >= 0) {
        return '~${sizeMB.toStringAsFixed(2)} MB';
      }
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
