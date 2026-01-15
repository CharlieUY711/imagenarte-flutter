import 'package:core/domain/video_operation.dart';
import 'package:core/domain/tracking_region.dart';

/// Operación de video: Blur en región
/// 
/// Aplica blur persistente en zonas marcadas manualmente
class BlurRegionVideoOp {
  /// Aplica blur a un frame específico
  /// 
  /// params:
  ///   - intensity: double (0.0-1.0, por defecto 0.5)
  ///   - region_id: String (ID de la región a blur)
  Future<String?> applyToFrame({
    required String framePath,
    required int frameIndex,
    required VideoOperation operation,
    required TrackingRegion region,
  }) async {
    // Stub: Por ahora retorna null
    // En V1 se implementará el render real
    return null;
  }
}
