import 'package:flutter/material.dart';
import 'package:imagenarte/application/editor_ui_state.dart';
import 'package:imagenarte/presentation/widgets/editor_overlay_panel.dart';
import 'package:imagenarte/presentation/widgets/overlay_dial_row.dart';
import 'package:provider/provider.dart';

/// Panel overlay para blur con slider de intensidad
class BlurOverlayPanel extends StatelessWidget {
  const BlurOverlayPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EditorUiState>(
      builder: (context, uiState, child) {
        final isVisible = uiState.activeContext == EditorContext.action_blur;

        return EditorOverlayPanel(
          visible: isVisible,
          child: OverlayDialRow(
            label: 'Intensidad',
            valueDouble: uiState.blurIntensity,
            min: 0.0,
            max: 100.0,
            onChanged: (value) => uiState.setBlurIntensity(value),
            onChangeEnd: (value) {
              uiState.setBlurIntensity(value);
              uiState.pushUndo();
            },
          ),
        );
      },
    );
  }
}
