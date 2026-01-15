import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../../../state/ux_testing/ux_logger.dart';
import '../../../state/ux_testing/ux_report.dart';
import '../../../state/ux_testing/ux_event.dart';

/// Pantalla Debug para UX Testing
/// 
/// Permite activar/desactivar el modo testing, ver métricas en tiempo real
/// y exportar reportes manualmente.
class UXTestingScreen extends StatefulWidget {
  const UXTestingScreen({super.key});

  @override
  State<UXTestingScreen> createState() => _UXTestingScreenState();
}

class _UXTestingScreenState extends State<UXTestingScreen> {
  final UXLogger _logger = UXLogger();
  final UXReport _report = UXReport(UXLogger());
  bool _isEnabled = false;

  @override
  void initState() {
    super.initState();
    _isEnabled = _logger.isEnabled;
  }

  Future<void> _toggleTestingMode(bool value) async {
    if (value) {
      await _logger.enable();
    } else {
      await _logger.disable();
    }
    setState(() {
      _isEnabled = _logger.isEnabled;
    });
  }

  Future<void> _exportReport(String format) async {
    if (!_logger.isEnabled) {
      _showSnackBar('Modo Testing no está activo');
      return;
    }

    try {
      final reportString = format == 'json'
          ? _report.toJsonString()
          : _report.toCsvString();

      final extension = format == 'json' ? 'json' : 'csv';
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'ux_testing_report_$timestamp.$extension';

      // Guardar temporalmente
      final tempDir = await getTemporaryDirectory();
      final file = File(path.join(tempDir.path, fileName));
      await file.writeAsString(reportString);

      // Compartir
      final xFile = XFile(file.path);
      await Share.shareXFiles(
        [xFile],
        text: 'Reporte de UX Testing - Imagen@rte',
        subject: 'UX Testing Report',
      );

      _showSnackBar('Reporte exportado: $fileName');
    } catch (e) {
      _showSnackBar('Error al exportar: $e');
    }
  }

  Future<void> _copyReportToClipboard() async {
    if (!_logger.isEnabled) {
      _showSnackBar('Modo Testing no está activo');
      return;
    }

    try {
      final reportString = _report.toJsonString();
      await Clipboard.setData(ClipboardData(text: reportString));
      _showSnackBar('Reporte copiado al portapapeles');
    } catch (e) {
      _showSnackBar('Error al copiar: $e');
    }
  }

  void _clearEvents() {
    if (!_logger.isEnabled) {
      _showSnackBar('Modo Testing no está activo');
      return;
    }

    _logger.clearEvents();
    _showSnackBar('Eventos limpiados');
    setState(() {});
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Map<String, dynamic> _getStats() {
    return _logger.getStats();
  }

  List<UXEvent> _getEvents() {
    return _logger.getEvents();
  }

  @override
  Widget build(BuildContext context) {
    final stats = _getStats();
    final events = _getEvents();

    return Scaffold(
      appBar: AppBar(
        title: const Text('UX Testing'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner de advertencia
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '⚠️ No se recolecta PII. Exportación manual únicamente.',
                      style: TextStyle(
                        color: Colors.orange.shade900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Toggle Modo Testing
            Card(
              child: SwitchListTile(
                title: const Text('Modo Testing'),
                subtitle: Text(
                  _isEnabled
                      ? 'Métricas locales habilitadas'
                      : 'Métricas deshabilitadas',
                ),
                value: _isEnabled,
                onChanged: _toggleTestingMode,
                secondary: Icon(
                  _isEnabled ? Icons.bug_report : Icons.bug_report_outlined,
                  color: _isEnabled ? Colors.green : Colors.grey,
                ),
              ),
            ),

            if (_isEnabled) ...[
              const SizedBox(height: 24),

              // Estadísticas
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Estadísticas de Sesión',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (stats.isNotEmpty) ...[
                        _buildStatRow('ID de Sesión', stats['session_id'] ?? 'N/A'),
                        _buildStatRow(
                          'Duración',
                          '${(stats['session_duration_seconds'] ?? 0.0).toStringAsFixed(1)}s',
                        ),
                        _buildStatRow(
                          'Tareas Completadas',
                          '${stats['tasks_completed'] ?? 0}',
                        ),
                        _buildStatRow(
                          'Tareas Fallidas',
                          '${stats['tasks_failed'] ?? 0}',
                        ),
                        _buildStatRow(
                          'Crashes',
                          '${stats['total_crashes'] ?? 0}',
                        ),
                        _buildStatRow(
                          'Total de Eventos',
                          '${stats['total_events'] ?? 0}',
                        ),
                      ] else
                        const Text('No hay datos aún'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Eventos recientes
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Eventos Recientes',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _clearEvents,
                            icon: const Icon(Icons.clear_all, size: 18),
                            label: const Text('Limpiar'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (events.isEmpty)
                        const Text('No hay eventos registrados')
                      else
                        ...events.take(10).map((event) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  Icon(
                                    _getEventIcon(event.type),
                                    size: 16,
                                    color: _getEventColor(event.type),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${event.type.name}${event.taskId != null ? " (${event.taskId!.name})" : ""}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      if (events.length > 10)
                        Text(
                          '... y ${events.length - 10} eventos más',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Botones de exportación
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Exportar Reporte',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _exportReport('json'),
                            icon: const Icon(Icons.file_download),
                            label: const Text('Exportar JSON'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _exportReport('csv'),
                            icon: const Icon(Icons.table_chart),
                            label: const Text('Exportar CSV'),
                          ),
                          OutlinedButton.icon(
                            onPressed: _copyReportToClipboard,
                            icon: const Icon(Icons.copy),
                            label: const Text('Copiar JSON'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ] else
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(
                  child: Text(
                    'Activa el Modo Testing para comenzar a registrar métricas.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade700),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  IconData _getEventIcon(UXEventType type) {
    switch (type) {
      case UXEventType.taskStart:
        return Icons.play_arrow;
      case UXEventType.taskEnd:
        return Icons.check_circle;
      case UXEventType.taskError:
        return Icons.error;
      case UXEventType.crash:
        return Icons.crisis_alert;
      case UXEventType.rating:
        return Icons.star;
    }
  }

  Color _getEventColor(UXEventType type) {
    switch (type) {
      case UXEventType.taskStart:
        return Colors.blue;
      case UXEventType.taskEnd:
        return Colors.green;
      case UXEventType.taskError:
        return Colors.orange;
      case UXEventType.crash:
        return Colors.red;
      case UXEventType.rating:
        return Colors.amber;
    }
  }
}
