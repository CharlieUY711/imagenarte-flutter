import 'package:flutter/material.dart';
import 'package:imagenarte/application/editor_ui_state.dart';
import 'package:imagenarte/presentation/widgets/geometric_selection_overlay.dart';
import 'package:imagenarte/presentation/widgets/color_overlay.dart';
import 'package:imagenarte/presentation/widgets/classic_adjustments_overlay.dart';
import 'package:imagenarte/presentation/widgets/scissors_overlay.dart';
import 'package:imagenarte/presentation/widgets/blur_overlay_panel.dart';
import 'package:imagenarte/presentation/widgets/pixelate_overlay_panel.dart';
import 'package:imagenarte/presentation/widgets/watermark_overlay_panel.dart';
import 'package:imagenarte/presentation/widgets/metadata_overlay.dart';
import 'package:provider/provider.dart';

/// Router único de overlays (SINGLE SOURCE OF TRUTH)
/// Devuelve EXACTAMENTE 0 o 1 panel según activeContext
class EditorOverlayRouter extends StatelessWidget {
  final String? imagePath;
  
  const EditorOverlayRouter({
    super.key,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<EditorUiState>(
      builder: (context, uiState, child) {
        final ctx = uiState.activeContext;
        
        // Switch único: solo un overlay puede estar visible
        switch (ctx) {
          case EditorContext.selectionRatios:
            return const GeometricSelectionOverlay();
          case EditorContext.freeSelection:
            // Por ahora no hay overlay para selección libre
            return const SizedBox.shrink();
          case EditorContext.scissors:
            return ScissorsOverlay(imagePath: imagePath);
          case EditorContext.colorPresets:
            return const ColorOverlay();
          case EditorContext.classicAdjustments:
            return const ClassicAdjustmentsOverlay();
          case EditorContext.action_blur:
            return const BlurOverlayPanel();
          case EditorContext.action_pixelate:
            return const PixelateOverlayPanel();
          case EditorContext.action_watermark:
            return const WatermarkOverlayPanel();
          case EditorContext.action_metadata:
            return const MetadataOverlay();
          case EditorContext.none:
            return const SizedBox.shrink();
        }
      },
    );
  }
}
