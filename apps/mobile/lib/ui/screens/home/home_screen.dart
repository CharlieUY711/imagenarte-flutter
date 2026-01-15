import 'package:flutter/material.dart';
import '../../../navigation/app_router.dart';
import '../../../utils/debug_gate.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Imagen@rte'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // GATING ESTRICTO: Botón debug solo visible en modo debug
        actions: DebugGate.isDebugModeEnabled()
            ? [
                IconButton(
                  icon: const Icon(Icons.bug_report_outlined),
                  tooltip: 'UX Testing (Debug)',
                  onPressed: () {
                    Navigator.pushNamed(context, AppRouter.uxTesting);
                  },
                ),
              ]
            : null, // En release, actions es null (sin botón debug)
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.image_outlined,
                size: 80,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 32),
              const Text(
                'Tratamiento y Protección\nde Imágenes',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: () {
                  // Ir directamente al editor visual para corregir UI
                  Navigator.pushNamed(context, AppRouter.editor);
                },
                icon: const Icon(Icons.photo_library),
                label: const Text('Editor Visual (UI)'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, AppRouter.wizard);
                },
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Wizard (completo)'),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: null, // Deshabilitado por ahora
                icon: const Icon(Icons.videocam),
                label: const Text('Tratar Video (próximamente)'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 32),
              TextButton.icon(
                onPressed: () {
                  // TODO: Abrir configuración de protección
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Configuración de protección (próximamente)'),
                    ),
                  );
                },
                icon: const Icon(Icons.shield),
                label: const Text('Protección'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
