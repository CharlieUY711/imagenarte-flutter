import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:imagenarte/application/editor_ui_state.dart';
import 'package:imagenarte/domain/transformable_geometry.dart';
import 'package:imagenarte/app/theme/app_colors.dart';

/// Overlay que aplica blur visualmente solo dentro del ROI
/// 
/// Usa BackdropFilter con ImageFilter.blur para aplicar el efecto
/// de forma no destructiva y en tiempo real.
class BlurEffectOverlay extends StatelessWidget {
  final EditorUiState uiState;
  final Size canvasSize;

  const BlurEffectOverlay({
    super.key,
    required this.uiState,
    required this.canvasSize,
  });

  @override
  Widget build(BuildContext context) {
    // Solo mostrar si blur está activo y hay selección válida
    if (uiState.activeTool != EditorTool.blur || !uiState.hasValidSelection) {
      return const SizedBox.shrink();
    }

    // Si la intensidad es 0, no mostrar blur
    if (uiState.blurIntensity <= 0.0) {
      return const SizedBox.shrink();
    }

    // Calcular sigma de blur (mapear 0-100 a 0-20)
    final blurSigma = (uiState.blurIntensity / 100.0) * 20.0;

    // Determinar qué path usar para el clip
    Path? clipPath;
    if (uiState.freehandPathCanvas != null) {
      // Usar path de selección libre
      clipPath = uiState.freehandPathCanvas;
    } else if (uiState.selectionGeometry != null) {
      // Crear path desde geometría
      clipPath = _createPathFromGeometry(uiState.selectionGeometry!);
    }

    if (clipPath == null) {
      return const SizedBox.shrink();
    }

    // Aplicar blur solo dentro del ROI usando ClipPath y BackdropFilter
    // BackdropFilter aplica blur a todo lo que está detrás, así que lo usamos
    // dentro de un ClipPath para limitar el área de blur
    return IgnorePointer(
      ignoring: true, // No bloquear interacciones
      child: ClipPath(
        clipper: _RoiPathClipper(clipPath),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            // Container necesario para BackdropFilter
            // El color transparente permite ver el blur de lo que está detrás
            color: Colors.transparent,
          ),
        ),
      ),
    );
  }

  /// Crea un Path desde la geometría de selección
  Path _createPathFromGeometry(TransformableGeometry geometry) {
    Path path = Path();
    
    if (geometry.shape == TransformableShape.circle) {
      final radius = math.min(geometry.size.width, geometry.size.height) / 2;
      path.addOval(Rect.fromCircle(
        center: geometry.center,
        radius: radius,
      ));
    } else {
      // Rectángulo (incluye rotación si existe)
      if (geometry.rotation != 0) {
        // Aplicar transformación de rotación
        path.addRect(geometry.boundingBox);
        final matrix = Matrix4.identity()
          ..translate(geometry.center.dx, geometry.center.dy)
          ..rotateZ(geometry.rotation)
          ..translate(-geometry.center.dx, -geometry.center.dy);
        path = path.transform(matrix.storage);
      } else {
        path.addRect(geometry.boundingBox);
      }
    }
    
    return path;
  }
}

/// Clipper personalizado para el path del ROI
class _RoiPathClipper extends CustomClipper<Path> {
  final Path roiPath;

  _RoiPathClipper(this.roiPath);

  @override
  Path getClip(Size size) {
    return roiPath;
  }

  @override
  bool shouldReclip(_RoiPathClipper oldClipper) {
    return roiPath != oldClipper.roiPath;
  }
}
