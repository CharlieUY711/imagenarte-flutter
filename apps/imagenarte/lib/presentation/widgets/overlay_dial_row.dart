import 'package:flutter/material.dart';
import 'package:imagenarte/app/theme/app_colors.dart';
import 'package:imagenarte/application/editor_ui_state.dart';
import 'package:provider/provider.dart';

/// Componente canónico para ajustes con dial/slider en el overlay panel
/// 
/// Formato genérico y reutilizable:
/// - Header: Text(label) izquierda naranja + Text(value) derecha porcentaje
/// - Slider debajo que ocupa todo el ancho
/// - Track activo naranja, inactivo gris
/// - Thumb naranja
/// 
/// REGLA UNIFICADA: Reinicia automáticamente el timer de auto-cierre en todas las interacciones
/// No hardcodea nombres de herramientas; es genérico.
class OverlayDialRow extends StatelessWidget {
  final String label;
  final double valueDouble;
  final double min;
  final double max;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeEnd;

  const OverlayDialRow({
    super.key,
    required this.label,
    required this.valueDouble,
    required this.min,
    required this.max,
    this.onChanged,
    this.onChangeEnd,
  });

  String _formatPercentage(double value) {
    final rounded = value.round();
    // Mostrar con signo + para valores positivos, sin signo para 0, con - para negativos
    if (rounded > 0) {
      return '+$rounded';
    } else if (rounded < 0) {
      return '$rounded';
    } else {
      return '0';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: label izquierda naranja + value derecha porcentaje
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
            Text(
              _formatPercentage(valueDouble),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.foreground.withAlpha(179),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Slider que ocupa todo el ancho
        // REGLA UNIFICADA: Reinicia timer de auto-cierre en todas las interacciones
        Consumer<EditorUiState>(
          builder: (context, uiState, child) {
            return Slider(
              value: valueDouble,
              min: min,
              max: max,
              onChanged: onChanged != null
                  ? (value) {
                      // Reiniciar timer de auto-cierre al interactuar
                      uiState.resetToolAutoCloseTimer();
                      onChanged!(value);
                    }
                  : null,
              onChangeEnd: onChangeEnd != null
                  ? (value) {
                      // Reiniciar timer de auto-cierre al terminar interacción
                      uiState.resetToolAutoCloseTimer();
                      onChangeEnd!(value);
                    }
                  : null,
              activeColor: AppColors.accent,
              inactiveColor: AppColors.foreground.withAlpha(51),
              thumbColor: AppColors.accent,
            );
          },
        ),
      ],
    );
  }
}
