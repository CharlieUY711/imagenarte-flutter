import 'package:flutter/material.dart';
import 'package:imagenarte/app/theme/app_colors.dart';
import 'package:imagenarte/app/theme/app_radius.dart';
import 'package:imagenarte/presentation/theme/editor_tokens.dart';

/// Panel overlay canónico reutilizable para todas las herramientas del editor
/// 
/// Este panel debe estar siempre en la misma posición: sobre el canvas,
/// alineado abajo, justo encima de la toolbar naranja.
/// 
/// El overlay NO empuja el layout (usa Positioned) y NO bloquea gestos
/// del canvas fuera del panel.
class EditorOverlayPanel extends StatelessWidget {
  final Widget child;
  final bool visible;

  const EditorOverlayPanel({
    super.key,
    required this.child,
    required this.visible,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: EditorTokens.kOverlayHorizontalPadding,
      right: EditorTokens.kOverlayHorizontalPadding,
      bottom: EditorTokens.kToolbarHeight + EditorTokens.kToolbarToContentGap,
      child: IgnorePointer(
        ignoring: false,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 12.0, // Aumentado de 10.0 a 12.0 (20% más alto: 10.0 * 1.2 = 12.0)
          ),
          decoration: BoxDecoration(
            color: AppColors.background.withAlpha(180), // Más transparente: reducido de 230 a 180
            borderRadius: const BorderRadius.all(AppRadius.md),
          ),
          child: child,
        ),
      ),
    );
  }
}
