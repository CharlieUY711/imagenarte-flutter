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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Contenido principal centrado
              Expanded(
                child: Center(
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
              // Botones de Ajustes y Ayuda
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: () => _openSettingsSheet(context),
                    icon: Icon(
                      Icons.settings_outlined,
                      size: 20,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.75) ?? Colors.grey[600],
                    ),
                    label: Text(
                      'Ajustes',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.75) ?? Colors.grey[600],
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 28),
                  TextButton.icon(
                    onPressed: () => _openHelpSheet(context),
                    icon: Text(
                      '❓',
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.75) ?? Colors.grey[600],
                      ),
                    ),
                    label: Text(
                      'Ayuda',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.75) ?? Colors.grey[600],
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Footer legal
              Column(
                children: [
                  Text(
                    '© 2026 Imagen@rte — Todos los derechos reservados',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.45) ?? Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tratamiento local · Sin backend · Sin tracking',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.45) ?? Colors.grey[500],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _openSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: const Color(0xFF0B0B0D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle superior
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Título
                const Text(
                  'Ajustes',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                // Sección: Aplicación
                _buildSectionTitle('Aplicación'),
                const SizedBox(height: 12),
                _buildSettingItem('Versión: MVP'),
                _buildSettingItem('Modo: Offline-first'),
                _buildSettingItem('Backend: No utiliza backend'),
                _buildSettingItem('Procesamiento: 100% local'),
                const SizedBox(height: 24),
                // Sección: Exportación
                _buildSectionTitle('Exportación'),
                const SizedBox(height: 12),
                _buildSettingItem('Formato: JPG / PNG'),
                _buildSettingItem('Calidad: (por defecto)'),
                const SizedBox(height: 24),
                // Sección: Privacidad
                _buildSectionTitle('Privacidad'),
                const SizedBox(height: 12),
                _buildSettingItem('Las imágenes y videos nunca salen del dispositivo'),
                _buildSettingItem('No se almacenan datos personales'),
                const SizedBox(height: 24),
                // Botón cerrar
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cerrar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openHelpSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: const Color(0xFF0B0B0D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle superior
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Título
                const Text(
                  'Ayuda',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                // Sección: ¿Qué hace Imagen@rte?
                _buildSectionTitle('¿Qué hace Imagen@rte?'),
                const SizedBox(height: 12),
                _buildHelpText(
                  'Herramienta offline para tratamiento, protección y preparación de imágenes y videos antes de publicar.',
                ),
                const SizedBox(height: 24),
                // Sección: Flujo básico
                _buildSectionTitle('Flujo básico'),
                const SizedBox(height: 12),
                _buildHelpText('1. Seleccioná una imagen o video'),
                _buildHelpText('2. Protegé zonas sensibles'),
                _buildHelpText('3. Exportá el archivo tratado'),
                const SizedBox(height: 24),
                // Sección: Privacidad
                _buildSectionTitle('Privacidad'),
                const SizedBox(height: 12),
                _buildHelpText(
                  'Todo el procesamiento se realiza localmente en tu dispositivo.',
                ),
                const SizedBox(height: 24),
                // Botón cerrar
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cerrar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white.withOpacity(0.9),
      ),
    );
  }

  Widget _buildSettingItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: Colors.white.withOpacity(0.75),
        ),
      ),
    );
  }

  Widget _buildHelpText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: Colors.white.withOpacity(0.75),
          height: 1.5,
        ),
      ),
    );
  }
}
