import 'package:flutter/material.dart';
import 'package:imagenarte/application/editor_ui_state.dart';
import 'package:imagenarte/domain/watermark_config.dart';
import 'package:imagenarte/transform/transform_model.dart';
import 'package:imagenarte/transform/transform_controller.dart';
import 'package:imagenarte/transform/transform_overlay_widget.dart';
import 'package:imagenarte/transform/transform_adapter.dart';
import 'package:provider/provider.dart';

/// Widget que integra el nuevo motor de transformaciones con watermark
/// 
/// Usa el nuevo motor pero se integra con EditorUiState existente.
class WatermarkTransformOverlay extends StatefulWidget {
  const WatermarkTransformOverlay({super.key});

  @override
  State<WatermarkTransformOverlay> createState() => _WatermarkTransformOverlayState();
}

class _WatermarkTransformOverlayState extends State<WatermarkTransformOverlay> {
  late TransformController _transformController;
  String? _watermarkItemId;

  @override
  void initState() {
    super.initState();
    _transformController = TransformController(
      onTransformChanged: (item) {
        // Durante drag: actualizar sin commit undo
        final uiState = Provider.of<EditorUiState>(context, listen: false);
        if (uiState.watermarkConfig != null) {
          final geometry = TransformAdapter.toTransformableGeometry(
            item.transform,
            uiState.watermarkConfig!.transform.shape,
          );
          uiState.updateWatermarkGeometry(geometry);
        }
      },
      onTransformCommitted: (item) {
        // Al soltar: hacer commit undo inmediatamente
        final uiState = Provider.of<EditorUiState>(context, listen: false);
        // Cancelar el debounce timer y hacer pushUndo inmediato
        uiState.commitWatermarkTransform();
      },
    );
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EditorUiState>(
      builder: (context, uiState, child) {
        // Solo mostrar si watermark está activo y hay configuración
        if (uiState.activeTool != EditorTool.watermark ||
            uiState.watermarkConfig == null ||
            !uiState.watermarkConfig!.enabled) {
          _watermarkItemId = null;
          _transformController.clear();
          return const SizedBox.shrink();
        }

        final config = uiState.watermarkConfig!;
        final geometry = config.transform;
        final isSelected = uiState.activeTransformTarget == TransformTarget.watermarkText ||
            uiState.activeTransformTarget == TransformTarget.watermarkLogo;

        // Sincronizar item con estado
        final itemId = 'watermark_${config.type.name}';
        if (_watermarkItemId != itemId) {
          _watermarkItemId = itemId;
          _transformController.clear();
          
          final transform = TransformAdapter.fromTransformableGeometry(geometry);
          final item = TransformableItem(
            id: itemId,
            transform: transform,
            type: config.type == WatermarkType.text
                ? TransformableItemType.text
                : TransformableItemType.logo,
            isSelected: isSelected,
            payload: config,
          );
          _transformController.addItem(item);
          if (isSelected) {
            _transformController.selectItem(itemId);
          }
        } else {
          // Actualizar item existente
          final existingItem = _transformController.items.firstWhere(
            (item) => item.id == itemId,
            orElse: () => TransformableItem(
              id: itemId,
              transform: TransformAdapter.fromTransformableGeometry(geometry),
              type: config.type == WatermarkType.text
                  ? TransformableItemType.text
                  : TransformableItemType.logo,
              payload: config,
            ),
          );
          
          if (existingItem.id == itemId) {
            final transform = TransformAdapter.fromTransformableGeometry(geometry);
            final updatedItem = existingItem.copyWith(
              transform: transform,
              isSelected: isSelected,
            );
            _transformController.updateItem(updatedItem);
            if (isSelected && _transformController.selectedItem?.id != itemId) {
              _transformController.selectItem(itemId);
            } else if (!isSelected && _transformController.selectedItem?.id == itemId) {
              _transformController.selectItem(null);
            }
          }
        }

        // Configurar handles según si está bloqueado
        _transformController.setHandlesConfig(
          TransformHandlesConfig(
            showCornerHandles: true,
            showEdgeHandles: true,
            showRotateHandle: true,
            minScale: 0.1,
            maxScale: 5.0,
            maintainAspectRatio: false, // Watermark puede escalarse no-uniforme
          ),
        );

        // Mostrar overlay solo si está seleccionado
        if (!isSelected || config.locked) {
          return const SizedBox.shrink();
        }

        return TransformOverlayWidget(
          controller: _transformController,
          itemId: itemId,
        );
      },
    );
  }
}
