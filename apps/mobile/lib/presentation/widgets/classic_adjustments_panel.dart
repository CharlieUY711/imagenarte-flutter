import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Panel de ajustes clásicos (brillo, contraste, saturación, etc.)
/// Se muestra en el panel inferior cuando está activo
class ClassicAdjustmentsPanel extends StatelessWidget {
  final double brightness;
  final double contrast;
  final double saturation;
  final ValueChanged<double>? onBrightnessChanged;
  final ValueChanged<double>? onContrastChanged;
  final ValueChanged<double>? onSaturationChanged;

  const ClassicAdjustmentsPanel({
    super.key,
    this.brightness = 0.0,
    this.contrast = 0.0,
    this.saturation = 0.0,
    this.onBrightnessChanged,
    this.onContrastChanged,
    this.onSaturationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTokens.neutralDark.withOpacity(0.95),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTokens.neutralMedium,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Brightness
          _buildSlider(
            label: 'Brillo',
            value: brightness,
            onChanged: onBrightnessChanged,
          ),
          const SizedBox(height: 16),
          // Contrast
          _buildSlider(
            label: 'Contraste',
            value: contrast,
            onChanged: onContrastChanged,
          ),
          const SizedBox(height: 16),
          // Saturation
          _buildSlider(
            label: 'Saturación',
            value: saturation,
            onChanged: onSaturationChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    ValueChanged<double>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value.toStringAsFixed(1),
              style: TextStyle(
                color: AppTokens.accentOrange,
                fontSize: 12,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: -1.0,
          max: 1.0,
          divisions: 20,
          activeColor: AppTokens.accentOrange,
          inactiveColor: AppTokens.neutralMedium,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
