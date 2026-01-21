import 'package:flutter/material.dart';
import 'package:imagenarte/app/theme/app_colors.dart';
import 'package:imagenarte/app/theme/app_spacing.dart';
import 'package:imagenarte/application/editor_state.dart';
import 'package:imagenarte/domain/editor_tool.dart';

class EditorSidebar extends StatelessWidget {
  final EditorState editorState;

  const EditorSidebar({
    super.key,
    required this.editorState,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: editorState,
      builder: (context, child) {
        return Container(
          width: 72,
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border(
              right: BorderSide(
                color: AppColors.foreground.withAlpha(26),
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              _buildToolButton(
                icon: Icons.transform,
                label: 'Transform',
                tool: EditorTool.transform,
              ),
              _buildToolButton(
                icon: Icons.crop,
                label: 'Mask',
                tool: EditorTool.mask,
              ),
              _buildToolButton(
                icon: Icons.blur_on,
                label: 'Blur',
                tool: EditorTool.blur,
              ),
              _buildToolButton(
                icon: Icons.grid_off,
                label: 'Pixelate',
                tool: EditorTool.pixelate,
              ),
              _buildToolButton(
                icon: Icons.water_drop,
                label: 'Watermark',
                tool: EditorTool.watermark,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required EditorTool tool,
  }) {
    final isSelected = editorState.selectedTool == tool;
    return InkWell(
      onTap: () {
        editorState.setTool(tool);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withAlpha(51)
              : Colors.transparent,
          border: isSelected
              ? Border(
                  left: BorderSide(
                    color: AppColors.accent,
                    width: 2,
                  ),
                )
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.accent
                  : AppColors.foreground.withAlpha(179),
              size: 20,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected
                    ? AppColors.accent
                    : AppColors.foreground.withAlpha(179),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
