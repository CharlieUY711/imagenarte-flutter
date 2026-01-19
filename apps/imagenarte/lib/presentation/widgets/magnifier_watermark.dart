import 'package:flutter/material.dart';
import 'package:imagenarte/app/theme/app_colors.dart';
import 'package:imagenarte/application/editor_ui_state.dart';
import 'package:provider/provider.dart';

/// Lupa como marca de agua interactiva en la esquina superior izquierda
/// Al tocarla, activa el modo zoom
class MagnifierWatermark extends StatelessWidget {
  const MagnifierWatermark({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EditorUiState>(
      builder: (context, uiState, child) {
        return Positioned(
          left: 10.0,
          top: 10.0,
          child: GestureDetector(
            onTap: () {
              // Re-tap = reset completo del zoom + dial centrado
              // onMagnifierTap() ya hace esto (resetea a 0 y activa)
              uiState.onMagnifierTap();
            },
            child: Icon(
              Icons.zoom_in,
              color: AppColors.foreground.withOpacity(0.6),
              size: 22.0,
            ),
          ),
        );
      },
    );
  }
}
