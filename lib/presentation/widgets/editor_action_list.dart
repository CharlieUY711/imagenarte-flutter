import 'package:flutter/material.dart';
import 'package:imagenarte/app/theme/app_colors.dart';
import 'package:imagenarte/app/theme/app_spacing.dart';
import 'package:imagenarte/app/theme/app_radius.dart';
import 'package:imagenarte/application/editor_ui_state.dart';
import 'package:imagenarte/presentation/theme/editor_tokens.dart';
import 'package:provider/provider.dart';

class EditorActionList extends StatelessWidget {
  final String? imagePath;

  const EditorActionList({
    super.key,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<EditorUiState>(
      builder: (context, uiState, child) {
        final activeAction = uiState.activeAction;
        
        // Estado B: Modo foco - mostrar solo la acción activa
        if (activeAction != null) {
          return Container(
            padding: const EdgeInsets.only(
              top: EditorTokens.kToolbarToContentGap,
              left: AppSpacing.md,
              right: AppSpacing.md,
              bottom: AppSpacing.md,
            ),
            color: AppColors.background,
            child: _buildActionButton(
              context: context,
              label: _getActionLabel(activeAction),
              icon: _getActionIcon(activeAction),
              tool: activeAction,
              uiState: uiState,
              isFocused: true,
            ),
          );
        }
        
        // Estado A: Modo reposo - mostrar lista completa
        return Container(
          padding: const EdgeInsets.only(
            top: EditorTokens.kToolbarToContentGap,
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: AppSpacing.md,
          ),
          color: AppColors.background,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Blur
              _buildActionButton(
                context: context,
                label: 'Blur',
                icon: Icons.blur_on,
                tool: EditorTool.blur,
                uiState: uiState,
                isFocused: false,
              ),
              const SizedBox(height: AppSpacing.sm),
              // Pixelado
              _buildActionButton(
                context: context,
                label: 'Pixelado',
                icon: Icons.grid_off,
                tool: EditorTool.pixelate,
                uiState: uiState,
                isFocused: false,
              ),
              const SizedBox(height: AppSpacing.sm),
              // Marca de agua
              _buildActionButton(
                context: context,
                label: 'Marca de agua',
                icon: Icons.water_drop,
                tool: EditorTool.watermark,
                uiState: uiState,
                isFocused: false,
              ),
              const SizedBox(height: AppSpacing.sm),
              // Metadatos
              _buildActionButton(
                context: context,
                label: 'Metadatos',
                icon: Icons.info_outline,
                tool: EditorTool.metadata,
                uiState: uiState,
                isFocused: false,
              ),
            ],
          ),
        );
      },
    );
  }
  
  String _getActionLabel(EditorTool tool) {
    switch (tool) {
      case EditorTool.blur:
        return 'Blur';
      case EditorTool.pixelate:
        return 'Pixelado';
      case EditorTool.watermark:
        return 'Marca de agua';
      case EditorTool.metadata:
        return 'Metadatos';
      default:
        return '';
    }
  }
  
  IconData _getActionIcon(EditorTool tool) {
    switch (tool) {
      case EditorTool.blur:
        return Icons.blur_on;
      case EditorTool.pixelate:
        return Icons.grid_off;
      case EditorTool.watermark:
        return Icons.water_drop;
      case EditorTool.metadata:
        return Icons.info_outline;
      default:
        return Icons.help_outline;
    }
  }

  // Métodos de tijera movidos a EditorOrangeToolbar

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required EditorTool tool,
    required EditorUiState uiState,
    required bool isFocused,
  }) {
    // En modo foco, la acción activa siempre está activa y con estilo naranja
    final isActive = isFocused || uiState.activeAction == tool;
    
    return InkWell(
      onTap: () {
        uiState.toggleTool(tool);
      },
      child: Container(
        width: double.infinity,
        height: EditorTokens.kActionButtonHeight,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isFocused
              ? AppColors.accent.withAlpha(51)
              : isActive
                  ? AppColors.accent.withAlpha(51)
                  : AppColors.foreground.withAlpha(13),
          borderRadius: const BorderRadius.all(AppRadius.md),
          border: isFocused
              ? Border.all(
                  color: AppColors.accent,
                  width: 1,
                )
              : isActive
                  ? Border.all(
                      color: AppColors.accent,
                      width: 1,
                    )
                  : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isFocused
                  ? AppColors.accent
                  : isActive
                      ? AppColors.accent
                      : AppColors.foreground.withAlpha(179),
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isFocused
                      ? AppColors.accent
                      : isActive
                          ? AppColors.accent
                          : AppColors.foreground.withAlpha(179),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
