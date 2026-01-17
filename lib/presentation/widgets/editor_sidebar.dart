import 'package:flutter/material.dart';
import 'package:imagenarte/app/theme/app_colors.dart';
import 'package:imagenarte/app/theme/app_spacing.dart';

class EditorSidebar extends StatefulWidget {
  const EditorSidebar({super.key});

  @override
  State<EditorSidebar> createState() => _EditorSidebarState();
}

class _EditorSidebarState extends State<EditorSidebar> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          right: BorderSide(
            color: AppColors.foreground.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          _buildToolButton(
            icon: Icons.transform,
            label: 'Transform',
            index: 0,
          ),
          _buildToolButton(
            icon: Icons.crop,
            label: 'Mask',
            index: 1,
          ),
          _buildToolButton(
            icon: Icons.blur_on,
            label: 'Blur',
            index: 2,
          ),
          _buildToolButton(
            icon: Icons.grid_off,
            label: 'Pixelate',
            index: 3,
          ),
          _buildToolButton(
            icon: Icons.water_drop,
            label: 'Watermark',
            index: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = isSelected ? null : index;
        });
        // Placeholder: sin funcionalidad
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withOpacity(0.2)
              : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.accent
                  : AppColors.foreground.withOpacity(0.7),
              size: 24,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected
                    ? AppColors.accent
                    : AppColors.foreground.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
