import 'package:flutter/material.dart';
import 'package:imagenarte/app/theme/app_colors.dart';
import 'package:imagenarte/app/theme/app_spacing.dart';
import 'package:imagenarte/application/editor_state.dart';
import 'package:imagenarte/presentation/widgets/tool_options_inline.dart';

class MainBar extends StatelessWidget {
  final EditorState editorState;

  const MainBar({
    super.key,
    required this.editorState,
  });

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
          // Área central: tool options inline
          Expanded(
            child: ToolOptionsInline(editorState: editorState),
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
