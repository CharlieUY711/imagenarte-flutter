import 'package:flutter/material.dart';
import 'package:imagenarte/app/theme/app_colors.dart';
import 'package:imagenarte/application/editor_ui_state.dart';
import 'package:imagenarte/presentation/widgets/editor_overlay_panel.dart';
import 'package:provider/provider.dart';

/// Overlay canónico para Color
/// Opciones texto-only: Color, Grises, Sepia, B&N
class ColorOverlay extends StatelessWidget {
  const ColorOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EditorUiState>(
      builder: (context, uiState, child) {
        final isVisible = uiState.activeContext == EditorContext.colorPresets;
        
        return EditorOverlayPanel(
          visible: isVisible,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildColorOption(
                context: context,
                label: 'Color',
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
                label: 'B&N',
                mode: ColorMode.blackAndWhite,
                uiState: uiState,
              ),
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
    return GestureDetector(
      onTap: () {
        uiState.setColorMode(mode);
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
