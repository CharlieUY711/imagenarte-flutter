import 'video_operation.dart';
import 'tracking_region.dart';

/// Representa una sesión de trabajo con un video
class VideoSession {
  final String sessionId;
  final DateTime createdAt;
  final String? inputUri; // Solo referencia interna temporal
  final List<VideoOperation> operations;
  final Map<String, TrackingRegion> trackingState; // Regiones persistentes y su evolución

  VideoSession({
    required this.sessionId,
    required this.createdAt,
    this.inputUri,
    List<VideoOperation>? operations,
    Map<String, TrackingRegion>? trackingState,
  })  : operations = operations ?? [],
        trackingState = trackingState ?? {};

  VideoSession copyWith({
    String? sessionId,
    DateTime? createdAt,
    String? inputUri,
    List<VideoOperation>? operations,
    Map<String, TrackingRegion>? trackingState,
  }) {
    return VideoSession(
      sessionId: sessionId ?? this.sessionId,
      createdAt: createdAt ?? this.createdAt,
      inputUri: inputUri ?? this.inputUri,
      operations: operations ?? this.operations,
      trackingState: trackingState ?? this.trackingState,
    );
  }

  /// Obtiene el plan de procesamiento como metadata JSON
  /// (sin PII, solo estructura de operaciones y tracking)
  Map<String, dynamic> toProcessingPlan() {
    return {
      'session_id': sessionId,
      'created_at': createdAt.toIso8601String(),
      'operations': operations.map((op) => op.toMap()).toList(),
      'tracking_regions': trackingState.values.map((r) => r.toMap()).toList(),
    };
  }

  /// Crea una sesión desde un plan de procesamiento
  static VideoSession fromProcessingPlan(Map<String, dynamic> plan) {
    return VideoSession(
      sessionId: plan['session_id'] as String,
      createdAt: DateTime.parse(plan['created_at'] as String),
      operations: (plan['operations'] as List<dynamic>?)
              ?.map((op) => VideoOperation.fromMap(op as Map<String, dynamic>))
              .toList() ??
          [],
      trackingState: (plan['tracking_regions'] as List<dynamic>?)
              ?.map((r) {
                final region = TrackingRegion.fromMap(r as Map<String, dynamic>);
                return region;
              })
              .fold<Map<String, TrackingRegion>>(
                {},
                (map, region) => map..[region.id] = region,
              ) ??
          {},
    );
  }
}
