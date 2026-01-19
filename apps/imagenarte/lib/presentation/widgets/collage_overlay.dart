import 'package:flutter/material.dart';
import 'package:imagenarte/app/theme/app_colors.dart';
import 'package:imagenarte/app/theme/app_spacing.dart';
import 'package:imagenarte/application/editor_ui_state.dart';
import 'package:imagenarte/domain/collage_config.dart';
import 'package:imagenarte/presentation/widgets/editor_overlay_panel.dart';
import 'package:provider/provider.dart';

/// Overlay de configuración de collage
class CollageOverlay extends StatelessWidget {
  const CollageOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EditorUiState>(
      builder: (context, uiState, child) {
        return EditorOverlayPanel(
          visible: uiState.activeContext == EditorContext.collage,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Título
              Text(
                'Collage',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.foreground,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // Selector de layout
              Text(
                'Layout: ${uiState.collageConfig.rows}×${uiState.collageConfig.cols}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.foreground,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Por ahora solo Grid 4x3, pero preparado para futuros layouts
              _buildLayoutOption(
                context: context,
                uiState: uiState,
                rows: 4,
                cols: 3,
                label: 'Grid 4×3',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLayoutOption({
    required BuildContext context,
    required EditorUiState uiState,
    required int rows,
    required int cols,
    required String label,
  }) {
    final isSelected = uiState.collageConfig.rows == rows && 
                       uiState.collageConfig.cols == cols;
    
    return GestureDetector(
      onTap: () {
        // REGLA UNIFICADA: Reiniciar timer de auto-cierre al interactuar
        uiState.resetToolAutoCloseTimer();
        uiState.setCollageConfig(
          CollageConfig(
            layoutType: CollageLayoutType.grid,
            rows: rows,
            cols: cols,
            spacing: uiState.collageConfig.spacing,
            padding: uiState.collageConfig.padding,
            backgroundColor: uiState.collageConfig.backgroundColor,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withAlpha(51)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected
                ? AppColors.accent
                : AppColors.foreground.withAlpha(51),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? AppColors.accent : AppColors.foreground,
          ),
        ),
      ),
    );
  }
}
