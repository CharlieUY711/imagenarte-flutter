import 'package:flutter/material.dart';
import 'package:imagenarte/app/theme/app_colors.dart';

/// Área de ajuste que ocupa el espacio entre el menú principal y el bottom del teléfono
/// 
/// Por ahora es un placeholder vacío. En el futuro contendrá controles de ajuste
/// (sliders, dials, etc.) que se mostrarán según la herramienta activa.
class AdjustArea extends StatelessWidget {
  const AdjustArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.background,
      // Por ahora vacío, pero mantiene el espacio reservado
      child: const SizedBox.shrink(),
    );
  }
}
