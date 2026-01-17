import 'package:flutter/material.dart';
import 'package:imagenarte/app/theme/app_colors.dart';
import 'package:imagenarte/presentation/screens/editor_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Imagen@rte',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.foreground,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const EditorScreen(),
                  ),
                );
              },
              child: const Text('Seleccionar imagen'),
            ),
          ],
        ),
      ),
    );
  }
}
