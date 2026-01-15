import 'dart:convert';
import 'ux_event.dart';
import 'ux_logger.dart';

/// Generador de reportes de UX testing
/// 
/// Agrega métricas y produce JSON/CSV exportable.
class UXReport {
  final UXLogger _logger;

  UXReport(this._logger);

  /// Genera un reporte completo en formato JSON
  Map<String, dynamic> generateReport() {
    if (!_logger.isEnabled) {
      return {'error': 'Modo Testing no está activo'};
    }

    final stats = _logger.getStats();
    final events = _logger.getEvents();
    final now = DateTime.now();

    // Agrupar eventos por tarea
    final tasks = _groupEventsByTask(events);

    return {
      'session_id': stats['session_id'],
      'session_start': stats['session_start'],
      'session_end': now.millisecondsSinceEpoch / 1000.0,
      'total_duration_seconds': stats['session_duration_seconds'],
      'tasks_completed': stats['tasks_completed'],
      'tasks_failed': stats['tasks_failed'],
      'total_crashes': stats['total_crashes'],
      'tasks': tasks,
      'export_timestamp': now.millisecondsSinceEpoch / 1000.0,
      'export_format_version': '1.0',
    };
  }

  /// Convierte el reporte a JSON string (formateado)
  String toJsonString() {
    final report = generateReport();
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(report);
  }

  /// Convierte el reporte a CSV (formato simple)
  String toCsvString() {
    final report = generateReport();
    final tasks = report['tasks'] as List<dynamic>? ?? [];

    final buffer = StringBuffer();
    // Encabezados
    buffer.writeln(
        'task_id,start_time,end_time,duration_seconds,attempts,success,crashed,clarity_rating');

    // Filas
    for (final task in tasks) {
      buffer.write('${task['task_id']},');
      buffer.write('${task['start_time']},');
      buffer.write('${task['end_time']},');
      buffer.write('${task['duration_seconds']},');
      buffer.write('${task['attempts']},');
      buffer.write('${task['success']},');
      buffer.write('${task['crashed']},');
      buffer.writeln(task['clarity_rating'] ?? '');
    }

    return buffer.toString();
  }

  /// Agrupa eventos por tarea y calcula métricas
  List<Map<String, dynamic>> _groupEventsByTask(List<UXEvent> events) {
    final taskMap = <UXTaskId, _TaskMetrics>{};

    for (final event in events) {
      if (event.taskId == null) continue;

      final taskId = event.taskId!;
      taskMap.putIfAbsent(taskId, () => _TaskMetrics(taskId));

      final metrics = taskMap[taskId]!;

      switch (event.type) {
        case UXEventType.taskStart:
          metrics.startTime = event.timestamp;
          metrics.attempts++;
          break;

        case UXEventType.taskEnd:
          metrics.endTime = event.timestamp;
          metrics.success = event.payload['success'] as bool? ?? false;
          metrics.attempts = event.payload['attempts'] as int? ?? metrics.attempts;
          break;

        case UXEventType.crash:
          metrics.crashed = true;
          break;

        case UXEventType.rating:
          metrics.clarityRating = event.payload['clarity_rating'] as int?;
          break;

        default:
          break;
      }
    }

    return taskMap.values.map((m) => m.toMap()).toList();
  }
}

/// Métricas internas por tarea
class _TaskMetrics {
  final UXTaskId taskId;
  DateTime? startTime;
  DateTime? endTime;
  int attempts = 0;
  bool success = false;
  bool crashed = false;
  int? clarityRating;

  _TaskMetrics(this.taskId);

  Map<String, dynamic> toMap() {
    final duration = (startTime != null && endTime != null)
        ? endTime!.difference(startTime!).inMilliseconds / 1000.0
        : 0.0;

    return {
      'task_id': taskId.name,
      'start_time': startTime?.millisecondsSinceEpoch != null
          ? startTime!.millisecondsSinceEpoch / 1000.0
          : null,
      'end_time': endTime?.millisecondsSinceEpoch != null
          ? endTime!.millisecondsSinceEpoch / 1000.0
          : null,
      'duration_seconds': duration,
      'attempts': attempts,
      'success': success,
      'crashed': crashed,
      'clarity_rating': clarityRating,
    };
  }
}
