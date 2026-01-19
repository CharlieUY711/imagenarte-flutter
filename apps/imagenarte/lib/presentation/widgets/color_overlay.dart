import 'package:flutter/material.dart';
import 'package:imagenarte/app/theme/app_colors.dart';
import 'package:imagenarte/app/theme/app_spacing.dart';
import 'package:imagenarte/application/editor_ui_state.dart';
import 'package:imagenarte/presentation/widgets/editor_overlay_panel.dart';
import 'package:imagenarte/presentation/widgets/overlay_dial_row.dart';
import 'package:provider/provider.dart';

/// Overlay canónico para Color
/// Presets: Original, Grises, Sepia, B/N con dial de intensidad
class ColorOverlay extends StatelessWidget {
  const ColorOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EditorUiState>(
      builder: (context, uiState, child) {
        final isVisible = uiState.activeContext == EditorContext.colorPresets;
        
        return EditorOverlayPanel(
          visible: isVisible,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título obligatorio
              const Text(
                'Color',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Presets como botones toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildColorOption(
                    context: context,
                    label: 'Original',
                    mode: ColorMode.color,
                    uiState: uiState,
                  ),
                  _buildColorOption(
                    context: context,
                    label: 'Grises',
                    mode: ColorMode.grayscale,
                    uiState: uiState,
                  ),
                  _buildColorOption(
                    context: context,
                    label: 'Sepia',
                    mode: ColorMode.sepia,
                    uiState: uiState,
                  ),
                  _buildColorOption(
                    context: context,
                    label: 'B/N',
                    mode: ColorMode.blackAndWhite,
                    uiState: uiState,
                  ),
                ],
              ),
              // Dial de intensidad (visible solo para presets distintos de Original)
              if (uiState.colorMode != ColorMode.color) ...[
                const SizedBox(height: AppSpacing.md),
                OverlayDialRow(
                  label: 'Intensidad',
                  valueDouble: uiState.colorIntensity,
                  min: 0.0,
                  max: 100.0,
                  onChanged: (value) {
                    // Timer se reinicia automáticamente en OverlayDialRow
                    uiState.setColorIntensity(value);
                  },
                  onChangeEnd: (value) {
                    // Timer se reinicia automáticamente en OverlayDialRow
                    uiState.setColorIntensity(value);
                    uiState.pushUndo();
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildColorOption({
    required BuildContext context,
    required String label,
    required ColorMode mode,
    required EditorUiState uiState,
  }) {
    final isSelected = uiState.colorMode == mode;
    return InkWell(
      onTap: () {
        // REGLA UNIFICADA: Reiniciar timer de auto-cierre al interactuar
        uiState.resetToolAutoCloseTimer();
        uiState.setColorMode(mode);
        // Push undo al cambiar preset
        uiState.pushUndo();
      },
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isSelected ? AppColors.accent : AppColors.foreground,
        ),
      ),
    );
  }
}
