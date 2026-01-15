/// Engine para renderizar el video final
/// 
/// Aplica operaciones y genera output
abstract class RendererEngine {
  /// Renderiza el video final desde frames procesados
  /// 
  /// frames: Map<frameIndex, framePath>
  /// outputPath: Ruta donde guardar el video final
  Future<String?> renderVideo({
    required Map<int, String> frames,
    required String outputPath,
    required double fps,
    required int width,
    required int height,
  });
}

/// Implementación stub (por ahora)
class StubRendererEngine implements RendererEngine {
  @override
  Future<String?> renderVideo({
    required Map<int, String> frames,
    required String outputPath,
    required double fps,
    required int width,
    required int height,
  }) async {
    // Stub: Por ahora retorna null
    // En V1 se implementará con FFmpeg o APIs nativas
    return null;
  }
}
