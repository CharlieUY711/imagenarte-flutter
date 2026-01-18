import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:imagenarte/app/theme/app_colors.dart';
import 'package:imagenarte/app/theme/app_spacing.dart';
import 'package:imagenarte/application/editor_ui_state.dart';
import 'package:imagenarte/domain/transformable_geometry.dart';
import 'package:imagenarte/infrastructure/file_versioning.dart';
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
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.accent,
        ),
      ),
    );
  }

  Future<void> _handleScissorsChoice(BuildContext context, EditorUiState uiState, bool isInterior) async {
    if (imagePath == null || !uiState.hasValidSelection) {
      uiState.setContext(EditorContext.none);
      return;
    }

    try {
      // Leer imagen original
      final originalFile = File(imagePath!);
      final imageBytes = await originalFile.readAsBytes();
      final originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        uiState.setContext(EditorContext.none);
        return;
      }

      // Obtener geometría de selección
      final geometry = uiState.selectionGeometry;
      
      if (geometry == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Selección libre aún no implementada para tijera'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
        uiState.setContext(EditorContext.none);
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
                final ext = imagePath!.toLowerCase();
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
          final ext = imagePath!.toLowerCase();
          
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
      final newPath = await FileVersioning.buildVersionedName(imagePath!);
      
      // Guardar imagen
      final ext = imagePath!.toLowerCase();
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

      // Cerrar overlay y volver a selectionRatios
      // setActiveTool ya establece el contexto correcto, no necesitamos setContext aquí
      uiState.setActiveTool(EditorTool.geometricSelection);

      // Actualizar estado y navegar al nuevo archivo
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
}
