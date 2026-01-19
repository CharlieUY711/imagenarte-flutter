import 'package:flutter/material.dart';
import 'package:imagenarte/app/theme/app_colors.dart';
import 'package:imagenarte/application/editor_ui_state.dart';
import 'package:imagenarte/presentation/widgets/editor_overlay_panel.dart';
import 'package:provider/provider.dart';

/// Overlay canónico para selección geométrica
/// Muestra opciones de proporción: 9:16, 1:1, 16:9, 4:3, Circular
class GeometricSelectionOverlay extends StatelessWidget {
  const GeometricSelectionOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EditorUiState>(
      builder: (context, uiState, child) {
        // Visible cuando la herramienta de selección geométrica está activa
        final isVisible = uiState.activeContext == EditorContext.selectionRatios;
        
        return EditorOverlayPanel(
          visible: isVisible,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Opciones de proporción centradas y distribuidas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPresetOption(
                    context: context,
                    label: '9:16',
                    preset: CropPreset.p9_16,
                    uiState: uiState,
                  ),
                  _buildPresetOption(
                    context: context,
                    label: '1:1',
                    preset: CropPreset.p1_1,
                    uiState: uiState,
                  ),
                  _buildPresetOption(
                    context: context,
                    label: '16:9',
                    preset: CropPreset.p16_9,
                    uiState: uiState,
                  ),
                  _buildPresetOption(
                    context: context,
                    label: '4:3',
                    preset: CropPreset.p4_3,
                    uiState: uiState,
                  ),
                  _buildPresetOption(
                    context: context,
                    label: 'Circular',
                    preset: CropPreset.circular,
                    uiState: uiState,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPresetOption({
    required BuildContext context,
    required String label,
    required CropPreset preset,
    required EditorUiState uiState,
  }) {
    final isSelected = uiState.cropPreset == preset;
    return GestureDetector(
      onTap: () {
        // REGLA UNIFICADA: Reiniciar timer de auto-cierre al interactuar
        uiState.resetToolAutoCloseTimer();
        uiState.setCropPreset(preset);
        // Si ya hay una selección, actualizarla con el nuevo preset
        if (uiState.selectionGeometry != null) {
          final mediaQuery = MediaQuery.of(context);
          final canvasSize = mediaQuery.size;
          uiState.initializeGeometricSelection(canvasSize, null);
        }
      },
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isSelected ? AppColors.accent : AppColors.foreground,
        ),
      ),
    );
  }
}
