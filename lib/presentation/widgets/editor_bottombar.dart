import 'package:flutter/material.dart';
import 'package:imagenarte/app/theme/app_colors.dart';
import 'package:imagenarte/app/theme/app_spacing.dart';

class EditorBottomBar extends StatelessWidget {
  const EditorBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.foreground.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Botón Undo (izquierda)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: IconButton(
              onPressed: () {
                // Placeholder: sin funcionalidad
              },
              icon: const Icon(Icons.undo),
              color: AppColors.foreground,
              iconSize: 24,
            ),
          ),
          // Área central: tool options placeholder
          const Expanded(
            child: Center(
              child: Text(
                'Opciones',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.foreground,
                ),
              ),
            ),
          ),
          // Botón Save (derecha)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: IconButton(
              onPressed: () {
                // Placeholder: sin funcionalidad
              },
              icon: const Icon(Icons.save),
              color: AppColors.foreground,
              iconSize: 24,
            ),
          ),
        ],
      ),
    );
  }
}
