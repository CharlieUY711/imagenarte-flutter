/// Módulo de eventos para UX Testing
/// 
/// Define la estructura de eventos que se registran durante sesiones de testing.
/// NO captura PII ni datos personales.

enum UXEventType {
  taskStart,
  taskEnd,
  taskError,
  crash,
  rating,
}

enum UXTaskId {
  importImage,
  pixelateFace,
  blurRegion,
  removeBackground,
  exportExif,
  exportWatermark,
  exportReceipt,
}

enum UXErrorType {
  userConfusion,
  technicalError,
}

/// Evento individual de UX testing
class UXEvent {
  final UXEventType type;
  final DateTime timestamp;
  final UXTaskId? taskId;
  final Map<String, dynamic> payload;

  UXEvent({
    required this.type,
    required this.timestamp,
    this.taskId,
    Map<String, dynamic>? payload,
  }) : payload = payload ?? {};

  /// Convierte el evento a JSON para exportación
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'timestamp': timestamp.millisecondsSinceEpoch / 1000.0,
      if (taskId != null) 'task_id': taskId!.name,
      'payload': payload,
    };
  }

  /// Crea un evento de inicio de tarea
  factory UXEvent.taskStart({
    required UXTaskId taskId,
    DateTime? timestamp,
  }) {
    return UXEvent(
      type: UXEventType.taskStart,
      timestamp: timestamp ?? DateTime.now(),
      taskId: taskId,
    );
  }

  /// Crea un evento de fin de tarea
  factory UXEvent.taskEnd({
    required UXTaskId taskId,
    required bool success,
    required double durationSeconds,
    required int attempts,
    DateTime? timestamp,
  }) {
    return UXEvent(
      type: UXEventType.taskEnd,
      timestamp: timestamp ?? DateTime.now(),
      taskId: taskId,
      payload: {
        'success': success,
        'duration_seconds': durationSeconds,
        'attempts': attempts,
      },
    );
  }

  /// Crea un evento de error en tarea
  factory UXEvent.taskError({
    required UXTaskId taskId,
    required UXErrorType errorType,
    String? errorMessage,
    DateTime? timestamp,
  }) {
    return UXEvent(
      type: UXEventType.taskError,
      timestamp: timestamp ?? DateTime.now(),
      taskId: taskId,
      payload: {
        'error_type': errorType.name,
        if (errorMessage != null) 'error_message': errorMessage,
      },
    );
  }

  /// Crea un evento de crash
  factory UXEvent.crash({
    required UXTaskId taskId,
    required String errorCode,
    bool recovered = false,
    DateTime? timestamp,
  }) {
    return UXEvent(
      type: UXEventType.crash,
      timestamp: timestamp ?? DateTime.now(),
      taskId: taskId,
      payload: {
        'error_code': errorCode,
        'recovered': recovered,
      },
    );
  }

  /// Crea un evento de rating de claridad
  factory UXEvent.rating({
    required UXTaskId taskId,
    required int clarityRating,
    DateTime? timestamp,
  }) {
    assert(clarityRating >= 1 && clarityRating <= 5,
        'Rating debe estar entre 1 y 5');
    return UXEvent(
      type: UXEventType.rating,
      timestamp: timestamp ?? DateTime.now(),
      taskId: taskId,
      payload: {
        'clarity_rating': clarityRating,
        'scale': '1-5',
      },
    );
  }
}
