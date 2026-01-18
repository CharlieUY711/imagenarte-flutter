import 'package:flutter/material.dart';
import 'package:imagenarte/app/theme/app_colors.dart';

/// Componente canónico para ajustes con dial/slider en el overlay panel
/// 
/// Formato genérico y reutilizable:
/// - Header: Text(label) izquierda naranja + Text(value) derecha porcentaje
/// - Slider debajo que ocupa todo el ancho
/// - Track activo naranja, inactivo gris
/// - Thumb naranja
/// 
/// No hardcodea nombres de herramientas; es genérico.
class OverlayDialRow extends StatelessWidget {
  final String label;
  final double valueDouble;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeEnd;

  const OverlayDialRow({
    super.key,
    required this.label,
    required this.valueDouble,
    required this.min,
    required this.max,
    required this.onChanged,
    this.onChangeEnd,
  });

  String _formatPercentage(double value) {
    return '${value.round()}%';
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
        Slider(
          value: valueDouble,
          min: min,
          max: max,
          onChanged: onChanged,
          onChangeEnd: onChangeEnd,
          activeColor: AppColors.accent,
          inactiveColor: AppColors.foreground.withAlpha(51),
          thumbColor: AppColors.accent,
        ),
      ],
    );
  }
}
