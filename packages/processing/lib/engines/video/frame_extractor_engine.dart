/// Engine para extraer frames de un video
/// 
/// Abstracción para iterar frames sin UI
abstract class FrameExtractorEngine {
  /// Extrae información básica del video
  Future<VideoInfo?> extractVideoInfo(String videoPath);

  /// Extrae un frame específico del video
  /// 
  /// Retorna la ruta temporal del frame extraído
  Future<String?> extractFrame(String videoPath, int frameIndex);

  /// Itera sobre todos los frames del video
  /// 
  /// Llama a [onFrame] para cada frame extraído
  Future<void> iterateFrames(
    String videoPath,
    Future<void> Function(String framePath, int frameIndex) onFrame,
  );
}

/// Información básica de un video
class VideoInfo {
  final int totalFrames;
  final double fps;
  final int width;
  final int height;
  final Duration duration;

  VideoInfo({
    required this.totalFrames,
    required this.fps,
    required this.width,
    required this.height,
    required this.duration,
  });
}
