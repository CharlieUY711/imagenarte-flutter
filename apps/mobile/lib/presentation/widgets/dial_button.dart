import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Botón dial del Action Dial
/// Basado en el diseño Figma: 30px de altura, fondo #1C1C1E, texto blanco/naranja
/// 
/// Estados:
/// - Inactivo: border 1px, bg #1C1C1E, hover #2C2C2E
/// - Activo: border 2px orange-500, bg #1C1C1E, cursor ew-resize
class DialButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isActive;
  final int? value; // Valor numérico opcional (0-100)
  final String? unit; // Unidad opcional (default: '%')

  const DialButton({
    super.key,
    required this.label,
    this.onTap,
    this.isActive = false,
    this.value,
    this.unit = '%',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppTokens.dialButtonHeight,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppTokens.editorSurface,
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          border: Border.all(
            color: isActive ? AppTokens.accentOrange : AppTokens.border,
            width: isActive ? 2.0 : 1.0,
          ),
        ),
        child: Center(
          child: Text(
            value != null && value! > 0
                ? '$label ($value$unit)'
                : label,
            style: TextStyle(
              color: isActive ? AppTokens.accentOrange : Colors.white,
              fontSize: 12,
              fontWeight: AppTokens.fontWeightMedium,
            ),
          ),
        ),
      ),
    );
  }
}
