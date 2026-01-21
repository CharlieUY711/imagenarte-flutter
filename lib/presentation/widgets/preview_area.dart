import 'package:flutter/material.dart';
import 'package:imagenarte/application/editor_ui_state.dart';
import 'package:imagenarte/application/editor_state.dart';
import 'package:provider/provider.dart';

/// Área de previsualización que contiene el canvas y overlays fijos
/// 
/// Overlays:
/// - Zoom button (top-left)
/// - Undo button (bottom-right, 15 levels)
/// - Navigation arrows (center-left and center-right, vertically centered)
class PreviewArea extends StatelessWidget {
  final Widget childCanvas;
  final EditorState? editorState;

  const PreviewArea({
    super.key,
    required this.childCanvas,
    this.editorState,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<EditorUiState>(
      builder: (context, uiState, child) {
        final hasNavigation = editorState?.hasNavigation ?? false;
        
        return Stack(
          children: [
            // Base: canvas (full size)
            Positioned.fill(
              child: childCanvas,
            ),
            // Overlays
            // Zoom button (top-left)
            Positioned(
              top: 16,
              left: 16,
              child: _ZoomButton(
                onTap: () {
                  // TODO: Implementar zoom (mostrará dial/slider en AdjustArea)
                },
              ),
            ),
            // Navigation arrows (center-left and center-right, vertically centered)
            // Solo mostrar si hay más de 1 imagen
            if (hasNavigation) ...[
              Positioned(
                left: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _NavigationArrow(
                    icon: Icons.arrow_back,
                    onTap: () {
                      // TODO: Implementar navegación anterior (catálogo)
                    },
                  ),
                ),
              ),
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _NavigationArrow(
                    icon: Icons.arrow_forward,
                    onTap: () {
                      // TODO: Implementar navegación siguiente (catálogo)
                    },
                  ),
                ),
              ),
            ],
            // Undo button (bottom-right)
            Positioned(
              bottom: 16,
              right: 16,
              child: _UndoButton(
                canUndo: uiState.canUndo,
                onTap: uiState.canUndo
                    ? () {
                        uiState.undo();
                      }
                    : null,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Botón de zoom (lupa) en top-left
class _ZoomButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _ZoomButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        Icons.zoom_in,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}

/// Flecha de navegación (blanca) en center-left/right
class _NavigationArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _NavigationArrow({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        icon,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}

/// Botón de Undo en bottom-right
class _UndoButton extends StatelessWidget {
  final bool canUndo;
  final VoidCallback? onTap;

  const _UndoButton({
    required this.canUndo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        Icons.undo,
        color: canUndo
            ? Colors.white
            : Colors.white.withValues(alpha: 0.5),
        size: 24,
      ),
    );
  }
}
