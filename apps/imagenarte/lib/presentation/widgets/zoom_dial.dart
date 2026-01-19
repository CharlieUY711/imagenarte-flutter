import 'package:flutter/material.dart';
import 'package:imagenarte/app/theme/app_colors.dart';
import 'package:imagenarte/application/editor_ui_state.dart';
import 'package:imagenarte/presentation/widgets/editor_overlay_panel.dart';
import 'package:provider/provider.dart';

/// Panel overlay para zoom con dial horizontal
/// Muestra slider de -1.0 a +1.0, centrado en 0
class ZoomDial extends StatelessWidget {
  const ZoomDial({super.key});

  String _formatZoomPercentage(double scale) {
    return '${(scale * 100).round()}%';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EditorUiState>(
      builder: (context, uiState, child) {
        final isVisible = uiState.activeContext == EditorContext.zoom;

        return EditorOverlayPanel(
          visible: isVisible,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: label izquierda naranja + value derecha porcentaje
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Zoom',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        _formatZoomPercentage(uiState.zoomScale),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.foreground.withAlpha(179),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Botón reset
                      GestureDetector(
                        onTap: () => uiState.onZoomReset(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: const Text(
                            'Reset',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Slider que ocupa todo el ancho
              Slider(
                value: uiState.zoomT,
                min: -1.0,
                max: 1.0,
                onChanged: (value) => uiState.onZoomChanged(value),
                activeColor: AppColors.accent,
                inactiveColor: AppColors.foreground.withAlpha(51),
                thumbColor: AppColors.accent,
              ),
            ],
          ),
        );
      },
    );
  }
}
