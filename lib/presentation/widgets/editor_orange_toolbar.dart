import 'package:flutter/material.dart';
import 'package:imagenarte/app/theme/app_colors.dart';
import 'package:imagenarte/application/editor_ui_state.dart';
import 'package:imagenarte/presentation/theme/editor_tokens.dart';
import 'package:imagenarte/presentation/screens/home_screen.dart';
import 'package:provider/provider.dart';

class EditorOrangeToolbar extends StatelessWidget {
  final String? imagePath;

  const EditorOrangeToolbar({
    super.key,
    this.imagePath,
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
            child: Row(
              children: [
                // 1) Slot izquierdo fijo: Home (alineado con Home de top bar)
                SizedBox(
                  width: EditorTokens.kLeftIconSlotW,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: EditorTokens.kContentHPad),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const HomeScreen()),
                            (route) => false,
                          );
                        },
                        child: const Icon(
                          Icons.home,
                          color: AppColors.foreground,
                          size: EditorTokens.kIconSize,
                        ),
                      ),
                    ),
                  ),
                ),
                  // 2) Expanded: Todos los íconos originales + nuevos distribuidos uniformemente
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // ÍCONOS ORIGINALES
                        _buildUndoButton(uiState: uiState),
                        _buildScissorsIcon(context: context, uiState: uiState),
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
                        // NUEVOS ÍCONOS (AGREGADOS)
                        _buildActionIcon(
                          context: context,
                          icon: Icons.blur_on,
                          tool: EditorTool.blur,
                          uiState: uiState,
                        ),
                        _buildActionIcon(
                          context: context,
                          icon: Icons.grid_off,
                          tool: EditorTool.pixelate,
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
                  ),
                // 3) Slot derecho fijo: Save (alineado con Save de top bar)
                SizedBox(
                  width: EditorTokens.kRightIconSlotW,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: EditorTokens.kContentHPad),
                      child: GestureDetector(
                        onTap: () {
                          uiState.setActiveTool(EditorTool.save);
                        },
                        child: const Icon(
                          Icons.save,
                          color: AppColors.foreground,
                          size: EditorTokens.kIconSize,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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
        uiState.setActiveTool(tool);
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
      case EditorTool.scissors:
        return EditorContext.scissors;
      case EditorTool.color:
        return EditorContext.colorPresets;
      case EditorTool.classicAdjustments:
        return EditorContext.classicAdjustments;
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
        uiState.toggleTool(tool);
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

  Widget _buildUndoButton({required EditorUiState uiState}) {
    return GestureDetector(
      onTap: uiState.canUndo
          ? () {
              uiState.setActiveTool(EditorTool.undo);
            }
          : null,
      child: SizedBox(
        height: EditorTokens.kBarHeight,
        child: Center(
          child: Icon(
            Icons.undo,
            color: uiState.canUndo
                ? AppColors.foreground
                : AppColors.foreground.withAlpha(128),
            size: EditorTokens.kIconSize,
          ),
        ),
      ),
    );
  }

  Widget _buildScissorsIcon({required BuildContext context, required EditorUiState uiState}) {
    final isEnabled = uiState.hasValidSelection;
    return GestureDetector(
      onTap: isEnabled
          ? () {
              // Usar setContext en lugar de dialog
              uiState.setActiveTool(EditorTool.scissors);
            }
          : null,
      child: SizedBox(
        height: EditorTokens.kBarHeight,
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: uiState.activeContext == EditorContext.scissors
                  ? AppColors.foreground.withAlpha(51)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: SizedBox(
              height: EditorTokens.kBarHeight,
              child: Center(
                child: Icon(
                  Icons.content_cut,
                  color: isEnabled
                      ? AppColors.foreground
                      : AppColors.foreground.withAlpha(128),
                  size: EditorTokens.kIconSize,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

}
