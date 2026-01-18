import 'package:flutter/material.dart';
import 'package:imagenarte/app/theme/app_spacing.dart';
import 'package:imagenarte/application/editor_ui_state.dart';
import 'package:imagenarte/presentation/widgets/editor_overlay_panel.dart';
import 'package:imagenarte/presentation/widgets/overlay_dial_row.dart';
import 'package:provider/provider.dart';

/// Overlay canónico para Ajustes clásicos
/// Dial canónico: Brillo, Contraste, Saturación, Nitidez
class ClassicAdjustmentsOverlay extends StatelessWidget {
  const ClassicAdjustmentsOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EditorUiState>(
      builder: (context, uiState, child) {
        final isVisible = uiState.activeContext == EditorContext.classicAdjustments;
        
        return EditorOverlayPanel(
          visible: isVisible,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Brillo
              OverlayDialRow(
                label: 'Brillo',
                valueDouble: uiState.brightness,
                min: -100.0,
                max: 100.0,
                onChanged: (value) {
                  uiState.setBrightness(value);
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              // Contraste
              OverlayDialRow(
                label: 'Contraste',
                valueDouble: uiState.contrast,
                min: -100.0,
                max: 100.0,
                onChanged: (value) {
                  uiState.setContrast(value);
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              // Saturación
              OverlayDialRow(
                label: 'Saturación',
                valueDouble: uiState.saturation,
                min: -100.0,
                max: 100.0,
                onChanged: (value) {
                  uiState.setSaturation(value);
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              // Nitidez
              OverlayDialRow(
                label: 'Nitidez',
                valueDouble: uiState.sharpness,
                min: -100.0,
                max: 100.0,
                onChanged: (value) {
                  uiState.setSharpness(value);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
