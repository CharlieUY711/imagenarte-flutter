import 'package:flutter/material.dart';
import 'package:imagenarte/app/theme/app_colors.dart';
import 'package:imagenarte/presentation/theme/editor_tokens.dart';

/// TopBar canónica según UI_CONTRACT.md
/// 
/// Reglas:
/// - Color: Naranja → texto Blanco
/// - Altura: 25dp (kBarHeight)
/// - Iconos extremos: Home a 15px izquierda, Save a 15px derecha
/// - Divisores: 40px izquierda, 50%, 75%, 40px derecha
/// - Campos: Campo 1 (40px-50%), Campo 2 (50%-75%), Campo 3 (75%-40px)
class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth;
        if (barWidth <= 0 || !barWidth.isFinite) {
          return const SizedBox.shrink();
        }

        // Divisores según contrato: 40px izquierda, 50%, 75%, 40px derecha
        final divisor1Position = 40.0; // 40px desde izquierda
        final divisor2Position = barWidth * 0.5; // 50%
        final divisor3Position = barWidth * 0.75; // 75%
        final divisor4Position = barWidth - 40.0; // 40px desde derecha

        // Iconos extremos: Home a 15px izquierda, Save a 15px derecha
        final homeIconLeft = 15.0;
        final saveIconRight = 15.0;

        return Container(
          height: EditorTokens.kBarHeight,
          decoration: const BoxDecoration(
            color: AppColors.accent, // Barra Naranja
          ),
          child: Stack(
            children: [
              // Divisor 1: 40px desde izquierda (invisible, mismo color que barra)
              Positioned(
                left: divisor1Position,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    width: 0.5,
                    height: 12.0,
                    color: AppColors.accent, // Mismo color que barra (invisible)
                  ),
                ),
              ),
              // Divisor 2: 50% del ancho total
              Positioned(
                left: divisor2Position,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    width: 0.5,
                    height: 12.0,
                    color: AppColors.accent, // Mismo color que barra (invisible)
                  ),
                ),
              ),
              // Divisor 3: 75% del ancho total
              Positioned(
                left: divisor3Position,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    width: 0.5,
                    height: 12.0,
                    color: AppColors.accent, // Mismo color que barra (invisible)
                  ),
                ),
              ),
              // Divisor 4: 40px desde derecha (invisible, mismo color que barra)
              Positioned(
                left: divisor4Position,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    width: 0.5,
                    height: 12.0,
                    color: AppColors.accent, // Mismo color que barra (invisible)
                  ),
                ),
              ),
              // Home icon: borde izquierdo a 15px del borde izquierdo
              Positioned(
                left: homeIconLeft,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Icon(
                      Icons.home,
                      color: AppColors.foreground, // Blanco (Naranja → Blanco)
                      size: EditorTokens.kIconSize,
                    ),
                  ),
                ),
              ),
              // Save icon: borde derecho a 15px del borde derecho
              Positioned(
                right: saveIconRight,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      // TODO: Implementar guardado
                    },
                    child: const Icon(
                      Icons.save,
                      color: AppColors.foreground, // Blanco (Naranja → Blanco)
                      size: EditorTokens.kIconSize,
                    ),
                  ),
                ),
              ),
              // Campo 1: entre Divisor 1 (40px) y Divisor 2 (50%)
              Positioned(
                left: divisor1Position,
                right: barWidth - divisor2Position,
                top: 0,
                bottom: 0,
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '', // Campo 1 - contenido a definir según uso
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.foreground, // Blanco
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
              // Campo 2: entre Divisor 2 (50%) y Divisor 3 (75%)
              Positioned(
                left: divisor2Position,
                right: barWidth - divisor3Position,
                top: 0,
                bottom: 0,
                child: const Center(
                  child: Text(
                    '', // Campo 2 - contenido a definir según uso
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.foreground, // Blanco
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
              // Campo 3: entre Divisor 3 (75%) y Divisor 4 (40px desde derecha)
              Positioned(
                left: divisor3Position,
                right: barWidth - divisor4Position,
                top: 0,
                bottom: 0,
                child: const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '', // Campo 3 - contenido a definir según uso
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.foreground, // Blanco
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
