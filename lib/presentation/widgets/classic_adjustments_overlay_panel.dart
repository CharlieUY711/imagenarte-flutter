import 'package:flutter/material.dart';
import 'package:imagenarte/app/theme/app_colors.dart';
import 'package:imagenarte/app/theme/app_spacing.dart';
import 'package:imagenarte/application/editor_ui_state.dart';
import 'package:imagenarte/presentation/widgets/editor_overlay_panel.dart';
import 'package:imagenarte/presentation/widgets/overlay_dial_row.dart';
import 'package:provider/provider.dart';

/// Panel overlay para ajustes clásicos (Brillo, Contraste, Saturación, Nitidez)
/// 
/// Usa selector de ajustes (texto + ícono) y dial canónico para el ajuste activo.
class ClassicAdjustmentsOverlayPanel extends StatelessWidget {
  const ClassicAdjustmentsOverlayPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EditorUiState>(
      builder: (context, uiState, child) {
        final isVisible = uiState.activeTool == EditorTool.classicAdjustments;

        if (!isVisible) {
          return const SizedBox.shrink();
        }

        return EditorOverlayPanel(
          visible: isVisible,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selector de ajustes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAdjustmentSelector(
                    label: 'Brillo',
                    icon: Icons.brightness_6,
                    adjustment: ClassicAdjustment.brightness,
                    uiState: uiState,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _buildAdjustmentSelector(
                    label: 'Contraste',
                    icon: Icons.contrast,
                    adjustment: ClassicAdjustment.contrast,
                    uiState: uiState,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _buildAdjustmentSelector(
                    label: 'Saturación',
                    icon: Icons.palette,
                    adjustment: ClassicAdjustment.saturation,
                    uiState: uiState,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _buildAdjustmentSelector(
                    label: 'Nitidez',
                    icon: Icons.auto_fix_high,
                    adjustment: ClassicAdjustment.sharpness,
                    uiState: uiState,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              // Dial canónico para el ajuste activo
              if (uiState.activeClassicAdjustment != null)
                _buildActiveDial(uiState),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdjustmentSelector({
    required String label,
    required IconData icon,
    required ClassicAdjustment adjustment,
    required EditorUiState uiState,
  }) {
    final isActive = uiState.activeClassicAdjustment == adjustment;
    
    return InkWell(
      onTap: () {
        if (isActive) {
          // Si ya está activo, desactivarlo
          uiState.setActiveClassicAdjustment(null);
        } else {
          // Activar este ajuste
          uiState.setActiveClassicAdjustment(adjustment);
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isActive ? AppColors.accent : AppColors.foreground,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isActive ? AppColors.accent : AppColors.foreground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveDial(EditorUiState uiState) {
    final adjustment = uiState.activeClassicAdjustment!;
    
    String label;
    double value;
    ValueChanged<double> onChanged;
    ValueChanged<double>? onChangeEnd;
    
    switch (adjustment) {
      case ClassicAdjustment.brightness:
        label = 'Brillo';
        value = uiState.brightness;
        onChanged = (v) => uiState.setBrightness(v);
        onChangeEnd = (v) {
          uiState.setBrightness(v);
          uiState.pushUndo();
        };
        break;
      case ClassicAdjustment.contrast:
        label = 'Contraste';
        value = uiState.contrast;
        onChanged = (v) => uiState.setContrast(v);
        onChangeEnd = (v) {
          uiState.setContrast(v);
          uiState.pushUndo();
        };
        break;
      case ClassicAdjustment.saturation:
        label = 'Saturación';
        value = uiState.saturation;
        onChanged = (v) => uiState.setSaturation(v);
        onChangeEnd = (v) {
          uiState.setSaturation(v);
          uiState.pushUndo();
        };
        break;
      case ClassicAdjustment.sharpness:
        label = 'Nitidez';
        value = uiState.sharpness;
        onChanged = (v) => uiState.setSharpness(v);
        onChangeEnd = (v) {
          uiState.setSharpness(v);
          uiState.pushUndo();
        };
        break;
    }
    
    return OverlayDialRow(
      label: label,
      valueDouble: value,
      min: 0.0,
      max: 100.0,
      onChanged: onChanged,
      onChangeEnd: onChangeEnd,
    );
  }
}
