import 'package:flutter/material.dart';
import 'package:imagenarte/app/theme/app_colors.dart';
import 'package:imagenarte/presentation/widgets/editor_topbar.dart';
import 'package:imagenarte/presentation/widgets/editor_sidebar.dart';
import 'package:imagenarte/presentation/widgets/editor_canvas_placeholder.dart';
import 'package:imagenarte/presentation/widgets/editor_bottombar.dart';

class EditorScreen extends StatelessWidget {
  const EditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Topbar fija
            const EditorTopbar(),
            // Cuerpo principal
            Expanded(
              child: Row(
                children: [
                  // Sidebar izquierda fija
                  const EditorSidebar(),
                  // Área central (canvas/preview)
                  const Expanded(
                    child: EditorCanvasPlaceholder(),
                  ),
                ],
              ),
            ),
            // Bottom control bar fija
            const EditorBottomBar(),
          ],
        ),
      ),
    );
  }
}
