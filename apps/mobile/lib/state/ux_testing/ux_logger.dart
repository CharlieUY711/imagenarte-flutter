import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'ux_event.dart';

/// Logger para eventos de UX testing
/// 
/// Almacena eventos en memoria y opcionalmente en archivo temporal.
/// NO persiste datos entre sesiones si no se exporta explícitamente.
class UXLogger {
  static final UXLogger _instance = UXLogger._internal();
  factory UXLogger() => _instance;
  UXLogger._internal();

  bool _isEnabled = false;
  final List<UXEvent> _events = [];
  DateTime? _sessionStart;
  String? _sessionId;
  File? _tempFile;

  /// Habilita el logging (solo si Modo Testing está activo)
  Future<void> enable() async {
    if (_isEnabled) return;

    _isEnabled = true;
    _sessionStart = DateTime.now();
    _sessionId = _generateSessionId();
    _events.clear();

    // Opcional: crear archivo temporal para persistencia durante sesión
    try {
      final tempDir = await getTemporaryDirectory();
      _tempFile = File(path.join(
        tempDir.path,
        'ux_testing_${_sessionId}.json',
      ));
    } catch (e) {
      // Si falla, solo usamos memoria (no crítico)
      _tempFile = null;
    }
  }

  /// Deshabilita el logging y limpia datos
  Future<void> disable() async {
    if (!_isEnabled) return;

    _isEnabled = false;

    // Limpiar archivo temporal si existe
    if (_tempFile != null && await _tempFile!.exists()) {
      try {
        await _tempFile!.delete();
      } catch (e) {
        // Ignorar errores de limpieza
      }
      _tempFile = null;
    }

    _events.clear();
    _sessionStart = null;
    _sessionId = null;
  }

  /// Verifica si el logger está habilitado
  bool get isEnabled => _isEnabled;

  /// Obtiene el ID de sesión actual
  String? get sessionId => _sessionId;

  /// Registra un evento
  void log(UXEvent event) {
    if (!_isEnabled) return;

    _events.add(event);

    // Opcional: escribir a archivo temporal (async, no bloquea)
    if (_tempFile != null) {
      _writeToTempFileAsync();
    }
  }

  /// Obtiene todos los eventos registrados
  List<UXEvent> getEvents() {
    return List.unmodifiable(_events);
  }

  /// Limpia todos los eventos (útil después de exportar)
  void clearEvents() {
    _events.clear();
  }

  /// Obtiene estadísticas básicas
  Map<String, dynamic> getStats() {
    if (!_isEnabled || _sessionStart == null) {
      return {};
    }

    final now = DateTime.now();
    final duration = now.difference(_sessionStart!).inMilliseconds / 1000.0;

    final taskEvents = _events.where((e) => e.taskId != null).toList();
    final completed = taskEvents
        .where((e) => e.type == UXEventType.taskEnd && e.payload['success'] == true)
        .length;
    final failed = taskEvents
        .where((e) => e.type == UXEventType.taskEnd && e.payload['success'] == false)
        .length;
    final crashes = _events.where((e) => e.type == UXEventType.crash).length;

    return {
      'session_id': _sessionId,
      'session_start': _sessionStart!.millisecondsSinceEpoch / 1000.0,
      'session_duration_seconds': duration,
      'total_events': _events.length,
      'tasks_completed': completed,
      'tasks_failed': failed,
      'total_crashes': crashes,
    };
  }

  /// Genera un ID de sesión único (local, no relacionado con usuario)
  String _generateSessionId() {
    final now = DateTime.now();
    return 'session_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
  }

  /// Escribe eventos a archivo temporal de forma asíncrona
  Future<void> _writeToTempFileAsync() async {
    if (_tempFile == null) return;

    try {
      final jsonEvents = _events.map((e) => e.toJson()).toList();
      final jsonString = _formatJson(jsonEvents);
      await _tempFile!.writeAsString(jsonString);
    } catch (e) {
      // Ignorar errores de escritura (no crítico)
    }
  }

  /// Formatea JSON de forma legible
  String _formatJson(List<Map<String, dynamic>> data) {
    // Formato simple (sin dependencias externas)
    final buffer = StringBuffer();
    buffer.writeln('[');
    for (int i = 0; i < data.length; i++) {
      buffer.writeln(_formatMap(data[i], 1));
      if (i < data.length - 1) buffer.write(',');
      buffer.writeln();
    }
    buffer.write(']');
    return buffer.toString();
  }

  String _formatMap(Map<String, dynamic> map, int indent) {
    final indentStr = '  ' * indent;
    final buffer = StringBuffer();
    buffer.write('$indentStr{');
    final entries = map.entries.toList();
    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      buffer.write('\n$indentStr  "${entry.key}": ');
      if (entry.value is Map) {
        buffer.write(_formatMap(entry.value as Map<String, dynamic>, indent + 1));
      } else if (entry.value is List) {
        buffer.write(_formatList(entry.value as List, indent + 1));
      } else if (entry.value is String) {
        buffer.write('"${entry.value}"');
      } else {
        buffer.write(entry.value);
      }
      if (i < entries.length - 1) buffer.write(',');
    }
    buffer.write('\n$indentStr}');
    return buffer.toString();
  }

  String _formatList(List list, int indent) {
    final indentStr = '  ' * indent;
    final buffer = StringBuffer();
    buffer.write('[');
    for (int i = 0; i < list.length; i++) {
      buffer.write('\n$indentStr  ');
      if (list[i] is Map) {
        buffer.write(_formatMap(list[i] as Map<String, dynamic>, indent + 1));
      } else if (list[i] is String) {
        buffer.write('"${list[i]}"');
      } else {
        buffer.write(list[i]);
      }
      if (i < list.length - 1) buffer.write(',');
    }
    buffer.write('\n$indentStr]');
    return buffer.toString();
  }
}
