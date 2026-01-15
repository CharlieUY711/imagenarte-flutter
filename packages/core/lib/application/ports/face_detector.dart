import 'dart:typed_data';
import '../../domain/roi.dart';

/// Puerto (interfaz) para detección facial
/// 
/// Esta interfaz NO depende de Flutter UI ni de implementaciones específicas.
/// Permite intercambiar implementaciones (MLKit, MediaPipe, etc.)
abstract class FaceDetector {
  /// Detecta rostros en una imagen
  /// 
  /// [imageBytes]: Bytes de la imagen
  /// [width]: Ancho de la imagen en píxeles
  /// [height]: Alto de la imagen en píxeles
  /// 
  /// Retorna lista de ROIs normalizadas (0.0 a 1.0) con tipo [RoiType.faceAuto]
  Future<List<ROI>> detectFaces(
    Uint8List imageBytes,
    int width,
    int height,
  );
}
