import 'package:flutter/material.dart';
import 'package:imagenarte/app/theme/app_colors.dart';
import 'package:imagenarte/app/theme/app_spacing.dart';
import 'package:imagenarte/application/editor_ui_state.dart';
import 'package:imagenarte/presentation/widgets/editor_overlay_panel.dart';
import 'package:provider/provider.dart';

/// Overlay canónico para Metadatos
/// Muestra opción: Sí / No
class MetadataOverlay extends StatelessWidget {
  const MetadataOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EditorUiState>(
      builder: (context, uiState, child) {
        return EditorOverlayPanel(
          visible: uiState.activeContext == EditorContext.action_metadata,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Título
              Text(
                'Metadatos',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.foreground,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Opciones centradas y distribuidas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOption(
                    context: context,
                    label: 'Sí',
                    isSelected: true, // TODO: Implementar estado real
                    onTap: () {
                      // TODO: Implementar lógica de metadatos
                      uiState.setContext(EditorContext.none);
                    },
                  ),
                  _buildOption(
                    context: context,
                    label: 'No',
                    isSelected: false, // TODO: Implementar estado real
                    onTap: () {
                      // TODO: Implementar lógica de metadatos
                      uiState.setContext(EditorContext.none);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
