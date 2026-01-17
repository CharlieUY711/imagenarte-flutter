import 'package:flutter/material.dart';
import 'package:imagenarte/app/theme/app_colors.dart';
import 'package:imagenarte/app/theme/app_spacing.dart';
import 'package:imagenarte/app/theme/app_radius.dart';

class EditorCanvasPlaceholder extends StatelessWidget {
  const EditorCanvasPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.5),
        border: Border.all(
          color: AppColors.foreground.withOpacity(0.2),
          width: 1,
        ),
        borderRadius: const BorderRadius.all(AppRadius.md),
      ),
      child: const Center(
        child: Text(
          'Preview',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.foreground,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
