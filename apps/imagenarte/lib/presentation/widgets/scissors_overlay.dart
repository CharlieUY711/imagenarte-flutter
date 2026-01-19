import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:imagenarte/app/theme/app_colors.dart';
import 'package:imagenarte/app/theme/app_spacing.dart';
import 'package:imagenarte/application/editor_ui_state.dart';
import 'package:imagenarte/infrastructure/file_versioning.dart';
import 'package:imagenarte/infrastructure/image_render_pipeline.dart';
import 'package:imagenarte/infrastructure/imaging/image_export_helper.dart';
import 'package:imagenarte/presentation/screens/editor_screen.dart';
import 'package:imagenarte/presentation/widgets/editor_overlay_panel.dart';
import 'package:provider/provider.dart';

/// Overlay canónico para Tijera
/// Muestra opciones: Interior / Exterior
class ScissorsOverlay extends StatelessWidget {
  final String? imagePath;
  
  const ScissorsOverlay({
    super.key,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<EditorUiState>(
      builder: (context, uiState, child) {
        return EditorOverlayPanel(
          visible: uiState.activeContext == EditorContext.scissors,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Título
              Text(
                'Tijera',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.foreground,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '¿Interior o Exterior?',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.foreground,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Opciones centradas y distribuidas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOption(
                    context: context,
                    label: 'Interior',
                    onTap: () => _handleScissorsChoice(context, uiState, true),
                  ),
                  _buildOption(
                    context: context,
                    label: 'Exterior',
                    onTap: () => _handleScissorsChoice(context, uiState, false),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required String label,
    required VoidCallback onTap,
  }) {
    return Consumer<EditorUiState>(
      builder: (context, uiState, child) {
        return GestureDetector(
          onTap: () {
            // REGLA UNIFICADA: Reiniciar timer de auto-cierre al interactuar
            uiState.resetToolAutoCloseTimer();
            onTap();
          },
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.accent,
            ),
          ),
        );
      },
    );
  }

  /// Ejecuta el corte inmediatamente usando el pipeline unificado
  static Future<void> executeCrop({
    required BuildContext context,
    required EditorUiState uiState,
    required String imagePath,
    required Size canvasSize,
    required Size imageSize,
  }) async {
    if (!uiState.hasValidSelection) {
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

    try {
      // Guardar snapshot para undo antes de aplicar corte
      uiState.pushUndo();

      // Usar el pipeline unificado para renderizar el corte
      final croppedImage = await ImageRenderPipeline.renderCrop(
        imagePath: imagePath,
        selectionGeometry: uiState.selectionGeometry,
        freehandPathImage: uiState.freehandPathImage,
        isInterior: !uiState.selectionInverted,
        canvasSize: canvasSize,
        imageSize: imageSize,
      );

      // Convertir ui.Image a bytes
      final byteData = await croppedImage.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Error al convertir imagen a bytes');
      }

      final imageBytes = byteData.buffer.asUint8List();

      // Generar nombre versionado
      final newPath = await FileVersioning.buildVersionedName(imagePath);

      // Guardar imagen con opción de eliminar metadatos
      await ImageExportHelper.exportImageBytes(
        imageBytes: imageBytes,
        outputPath: newPath,
        removeMetadata: uiState.metadataRemovalEnabled,
        quality: 95,
      );

      // Limpiar selección y volver a estado neutro
      uiState.updateSelectionGeometry(null);
      uiState.clearFreehand();
      uiState.setActiveTool(EditorTool.none);
      uiState.setContext(EditorContext.none);

      // Navegar al nuevo archivo
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
      uiState.setContext(EditorContext.none);
    }
  }

  Future<void> _handleScissorsChoice(BuildContext context, EditorUiState uiState, bool isInterior) async {
    // Cambiar configuración interior/exterior
    if (isInterior != !uiState.selectionInverted) {
      uiState.toggleSelectionInverted();
    }
    
    // Ejecutar corte inmediatamente
    if (imagePath == null || !uiState.hasValidSelection) {
      uiState.setContext(EditorContext.none);
      return;
    }

    // Obtener canvasSize e imageSize del estado
    final canvasSize = uiState.canvasSize ?? const Size(400, 400);
    
    // Cargar tamaño de imagen
    Size? imageSize;
    try {
      final file = File(imagePath!);
      final imageBytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(imageBytes);
      final frame = await codec.getNextFrame();
      imageSize = Size(frame.image.width.toDouble(), frame.image.height.toDouble());
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cargar imagen'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
      uiState.setContext(EditorContext.none);
      return;
    }

    await executeCrop(
      context: context,
      uiState: uiState,
      imagePath: imagePath!,
      canvasSize: canvasSize,
      imageSize: imageSize,
    );
  }
}
