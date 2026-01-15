import 'package:core/domain/video_operation.dart';

/// Operación de video: Watermark dinámico por sesión
/// 
/// Aplica un watermark visible que es único por sesión
class DynamicWatermarkVideoOp {
  /// Aplica watermark a un frame específico
  /// 
  /// params:
  ///   - text: String? (Texto del watermark, si es null usa session_id)
  ///   - position: String ('top-left', 'top-right', 'bottom-left', 'bottom-right', por defecto 'bottom-right')
  ///   - opacity: double (0.0-1.0, por defecto 0.7)
  Future<String?> applyToFrame({
    required String framePath,
    required int frameIndex,
    required VideoOperation operation,
    required String sessionId,
  }) async {
    // Stub: Por ahora retorna null
    // En V1 se implementará el render real
    return null;
  }
}
