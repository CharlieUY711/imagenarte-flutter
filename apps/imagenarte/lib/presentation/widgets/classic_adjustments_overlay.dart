import 'package:flutter/material.dart';
import 'package:imagenarte/app/theme/app_spacing.dart';
import 'package:imagenarte/application/editor_ui_state.dart';
import 'package:imagenarte/presentation/widgets/editor_overlay_panel.dart';
import 'package:imagenarte/presentation/widgets/overlay_dial_row.dart';
import 'package:provider/provider.dart';

/// Overlay canónico para Ajustes clásicos
/// Muestra 4 sliders: Brillo, Contraste, Saturación, Nitidez
/// Preview en tiempo real durante drag, commit al soltar (onChangeEnd)
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
              // Brillo (-100..+100, default 0)
              OverlayDialRow(
                label: 'Brillo',
                valueDouble: uiState.brightness,
                min: -100.0,
                max: 100.0,
                onChanged: (value) {
                  // Preview en tiempo real (throttled)
                  uiState.setBrightness(value);
                },
                onChangeEnd: (value) {
                  // Commit al soltar
                  uiState.setBrightness(value);
                  uiState.commitClassicAdjustments();
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              // Contraste (-100..+100, default 0)
              OverlayDialRow(
                label: 'Contraste',
                valueDouble: uiState.contrast,
                min: -100.0,
                max: 100.0,
                onChanged: (value) {
                  // Preview en tiempo real (throttled)
                  uiState.setContrast(value);
                },
                onChangeEnd: (value) {
                  // Commit al soltar
                  uiState.setContrast(value);
                  uiState.commitClassicAdjustments();
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              // Saturación (-100..+100, default 0)
              OverlayDialRow(
                label: 'Saturación',
                valueDouble: uiState.saturation,
                min: -100.0,
                max: 100.0,
                onChanged: (value) {
                  // Preview en tiempo real (throttled)
                  uiState.setSaturation(value);
                },
                onChangeEnd: (value) {
                  // Commit al soltar
                  uiState.setSaturation(value);
                  uiState.commitClassicAdjustments();
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              // Nitidez (0..100, default 0)
              OverlayDialRow(
                label: 'Nitidez',
                valueDouble: uiState.sharpness,
                min: 0.0,
                max: 100.0,
                onChanged: (value) {
                  // Preview en tiempo real (throttled)
                  uiState.setSharpness(value);
                },
                onChangeEnd: (value) {
                  // Commit al soltar
                  uiState.setSharpness(value);
                  uiState.commitClassicAdjustments();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
