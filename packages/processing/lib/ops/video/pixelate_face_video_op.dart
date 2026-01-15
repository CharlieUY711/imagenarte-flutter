import 'package:core/domain/video_operation.dart';
import 'package:core/domain/tracking_region.dart';

/// Operación de video: Pixelado de rostro
/// 
/// Auto-detección con fallback manual
/// Aplica pixelado frame a frame en las regiones trackeadas
class PixelateFaceVideoOp {
  /// Aplica pixelado a un frame específico
  /// 
  /// params:
  ///   - intensity: int (1-10, por defecto 5)
  ///   - region_id: String? (ID de la región a pixelar, si es null usa auto-detección)
  Future<String?> applyToFrame({
    required String framePath,
    required int frameIndex,
    required VideoOperation operation,
    TrackingRegion? region,
  }) async {
    // Stub: Por ahora retorna null
    // En V1 se implementará el render real
    return null;
  }
}
