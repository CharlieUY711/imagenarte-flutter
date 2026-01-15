import 'dart:typed_data';
import 'package:core/application/ports/face_detector.dart';
import 'package:core/domain/roi.dart';

/// Implementación NOOP de FaceDetector para Web
/// 
/// Esta implementación no realiza detección real y siempre retorna una lista vacía.
/// Se usa en plataforma web donde ML Kit no está disponible.
class NoopFaceDetectorWeb implements FaceDetector {
  @override
  Future<List<ROI>> detectFaces(
    Uint8List imageBytes,
    int width,
    int height,
  ) async {
    // NOOP: Retorna lista vacía sin realizar detección
    return [];
  }
}
