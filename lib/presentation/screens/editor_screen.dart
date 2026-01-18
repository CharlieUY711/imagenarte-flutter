import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:imagenarte/app/theme/app_colors.dart';
import 'package:imagenarte/application/editor_ui_state.dart';
import 'package:imagenarte/presentation/widgets/editor_top_info_bar.dart';
import 'package:imagenarte/presentation/widgets/editor_canvas.dart';
import 'package:imagenarte/presentation/widgets/editor_orange_toolbar.dart';
import 'package:imagenarte/presentation/widgets/editor_action_list.dart';

class EditorScreen extends StatelessWidget {
  final String? imagePath;

  const EditorScreen({
    super.key,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditorUiState(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // A) Top info bar naranja (compacta)
              EditorTopInfoBar(imagePath: imagePath),
              // B) Canvas central con imagen
              Expanded(
                child: EditorCanvas(imagePath: imagePath),
              ),
              // C) Toolbar naranja horizontal
              EditorOrangeToolbar(imagePath: imagePath),
              // D) Lista inferior de acciones (botones negros grandes)
              EditorActionList(imagePath: imagePath),
            ],
          ),
        ),
      ),
    );
  }
}
