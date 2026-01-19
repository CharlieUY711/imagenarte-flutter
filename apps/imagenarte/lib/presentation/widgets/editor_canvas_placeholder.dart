import 'dart:io';
import 'package:flutter/material.dart';
import 'package:imagenarte/app/theme/app_colors.dart';
import 'package:imagenarte/app/theme/app_spacing.dart';
import 'package:imagenarte/app/theme/app_radius.dart';

class EditorCanvasPlaceholder extends StatelessWidget {
  final String? imagePath;

  const EditorCanvasPlaceholder({
    super.key,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        top: AppSpacing.sm,
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.background.withAlpha(128),
        border: Border.all(
          color: AppColors.foreground.withAlpha(51),
          width: 1,
        ),
        borderRadius: const BorderRadius.all(AppRadius.md),
      ),
      child: imagePath != null
          ? ClipRRect(
              borderRadius: const BorderRadius.all(AppRadius.md),
              child: Image.file(
                File(imagePath!),
                fit: BoxFit.contain,
              ),
            )
          : const Center(
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
