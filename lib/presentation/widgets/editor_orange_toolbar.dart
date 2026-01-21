import 'package:flutter/material.dart';
import 'package:imagenarte/app/theme/app_colors.dart';
import 'package:imagenarte/application/editor_ui_state.dart';
import 'package:imagenarte/application/editor_state.dart';
import 'package:imagenarte/presentation/theme/editor_tokens.dart';
import 'package:imagenarte/presentation/widgets/tool_options_inline.dart';
import 'package:provider/provider.dart';

class EditorOrangeToolbar extends StatelessWidget {
  final String? imagePath;
  final EditorState editorState;

  const EditorOrangeToolbar({
    super.key,
    this.imagePath,
    required this.editorState,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<EditorUiState>(
      builder: (context, uiState, child) {
        return SizedBox(
          height: EditorTokens.kBarHeight,
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.accent,
            ),
            child: Padding(
              // Iconos extremos: primer icono a 15px izquierda, último icono a 15px derecha
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                children: [
                  // Grupo izquierdo: Herramientas de selección y acciones
                  Row(
                    children: [
                      // Grupo 1: Herramientas de selección
                      _buildToolIcon(
                        context: context,
                        icon: Icons.crop,
                        tool: EditorTool.geometricSelection,
                        uiState: uiState,
                      ),
                      _buildToolIcon(
                        context: context,
                        icon: Icons.pan_tool,
                        tool: EditorTool.freeSelection,
                        uiState: uiState,
                      ),
                      // Doble espacio
                      const SizedBox(width: 32),
                      // Grupo 2: Acciones (Pixelado, Blur, Marca de Agua, Metadatos)
                      _buildActionIcon(
                        context: context,
                        icon: Icons.grid_off,
                        tool: EditorTool.pixelate,
                        uiState: uiState,
                      ),
                      _buildActionIcon(
                        context: context,
                        icon: Icons.blur_on,
                        tool: EditorTool.blur,
                        uiState: uiState,
                      ),
                      _buildActionIcon(
                        context: context,
                        icon: Icons.water_drop,
                        tool: EditorTool.watermark,
                        uiState: uiState,
                      ),
                      _buildActionIcon(
                        context: context,
                        icon: Icons.info_outline,
                        tool: EditorTool.metadata,
                        uiState: uiState,
                      ),
                    ],
                  ),
                  // Espacio flexible entre grupos
                  const Spacer(),
                  // Tool options inline (centro)
                  Expanded(
                    child: ToolOptionsInline(editorState: editorState),
                  ),
                  const Spacer(),
                  // Grupo derecho: Color y Ajustes
                  Row(
                    children: [
                      // Grupo 3: Color y Ajustes
                      _buildToolIcon(
                        context: context,
                        icon: Icons.palette,
                        tool: EditorTool.color,
                        uiState: uiState,
                      ),
                      _buildToolIcon(
                        context: context,
                        icon: Icons.tune,
                        tool: EditorTool.classicAdjustments,
                        uiState: uiState,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionIcon({
    required BuildContext context,
    required IconData icon,
    required EditorTool tool,
    required EditorUiState uiState,
  }) {
    final isActive = uiState.activeTool == tool || uiState.activeContext == _getContextForTool(tool);
    return GestureDetector(
      onTap: () {
        uiState.selectToolFromMainMenu(tool);
      },
      child: SizedBox(
        height: EditorTokens.kBarHeight,
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.foreground.withAlpha(51)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: SizedBox(
              height: EditorTokens.kBarHeight,
              child: Center(
                child: Icon(
                  icon,
                  color: AppColors.foreground,
                  size: EditorTokens.kIconSize,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  EditorContext _getContextForTool(EditorTool tool) {
    switch (tool) {
      case EditorTool.blur:
        return EditorContext.action_blur;
      case EditorTool.pixelate:
        return EditorContext.action_pixelate;
      case EditorTool.watermark:
        return EditorContext.action_watermark;
      case EditorTool.metadata:
        return EditorContext.action_metadata;
      default:
        return EditorContext.none;
    }
  }

  Widget _buildToolIcon({
    required BuildContext context,
    required IconData icon,
    required EditorTool tool,
    required EditorUiState uiState,
  }) {
    final isActive = uiState.activeTool == tool;
    return GestureDetector(
      onTap: () {
        uiState.selectToolFromMainMenu(tool);
      },
      child: SizedBox(
        height: EditorTokens.kBarHeight,
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.foreground.withAlpha(51)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: SizedBox(
              height: EditorTokens.kBarHeight,
              child: Center(
                child: Icon(
                  icon,
                  color: AppColors.foreground,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

}
