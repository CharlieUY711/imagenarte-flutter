import 'package:flutter/material.dart';
import 'package:imagenarte/app/theme/app_colors.dart';

class EditorTopbar extends StatelessWidget {
  const EditorTopbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.foreground.withAlpha(26),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Botón back (izquierda)
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back),
            color: AppColors.foreground,
            iconSize: 20,
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
          ),
          // Título centrado
          const Expanded(
            child: Text(
              'Editor',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.foreground,
              ),
            ),
          ),
          // Iconos derecha (settings/help)
          IconButton(
            onPressed: () {
              // Placeholder: sin funcionalidad
            },
            icon: const Icon(Icons.settings),
            color: AppColors.foreground,
            iconSize: 20,
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
          ),
          IconButton(
            onPressed: () {
              // Placeholder: sin funcionalidad
            },
            icon: const Icon(Icons.help_outline),
            color: AppColors.foreground,
            iconSize: 20,
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
          ),
        ],
      ),
    );
  }
}
