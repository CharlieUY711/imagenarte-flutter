import 'package:flutter/material.dart';
import 'package:imagenarte/app/theme/app_colors.dart';
import 'package:imagenarte/app/theme/app_spacing.dart';
import 'package:imagenarte/application/editor_state.dart';
import 'package:imagenarte/domain/editor_tool.dart';

/// Opciones inline para herramientas (Track B B2.1)
/// UNA SOLA FILA compacta por herramienta
class ToolOptionsInline extends StatelessWidget {
  final EditorState editorState;

  const ToolOptionsInline({
    super.key,
    required this.editorState,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: editorState,
      builder: (context, child) {
        switch (editorState.selectedTool) {
          case EditorTool.transform:
            return _buildTransformOptions();
          case EditorTool.mask:
            return _buildMaskOptions();
          case EditorTool.blur:
            return _buildBlurOptions();
          case EditorTool.pixelate:
            return _buildPixelateOptions();
          case EditorTool.watermark:
            return _buildWatermarkOptions();
        }
      },
    );
  }

  Widget _buildTransformOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Transform',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.foreground.withAlpha(179),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        _buildSmallButton(
          icon: Icons.rotate_left,
          onPressed: () {
            // Placeholder
          },
        ),
        const SizedBox(width: AppSpacing.xs),
        _buildSmallButton(
          icon: Icons.rotate_right,
          onPressed: () {
            // Placeholder
          },
        ),
      ],
    );
  }

  Widget _buildMaskOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildChip(
          label: 'Rect',
          isSelected: editorState.maskShape == MaskShape.rect,
          onTap: () => editorState.setMaskShape(MaskShape.rect),
        ),
        const SizedBox(width: AppSpacing.xs),
        _buildChip(
          label: 'Circle',
          isSelected: editorState.maskShape == MaskShape.circle,
          onTap: () => editorState.setMaskShape(MaskShape.circle),
        ),
      ],
    );
  }

  Widget _buildBlurOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Blur',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.foreground.withAlpha(179),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Slider(
              value: editorState.blurIntensity,
              min: 0.0,
              max: 100.0,
              onChanged: (value) => editorState.setBlurIntensity(value),
              activeColor: AppColors.accent,
              inactiveColor: AppColors.foreground.withAlpha(51),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          SizedBox(
            width: 40,
            child: Text(
              '${editorState.blurIntensity.toInt()}',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.foreground.withAlpha(179),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPixelateOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Pixelate',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.foreground.withAlpha(179),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Slider(
              value: editorState.pixelIntensity,
              min: 0.0,
              max: 100.0,
              onChanged: (value) => editorState.setPixelIntensity(value),
              activeColor: AppColors.accent,
              inactiveColor: AppColors.foreground.withAlpha(51),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          SizedBox(
            width: 40,
            child: Text(
              '${editorState.pixelIntensity.toInt()}',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.foreground.withAlpha(179),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWatermarkOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Watermark',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.foreground.withAlpha(179),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        _buildSmallButton(
          icon: Icons.text_fields,
          onPressed: () {
            // Placeholder
          },
        ),
        const SizedBox(width: AppSpacing.xs),
        _buildSmallButton(
          icon: Icons.image,
          onPressed: () {
            // Placeholder
          },
        ),
      ],
    );
  }

  Widget _buildSmallButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      iconSize: 18,
      color: AppColors.foreground.withAlpha(179),
      padding: const EdgeInsets.all(4),
      constraints: const BoxConstraints(
        minWidth: 32,
        minHeight: 32,
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withAlpha(51)
              : AppColors.foreground.withAlpha(13),
          borderRadius: BorderRadius.circular(4),
          border: isSelected
              ? Border.all(
                  color: AppColors.accent,
                  width: 1,
                )
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected
                ? AppColors.accent
                : AppColors.foreground.withAlpha(179),
          ),
        ),
      ),
    );
  }
}
