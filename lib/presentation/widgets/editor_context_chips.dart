import 'package:flutter/material.dart';
import 'package:imagenarte/app/theme/app_colors.dart';
import 'package:imagenarte/app/theme/app_spacing.dart';
import 'package:imagenarte/application/editor_ui_state.dart';
import 'package:imagenarte/presentation/widgets/editor_overlay_panel.dart';
import 'package:provider/provider.dart';

class EditorContextChips extends StatelessWidget {
  const EditorContextChips({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EditorUiState>(
      builder: (context, uiState, child) {
        // Solo mostrar chips cuando activeTool es crop o mask
        final isVisible = uiState.activeTool == EditorTool.geometricSelection ||
            uiState.activeTool == EditorTool.freeSelection;

        final isGeometricSelection = uiState.activeTool == EditorTool.geometricSelection;
        final title = isGeometricSelection ? 'Selección geométrica' : 'Selección libre';

        return EditorOverlayPanel(
          visible: isVisible,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Título
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.foreground,
                    ),
                  ),
                ),
                // Chips (solo para Selección geométrica)
                if (isGeometricSelection) ...[
                  _buildChip(
                    label: '9:16',
                    preset: CropPreset.p9_16,
                    uiState: uiState,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _buildChip(
                    label: '1:1',
                    preset: CropPreset.p1_1,
                    uiState: uiState,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _buildChip(
                    label: '16:9',
                    preset: CropPreset.p16_9,
                    uiState: uiState,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _buildChip(
                    label: '4:3',
                    preset: CropPreset.p4_3,
                    uiState: uiState,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _buildChip(
                    label: 'Circular',
                    preset: CropPreset.circular,
                    uiState: uiState,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChip({
    required String label,
    required CropPreset preset,
    required EditorUiState uiState,
  }) {
    final isSelected = uiState.cropPreset == preset;
    return GestureDetector(
      onTap: () {
        uiState.setCropPreset(preset);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected
                ? AppColors.accent
                : AppColors.foreground,
          ),
        ),
      ),
    );
  }
}
