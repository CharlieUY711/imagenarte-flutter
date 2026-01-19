import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:imagenarte/app/theme/app_colors.dart';
import 'package:imagenarte/application/editor_ui_state.dart';
import 'package:imagenarte/presentation/theme/editor_tokens.dart';
import 'package:imagenarte/presentation/widgets/editor_top_info_bar.dart';
import 'package:imagenarte/presentation/widgets/editor_canvas.dart';
import 'package:imagenarte/presentation/widgets/editor_orange_toolbar.dart';
import 'package:imagenarte/presentation/widgets/tool_control_area.dart';

class EditorScreen extends StatefulWidget {
  final String? imagePath;

  const EditorScreen({
    super.key,
    this.imagePath,
  });

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Solicitar foco para capturar eventos de teclado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    // Manejar ESC: salir de herramienta activa
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
      final uiState = Provider.of<EditorUiState>(context, listen: false);
      uiState.exitActiveTool();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditorUiState(),
      child: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: _handleKeyEvent,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            top: false, // La barra naranja debe estar en la parte superior sin padding
            child: LayoutBuilder(
              builder: (context, constraints) {
              final screenHeight = constraints.maxHeight;
              final screenWidth = constraints.maxWidth;
              // Calcular altura para que el área de previsualización ocupe 70% de la pantalla
              // EditorTopInfoBar tiene dos barras: naranja (25px) + blanca (25px) = 50px total
              final infoBarHeight = EditorTokens.kBarHeight * 2; // 50px (barra naranja + barra blanca)
                
                // El área de previsualización (info bars + canvas) debe ser 70% de la pantalla
                // El canvas comienza inmediatamente después de la barra blanca
                final previewAreaHeight = screenHeight * 0.70;
                final canvasHeight = previewAreaHeight - infoBarHeight;
                
                return Column(
                  children: [
                    // Espacio superior de 50px
                    const SizedBox(height: 50),
                    // A) Top info bar naranja (compacta) - FIJA
                    EditorTopInfoBar(imagePath: widget.imagePath),
                    // C) Canvas central con imagen - hasta 70% de la pantalla (fijo e inamovible)
                    SizedBox(
                      height: canvasHeight,
                      child: EditorCanvas(imagePath: widget.imagePath),
                    ),
                    // D) Toolbar naranja horizontal - FIJA en posición 70% (inamovible)
                    EditorOrangeToolbar(imagePath: widget.imagePath),
                    // E) Área de control de herramienta - FIJA
                    const ToolControlArea(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
