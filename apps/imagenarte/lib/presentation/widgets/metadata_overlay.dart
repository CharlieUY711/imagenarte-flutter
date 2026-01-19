import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:imagenarte/app/theme/app_colors.dart';
import 'package:imagenarte/app/theme/app_spacing.dart';
import 'package:imagenarte/application/editor_ui_state.dart';
import 'package:imagenarte/domain/services/metadata_stripper.dart';
import 'package:imagenarte/infrastructure/imaging/metadata_stripper_impl.dart';
import 'package:imagenarte/presentation/widgets/editor_overlay_panel.dart';
import 'package:provider/provider.dart';

/// Overlay canónico para Metadatos
/// Muestra toggle ON/OFF y detección de metadatos presentes
class MetadataOverlay extends StatefulWidget {
  final String? imagePath;

  const MetadataOverlay({
    super.key,
    this.imagePath,
  });

  @override
  State<MetadataOverlay> createState() => _MetadataOverlayState();
}

class _MetadataOverlayState extends State<MetadataOverlay> {
  Map<String, bool>? _detectedMetadata;
  bool _isDetecting = false;
  final MetadataStripper _metadataStripper = MetadataStripperImpl();

  @override
  void initState() {
    super.initState();
    _detectMetadataIfNeeded();
  }

  @override
  void didUpdateWidget(MetadataOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagePath != widget.imagePath) {
      _detectMetadataIfNeeded();
    }
  }

  Future<void> _detectMetadataIfNeeded() async {
    if (widget.imagePath == null) return;

    setState(() {
      _isDetecting = true;
    });

    try {
      final file = File(widget.imagePath!);
      final bytes = await file.readAsBytes();
      final detected = await _metadataStripper.detectMetadata(bytes);
      if (mounted) {
        setState(() {
          _detectedMetadata = detected;
          _isDetecting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _detectedMetadata = {'exif': false, 'xmp': false, 'iptc': false};
          _isDetecting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EditorUiState>(
      builder: (context, uiState, child) {
        final isVisible = uiState.activeContext == EditorContext.action_metadata;

        return EditorOverlayPanel(
          visible: isVisible,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Text(
                'Metadatos',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.foreground,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // Subtítulo
              Text(
                'Eliminar EXIF/XMP/IPTC',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: AppColors.foreground.withAlpha(179),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Toggle ON/OFF
              _buildToggle(
                label: 'Eliminar',
                value: uiState.metadataRemovalEnabled,
                onChanged: (value) {
                  // REGLA UNIFICADA: Reiniciar timer de auto-cierre al interactuar
                  uiState.resetToolAutoCloseTimer();
                  uiState.setMetadataRemovalEnabled(value);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              // Resumen de detección
              if (_isDetecting)
                Text(
                  'Detectando...',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.foreground.withAlpha(128),
                  ),
                )
              else if (_detectedMetadata != null)
                _buildDetectionSummary(_detectedMetadata!),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToggle({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
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
            const SizedBox(width: AppSpacing.xs),
            Icon(
              value ? Icons.check : Icons.close,
              size: 14,
              color: value
                  ? AppColors.foreground
                  : AppColors.foreground.withAlpha(179),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetectionSummary(Map<String, bool> detected) {
    final hasAny = detected.values.any((v) => v);
    
    if (!hasAny) {
      return Text(
        'No se detectaron metadatos',
        style: TextStyle(
          fontSize: 10,
          color: AppColors.foreground.withAlpha(128),
        ),
      );
    }

    final parts = <String>[];
    if (detected['exif'] == true) parts.add('EXIF');
    if (detected['xmp'] == true) parts.add('XMP');
    if (detected['iptc'] == true) parts.add('IPTC');

    return Text(
      'Detectados: ${parts.join(', ')}',
      style: TextStyle(
        fontSize: 10,
        color: AppColors.foreground.withAlpha(179),
      ),
    );
  }
}
