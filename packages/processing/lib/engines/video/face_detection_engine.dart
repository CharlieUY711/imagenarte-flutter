import 'package:core/domain/tracking_region.dart';

/// Engine para detección facial en frames
/// 
/// Devuelve bounding boxes por frame
abstract class FaceDetectionEngine {
  /// Detecta rostros en un frame
  /// 
  /// Retorna lista de bounding boxes detectados
  Future<List<BoundingBox>> detectFaces(String framePath);
}

/// Implementación stub (por ahora)
class StubFaceDetectionEngine implements FaceDetectionEngine {
  @override
  Future<List<BoundingBox>> detectFaces(String framePath) async {
    // Stub: Retorna un bounding box simulado en el centro
    // En V1 se integrará MediaPipe/MLKit
    return [];
  }
}
