/// Tipo de operación de video
enum VideoOperationType {
  pixelateFace, // Pixelado de rostro (auto-detección con fallback manual)
  blurRegion, // Blur en región manual
  dynamicWatermark, // Watermark dinámico por sesión
}

/// Representa una operación a aplicar en el pipeline de video
class VideoOperation {
  final VideoOperationType type;
  final bool enabled;
  final Map<String, dynamic> params;

  VideoOperation({
    required this.type,
    this.enabled = true,
    Map<String, dynamic>? params,
  }) : params = params ?? {};

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'enabled': enabled,
      'params': params,
    };
  }

  static VideoOperation fromMap(Map<String, dynamic> map) {
    return VideoOperation(
      type: VideoOperationType.values.firstWhere(
        (t) => t.name == map['type'],
      ),
      enabled: map['enabled'] as bool? ?? true,
      params: (map['params'] as Map<String, dynamic>?) ?? {},
    );
  }
}
