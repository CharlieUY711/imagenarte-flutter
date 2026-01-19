import 'package:flutter/material.dart';
import 'package:imagenarte/app/theme/app_colors.dart';
import 'package:imagenarte/app/theme/app_spacing.dart';

class EditorBottomBar extends StatelessWidget {
  const EditorBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.foreground.withAlpha(26),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Botón Undo (izquierda)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: IconButton(
              onPressed: () {
                // Placeholder: sin funcionalidad
              },
              icon: const Icon(Icons.undo),
              color: AppColors.foreground,
              iconSize: 22,
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
            ),
          ),
          // Área central: tool options placeholder
          Expanded(
            child: Center(
              child: Text(
                'Opciones',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.foreground.withAlpha(128),
                ),
              ),
            ),
          ),
          // Botón Save (derecha)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: IconButton(
              onPressed: () {
                // Placeholder: sin funcionalidad
              },
              icon: const Icon(Icons.save),
              color: AppColors.foreground,
              iconSize: 22,
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
