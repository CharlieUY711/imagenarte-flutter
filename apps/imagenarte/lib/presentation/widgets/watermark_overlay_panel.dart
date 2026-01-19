import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:imagenarte/app/theme/app_colors.dart';
import 'package:imagenarte/app/theme/app_spacing.dart';
import 'package:imagenarte/application/editor_ui_state.dart';
import 'package:imagenarte/domain/watermark_config.dart';
import 'package:imagenarte/presentation/widgets/editor_overlay_panel.dart';
import 'package:imagenarte/presentation/widgets/overlay_dial_row.dart';
import 'package:provider/provider.dart';

/// Panel overlay completo para marca de agua
/// 
/// Incluye: tipo (texto/logo), texto editable, color, opacidad,
/// presets de posición, lock, visible, reset.
class WatermarkOverlayPanel extends StatelessWidget {
  const WatermarkOverlayPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EditorUiState>(
      builder: (context, uiState, child) {
        final isVisible = uiState.activeContext == EditorContext.action_watermark;
        final config = uiState.watermarkConfig;

        return EditorOverlayPanel(
          visible: isVisible,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              const Text(
                'Marca de agua',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              
              // Tipo: Texto | Logo (segmented)
              _buildTypeSelector(context, uiState, config),
              const SizedBox(height: AppSpacing.sm),
              
              // Controles según tipo
              if (config != null) ...[
                if (config.type == WatermarkType.text) ...[
                  // Texto editable
                  _buildTextInput(context, uiState, config),
                  const SizedBox(height: AppSpacing.sm),
                  // Color picker (solo para texto)
                  _buildColorPicker(context, uiState, config),
                  const SizedBox(height: AppSpacing.sm),
                ] else ...[
                  // Cargar logo
                  _buildLoadLogoButton(context, uiState),
                  const SizedBox(height: AppSpacing.sm),
                ],
                
                // Opacidad (siempre visible)
                OverlayDialRow(
                  label: 'Opacidad',
                  valueDouble: uiState.watermarkOpacity,
                  min: 0.0,
                  max: 100.0,
                  onChanged: (value) => uiState.setWatermarkOpacity(value),
                  onChangeEnd: (value) => uiState.setWatermarkOpacityEnd(value),
                ),
                const SizedBox(height: AppSpacing.sm),
                
                // Presets de posición (9-grid)
                _buildPositionPresets(context, uiState),
                const SizedBox(height: AppSpacing.sm),
                
                // Fila de toggles: Lock, Visible, Reset
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildToggle(
                      context: context,
                      label: 'Lock',
                      icon: Icons.lock,
                      value: config.locked,
                      onChanged: (value) => uiState.setWatermarkLocked(value),
                    ),
                    _buildToggle(
                      context: context,
                      label: 'Visible',
                      icon: Icons.visibility,
                      value: config.enabled,
                      onChanged: (value) => uiState.setWatermarkVisible(value),
                    ),
                    _buildResetButton(context, uiState),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypeSelector(BuildContext context, EditorUiState uiState, WatermarkConfig? config) {
    final isText = config?.type == WatermarkType.text;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildTypeOption(
          context: context,
          label: 'Texto',
          isSelected: isText,
          onTap: () => uiState.setWatermarkIsText(true),
        ),
        _buildTypeOption(
          context: context,
          label: 'Logo',
          isSelected: !isText,
          onTap: () => uiState.setWatermarkIsText(false),
        ),
      ],
    );
  }

  Widget _buildTypeOption({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Consumer<EditorUiState>(
      builder: (context, uiState, child) {
        return InkWell(
          onTap: () {
            // REGLA UNIFICADA: Reiniciar timer de auto-cierre al interactuar
            uiState.resetToolAutoCloseTimer();
            onTap();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.accent
                  : AppColors.foreground.withAlpha(26),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? AppColors.foreground
                    : AppColors.foreground.withAlpha(179),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextInput(BuildContext context, EditorUiState uiState, WatermarkConfig config) {
    return TextField(
      controller: TextEditingController(text: config.text),
      style: const TextStyle(
        fontSize: 12,
        color: AppColors.foreground,
      ),
      decoration: InputDecoration(
        labelText: 'Texto',
        labelStyle: TextStyle(
          fontSize: 12,
          color: AppColors.foreground.withAlpha(179),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
            color: AppColors.foreground.withAlpha(51),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
            color: AppColors.foreground.withAlpha(51),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(
            color: AppColors.accent,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
      ),
      onChanged: (value) {
        // REGLA UNIFICADA: Reiniciar timer de auto-cierre al interactuar
        uiState.resetToolAutoCloseTimer();
        // Actualizar en tiempo real sin undo (se hará undo al perder foco)
      },
      onSubmitted: (value) {
        // REGLA UNIFICADA: Reiniciar timer de auto-cierre al interactuar
        uiState.resetToolAutoCloseTimer();
        uiState.setWatermarkText(value.isEmpty ? '@imagenarte' : value);
      },
    );
  }

  Widget _buildColorPicker(BuildContext context, EditorUiState uiState, WatermarkConfig config) {
    // Colores predefinidos simples
    final colors = [
      const Color(0xFFFFFFFF), // Blanco
      const Color(0xFF000000), // Negro
      const Color(0xFF808080), // Gris
      const Color(0xFFFF0000), // Rojo
      const Color(0xFF00FF00), // Verde
      const Color(0xFF0000FF), // Azul
      const Color(0xFFFFFF00), // Amarillo
      const Color(0xFFFF00FF), // Magenta
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Color',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: colors.map((color) {
            final isSelected = config.color.value == color.value;
            return GestureDetector(
              onTap: () {
                // REGLA UNIFICADA: Reiniciar timer de auto-cierre al interactuar
                uiState.resetToolAutoCloseTimer();
                uiState.setWatermarkColor(color);
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.accent : AppColors.foreground.withAlpha(51),
                    width: isSelected ? 3 : 1,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLoadLogoButton(BuildContext context, EditorUiState uiState) {
    return Consumer<EditorUiState>(
      builder: (context, uiState, child) {
        return InkWell(
          onTap: () async {
            // REGLA UNIFICADA: Reiniciar timer de auto-cierre al interactuar
            uiState.resetToolAutoCloseTimer();
            final picker = ImagePicker();
            final XFile? image = await picker.pickImage(source: ImageSource.gallery);
            if (image != null) {
              uiState.setWatermarkImagePath(image.path);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.image,
                  size: 16,
                  color: AppColors.foreground,
                ),
                const SizedBox(width: AppSpacing.xs),
                const Text(
                  'Cargar logo',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.foreground,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPositionPresets(BuildContext context, EditorUiState uiState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Posición',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        // Grid 3x3 de presets
        SizedBox(
          width: 180,
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            children: [
              _buildPresetButton(context, uiState, WatermarkAnchorPreset.topLeft, Icons.north_west),
              _buildPresetButton(context, uiState, WatermarkAnchorPreset.topCenter, Icons.north),
              _buildPresetButton(context, uiState, WatermarkAnchorPreset.topRight, Icons.north_east),
              _buildPresetButton(context, uiState, WatermarkAnchorPreset.middleLeft, Icons.west),
              _buildPresetButton(context, uiState, WatermarkAnchorPreset.center, Icons.center_focus_strong),
              _buildPresetButton(context, uiState, WatermarkAnchorPreset.middleRight, Icons.east),
              _buildPresetButton(context, uiState, WatermarkAnchorPreset.bottomLeft, Icons.south_west),
              _buildPresetButton(context, uiState, WatermarkAnchorPreset.bottomCenter, Icons.south),
              _buildPresetButton(context, uiState, WatermarkAnchorPreset.bottomRight, Icons.south_east),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPresetButton(
    BuildContext context,
    EditorUiState uiState,
    WatermarkAnchorPreset preset,
    IconData icon,
  ) {
    final config = uiState.watermarkConfig;
    final isSelected = config?.anchorPreset == preset;
    
    return InkWell(
      onTap: () {
        // REGLA UNIFICADA: Reiniciar timer de auto-cierre al interactuar
        uiState.resetToolAutoCloseTimer();
        if (uiState.canvasSize != null) {
          uiState.applyWatermarkAnchorPreset(preset, uiState.canvasSize!);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent
              : AppColors.foreground.withAlpha(26),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isSelected
              ? AppColors.foreground
              : AppColors.foreground.withAlpha(179),
        ),
      ),
    );
  }

  Widget _buildToggle({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return InkWell(
      onTap: () {
        // REGLA UNIFICADA: Reiniciar timer de auto-cierre al interactuar
        final uiState = Provider.of<EditorUiState>(context, listen: false);
        uiState.resetToolAutoCloseTimer();
        onChanged(!value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: value
              ? AppColors.accent
              : AppColors.foreground.withAlpha(26),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: value
                  ? AppColors.foreground
                  : AppColors.foreground.withAlpha(179),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: value
                    ? AppColors.foreground
                    : AppColors.foreground.withAlpha(179),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResetButton(BuildContext context, EditorUiState uiState) {
    return InkWell(
      onTap: () {
        // REGLA UNIFICADA: Reiniciar timer de auto-cierre al interactuar
        uiState.resetToolAutoCloseTimer();
        if (uiState.canvasSize != null) {
          uiState.resetWatermark(uiState.canvasSize!);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.foreground.withAlpha(26),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.refresh,
              size: 14,
              color: AppColors.foreground.withAlpha(179),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Reset',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.foreground.withAlpha(179),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
