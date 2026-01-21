import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:imagenarte/app/theme/app_colors.dart';
import 'package:imagenarte/application/editor_ui_state.dart';
import 'package:imagenarte/application/editor_state.dart';
import 'package:imagenarte/presentation/widgets/info_bar.dart';
import 'package:imagenarte/presentation/widgets/editor_canvas.dart';
import 'package:imagenarte/presentation/widgets/editor_orange_toolbar.dart';
import 'package:imagenarte/presentation/widgets/preview_area.dart';
import 'package:imagenarte/presentation/widgets/adjust_area.dart';
import 'package:imagenarte/presentation/theme/editor_tokens.dart';

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
    // Establecer imagen activa visible en el preview
    if (widget.imagePath != null) {
      _editorState.setActivePreviewImagePath(widget.imagePath!);
    }
  }

  @override
  void didUpdateWidget(EditorScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si cambió el imagePath, actualizar imagen activa visible
    if (widget.imagePath != oldWidget.imagePath) {
      _editorState.setImagePath(widget.imagePath);
      if (widget.imagePath != null) {
        _editorState.setActivePreviewImagePath(widget.imagePath!);
      }
    }
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
      child: _EditorScreenContent(
        imagePath: widget.imagePath,
        child: Scaffold(
          backgroundColor: AppColors.background,
          // Las barras son inamovibles: el teclado NO debe reflowear el layout
          resizeToAvoidBottomInset: false,
          body: LayoutBuilder(
            builder: (context, constraints) {
              // Usar MediaQuery para obtener la altura total del dispositivo
              // NO usar constraints que pueden cambiar con viewInsets/teclado
              final mediaQuery = MediaQuery.of(context);
              final deviceHeight = mediaQuery.size.height;
              final statusBarHeight = mediaQuery.padding.top;
              
              // TopBar comienza inmediatamente después del status bar
              final topBarTop = statusBarHeight;
              // Altura total de InfoBar: barra naranja (25dp) + barra blanca (25dp) = 50dp
              // El offset de -2px en Transform.translate hace que el borde visual inferior esté en 48dp
              final topBarsHeight = EditorTokens.kBarHeight * 2;
              final infoBarBottom = topBarTop + topBarsHeight - 2.0; // Offset de -2px
              
              // MainBar posicionada al 75% de la altura total del dispositivo (desde el top del dispositivo)
              final toolbarTop = deviceHeight * 0.75;
              final toolbarHeight = EditorTokens.kBarHeight;
              final adjustAreaTop = toolbarTop + toolbarHeight;
              
              return Stack(
                children: [
                  // A) InfoBar (TopBar + InfoBar) - anclada desde statusBarHeight, inamovible
                  Positioned(
                    top: topBarTop,
                    left: 0,
                    right: 0,
                    child: InfoBar(
                      imagePath: widget.imagePath,
                      editorState: _editorState,
                    ),
                  ),
                  // B) PreviewArea: Canvas + overlays - posicionado exactamente entre InfoBar y MainBar
                  Positioned(
                    top: infoBarBottom,
                    bottom: deviceHeight - toolbarTop,
                    left: 0,
                    right: 0,
                    child: PreviewArea(
                      childCanvas: EditorCanvas(imagePath: widget.imagePath),
                      editorState: _editorState,
                    ),
                  ),
                  // C) MainBar (EditorOrangeToolbar) - anclada al 75% de altura total, inamovible
                  Positioned(
                    top: toolbarTop,
                    left: 0,
                    right: 0,
                    child: EditorOrangeToolbar(
                      imagePath: widget.imagePath,
                      editorState: _editorState,
                    ),
                  ),
                  // D) AdjustArea: espacio entre MainBar y bottom del dispositivo
                  Positioned(
                    top: adjustAreaTop,
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: const AdjustArea(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Widget interno que maneja el pushUndo inicial cuando se carga la imagen
class _EditorScreenContent extends StatefulWidget {
  final String? imagePath;
  final Widget child;

  const _EditorScreenContent({
    required this.imagePath,
    required this.child,
  });

  @override
  State<_EditorScreenContent> createState() => _EditorScreenContentState();
}

class _EditorScreenContentState extends State<_EditorScreenContent> {
  bool _hasPushedInitialUndo = false;

  @override
  void initState() {
    super.initState();
    // Push undo inicial cuando se carga la imagen
    // TODO: Mover esto a un punto más claro cuando se confirme la carga de imagen
    if (widget.imagePath != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_hasPushedInitialUndo) {
          final uiState = context.read<EditorUiState>();
          uiState.pushUndo();
          _hasPushedInitialUndo = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
