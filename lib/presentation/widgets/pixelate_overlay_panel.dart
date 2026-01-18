import 'package:flutter/material.dart';
import 'package:imagenarte/application/editor_ui_state.dart';
import 'package:imagenarte/presentation/widgets/editor_overlay_panel.dart';
import 'package:imagenarte/presentation/widgets/overlay_dial_row.dart';
import 'package:provider/provider.dart';

/// Panel overlay para pixelate con slider de intensidad
class PixelateOverlayPanel extends StatelessWidget {
  const PixelateOverlayPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EditorUiState>(
      builder: (context, uiState, child) {
        final isVisible = uiState.activeContext == EditorContext.action_pixelate;

        return EditorOverlayPanel(
          visible: isVisible,
          child: OverlayDialRow(
            label: 'Intensidad',
            valueDouble: uiState.pixelateIntensity,
            min: 0.0,
            max: 100.0,
            onChanged: (value) => uiState.setPixelateIntensity(value),
            onChangeEnd: (value) {
              uiState.setPixelateIntensity(value);
              uiState.pushUndo();
            },
          ),
        );
      },
    );
  }
}
