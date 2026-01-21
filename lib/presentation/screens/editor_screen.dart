import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:imagenarte/app/theme/app_colors.dart';
import 'package:imagenarte/application/editor_ui_state.dart';
import 'package:imagenarte/application/editor_state.dart';
import 'package:imagenarte/presentation/widgets/editor_top_info_bar.dart';
import 'package:imagenarte/presentation/widgets/editor_canvas.dart';
import 'package:imagenarte/presentation/widgets/editor_orange_toolbar.dart';
import 'package:imagenarte/presentation/widgets/editor_action_list.dart';
import 'package:imagenarte/presentation/widgets/editor_sidebar.dart';
import 'package:imagenarte/presentation/widgets/editor_bottombar.dart';

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
  late final EditorState _editorState;

  @override
  void initState() {
    super.initState();
    _editorState = EditorState();
    _editorState.setImagePath(widget.imagePath);
  }

  @override
  void dispose() {
    _editorState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditorUiState(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Row(
            children: [
              // Sidebar izquierda
              EditorSidebar(editorState: _editorState),
              // Área principal
              Expanded(
                child: Column(
                  children: [
                    // A) Top info bar naranja (compacta)
                    EditorTopInfoBar(imagePath: widget.imagePath),
                    // B) Canvas central con imagen
                    Expanded(
                      child: EditorCanvas(imagePath: widget.imagePath),
                    ),
                    // C) Toolbar naranja horizontal
                    EditorOrangeToolbar(imagePath: widget.imagePath),
                    // D) Lista inferior de acciones (botones negros grandes)
                    EditorActionList(imagePath: widget.imagePath),
                    // E) BottomBar con opciones inline
                    EditorBottomBar(editorState: _editorState),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
