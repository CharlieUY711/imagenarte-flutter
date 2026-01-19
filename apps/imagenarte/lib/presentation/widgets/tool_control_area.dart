import 'package:flutter/material.dart';
import 'package:imagenarte/app/theme/app_colors.dart';
import 'package:imagenarte/presentation/theme/editor_tokens.dart';

/// Área de control de la herramienta seleccionada
/// Por ahora: placeholder vacío que reserva espacio para futuros controles
class ToolControlArea extends StatelessWidget {
  const ToolControlArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.0, // minHeight recomendado: 56-72dp
      decoration: const BoxDecoration(
        color: AppColors.background,
      ),
      // Por ahora: vacío, solo reserva espacio
      child: const SizedBox.shrink(),
    );
  }
}
