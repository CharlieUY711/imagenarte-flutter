import 'package:flutter/material.dart';
import 'package:imagenarte/app/theme/app_colors.dart';
import 'package:imagenarte/app/theme/app_spacing.dart';
import 'package:imagenarte/application/editor_ui_state.dart';
import 'package:imagenarte/presentation/widgets/editor_overlay_panel.dart';
import 'package:imagenarte/presentation/widgets/overlay_dial_row.dart';
import 'package:provider/provider.dart';

/// Panel overlay para opciones de watermark
/// 
/// Muestra slider de opacidad (ajuste variable) y toggle de visible (booleano).
/// La transformación se hace en el canvas con TransformTool.
class WatermarkOverlayPanel extends StatelessWidget {
  const WatermarkOverlayPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EditorUiState>(
      builder: (context, uiState, child) {
        final isVisible = uiState.activeContext == EditorContext.action_watermark;

        return EditorOverlayPanel(
          visible: isVisible,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Slider de opacidad (ajuste variable)
              OverlayDialRow(
                label: 'Opacidad',
                valueDouble: uiState.watermarkOpacity,
                min: 0.0,
                max: 100.0,
                onChanged: (value) => uiState.setWatermarkOpacity(value),
                onChangeEnd: (value) {
                  uiState.setWatermarkOpacity(value);
                  uiState.pushUndo();
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              // Toggle de visible (booleano, no es ajuste variable)
              _buildToggle(
                label: 'Visible',
                value: uiState.watermarkVisible,
                onChanged: (value) {
                  uiState.setWatermarkVisible(value);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToggle({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: value
              ? AppColors.accent
              : AppColors.foreground.withAlpha(26),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: value
                    ? AppColors.foreground
                    : AppColors.foreground.withAlpha(179),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(
              value ? Icons.check : Icons.close,
              size: 14,
              color: value
                  ? AppColors.foreground
                  : AppColors.foreground.withAlpha(179),
            ),
          ],
        ),
      ),
    );
  }
}
