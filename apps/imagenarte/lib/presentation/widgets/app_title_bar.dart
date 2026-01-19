import 'package:flutter/material.dart';
import 'package:imagenarte/app/theme/app_colors.dart';
import 'package:imagenarte/presentation/theme/editor_tokens.dart';

/// Barra superior con el nombre de la aplicación centrado
class AppTitleBar extends StatelessWidget {
  const AppTitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: EditorTokens.kBarHeight,
      decoration: const BoxDecoration(
        color: AppColors.background,
      ),
      child: Center(
        child: Text(
          'ImagenArte',
          style: TextStyle(
            color: AppColors.foreground,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
