import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:imagenarte/app/theme/app_colors.dart';
import 'package:imagenarte/presentation/theme/editor_tokens.dart';
import 'package:imagenarte/application/editor_ui_state.dart';
import 'package:imagenarte/domain/transformable_geometry.dart';
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

  @override
  void initState() {
    super.initState();
    _loadFileInfo();
  }

  @override
  void didUpdateWidget(EditorTopInfoBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagePath != widget.imagePath) {
      _loadFileInfo();
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
      final codec = await ui.instantiateImageCodec(imageBytes);
      final frame = await codec.getNextFrame();
      _imageWidth = frame.image.width;
      _imageHeight = frame.image.height;
      _resolution = '$_imageWidth×$_imageHeight px';

      // Inicializar extensión y nombre base en el estado
      if (mounted && uiState != null) {
        uiState.setOriginalFileExtension(_getFileExtension(_fileName!));
        uiState.initializeSelectionVersionNameIfNeeded(_fileName!);
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

  @override
  Widget build(BuildContext context) {
    return Consumer<EditorUiState>(
      builder: (context, uiState, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Barra naranja superior (25dp) - Info archivo original
            Container(
              height: EditorTokens.kBarHeight,
              decoration: const BoxDecoration(
                color: AppColors.accent,
              ),
              child: Row(
                children: [
                  // 1) Slot izquierdo fijo: Home icon (alineado al borde izquierdo)
                  SizedBox(
                    width: EditorTokens.kLeftIconSlotW,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: EditorTokens.kContentHPad),
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
                  ),
                  // 2) Expanded flex:5 - Filename (alineado a la izquierda, exactamente después de Home)
                  Expanded(
                    flex: 5,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _fileName ?? (widget.imagePath != null 
                            ? widget.imagePath!.split(Platform.pathSeparator).last 
                            : 'imagen.jpg'),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.foreground,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  // 3) Expanded flex:3 - Resolución (centrado)
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: widget.imagePath != null && _resolution != null
                          ? Text(
                              _resolution!,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.foreground,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                  // 4) Expanded flex:3 - Tamaño MB (alineado a la derecha, exactamente antes de Save)
                  Expanded(
                    flex: 3,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: widget.imagePath != null && _fileSize != null
                          ? Text(
                              _fileSize!,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.foreground,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                  // 5) Slot derecho fijo: Save icon (alineado al borde derecho)
                  SizedBox(
                    width: EditorTokens.kRightIconSlotW,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: EditorTokens.kContentHPad),
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
                  ),
                ],
              ),
            ),
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

  Widget _buildWhiteBar(EditorUiState uiState) {
    // Actualizar textos estructurados y de soporte
    _updateWhiteBarTexts(uiState);

    // Modo structured: usa el mismo ancho utilizable que la barra superior
    if (uiState.whiteBarMode == WhiteBarMode.structured && 
        uiState.structuredInfoText != null && 
        uiState.structuredInfoText!.isNotEmpty) {
      return Row(
        children: [
          // Slot izquierdo: respeta el inicio del texto del nombre (después de Home)
          SizedBox(width: EditorTokens.kLeftIconSlotW),
          // Contenido expandido (mismo espacio que el texto en la barra superior)
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _buildStructuredContent(uiState),
            ),
          ),
          // Slot derecho: respeta el fin antes de Save
          SizedBox(width: EditorTokens.kRightIconSlotW),
        ],
      );
    }

    // Modo support: usa el mismo ancho utilizable que la barra superior
    return Row(
      children: [
        // Slot izquierdo: respeta el inicio del texto del nombre (después de Home)
        SizedBox(width: EditorTokens.kLeftIconSlotW),
        // Contenido expandido (mismo espacio que el texto en la barra superior)
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: _buildSupportContent(uiState),
          ),
        ),
        // Slot derecho: respeta el fin antes de Save
        SizedBox(width: EditorTokens.kRightIconSlotW),
      ],
    );
  }

  void _updateWhiteBarTexts(EditorUiState uiState) {
    // Construir texto estructurado si hay selección
    final hasSelection = uiState.hasValidSelection;
    if (hasSelection) {
      final baseName = uiState.selectionVersionBaseName ?? 'imagen';
      final extension = uiState.originalFileExtension ?? '';
      final selectionDef = _getSelectionDefinition(uiState);
      final estimatedSize = _getEstimatedSize(uiState);

      final buffer = StringBuffer();
      buffer.write('Selección: $baseName$extension');
      if (selectionDef != null) {
        buffer.write(' · $selectionDef');
      }
      if (estimatedSize != null) {
        buffer.write(' · $estimatedSize');
      }

      uiState.setStructuredInfoText(buffer.toString());
    } else {
      uiState.setStructuredInfoText(null);
    }

    // Construir mensaje de soporte
    final statusMessage = uiState.statusMessage;
    if (statusMessage != null && statusMessage.isNotEmpty) {
      uiState.setSupportMessageText(statusMessage);
    } else {
      uiState.setSupportMessageText('Selecciona una herramienta para comenzar');
    }
  }

  Widget _buildStructuredContent(EditorUiState uiState) {
    final hasSelection = uiState.hasValidSelection;
    if (!hasSelection) {
      return const SizedBox.shrink();
    }

    final baseName = uiState.selectionVersionBaseName ?? 'imagen';
    final extension = uiState.originalFileExtension ?? '';
    final selectionDef = _getSelectionDefinition(uiState);
    final estimatedSize = _getEstimatedSize(uiState);

    return Row(
      children: [
        const Text(
          'Selección: ',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.accent,
          ),
        ),
        // Nombre editable inline
        _EditableNameField(
          baseName: baseName,
          extension: extension,
          onChanged: (newBaseName) {
            if (newBaseName.trim().isEmpty) {
              // Revertir si está vacío
              uiState.setSelectionVersionBaseName(baseName);
            } else {
              uiState.setSelectionVersionBaseName(newBaseName.trim());
            }
          },
        ),
        // Definición
        if (selectionDef != null) ...[
          const Text(
            ' · ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.accent,
            ),
          ),
          Text(
            selectionDef,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.accent,
            ),
          ),
        ],
        // Tamaño estimado
        if (estimatedSize != null) ...[
          const Text(
            ' · ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.accent,
            ),
          ),
          Text(
            estimatedSize,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.accent,
            ),
          ),
        ],
      ],
    );
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
    if (uiState.freeSelectionPath != null) {
      // Freehand: usar bounding box
      final bounds = uiState.freeSelectionPath!.getBounds();
      final width = bounds.width.toInt();
      final height = bounds.height.toInt();
      return '$width×$height px';
    }
    
    if (uiState.selectionGeometry != null) {
      final geometry = uiState.selectionGeometry!;
      if (geometry.shape == TransformableShape.circle) {
        // Circle: usar diámetro
        final diameter = geometry.size.width.toInt();
        return 'Ø $diameter px';
      } else {
        // Rect: W×H px
        final width = geometry.size.width.toInt();
        final height = geometry.size.height.toInt();
        return '$width×$height px';
      }
    }
    
    return null;
  }

  String? _getEstimatedSize(EditorUiState uiState) {
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
}

/// Widget para nombre editable inline
class _EditableNameField extends StatefulWidget {
  final String baseName;
  final String extension;
  final ValueChanged<String> onChanged;

  const _EditableNameField({
    required this.baseName,
    required this.extension,
    required this.onChanged,
  });

  @override
  State<_EditableNameField> createState() => _EditableNameFieldState();
}

class _EditableNameFieldState extends State<_EditableNameField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.baseName);
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isEditing) {
        _isEditing = false;
        widget.onChanged(_controller.text);
      }
    });
  }

  @override
  void didUpdateWidget(_EditableNameField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.baseName != oldWidget.baseName && !_isEditing) {
      _controller.text = widget.baseName;
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
            width: 120,
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
            widget.baseName,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.accent,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.accent,
            ),
          ),
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
