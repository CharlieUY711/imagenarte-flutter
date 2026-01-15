import 'dart:typed_data';
import '../../domain/roi.dart';
import '../ports/face_detector.dart';

/// Caso de uso: Detectar rostros en una imagen
class DetectFacesUseCase {
  final FaceDetector _faceDetector;

  DetectFacesUseCase(this._faceDetector);

  /// Detecta rostros y retorna ROIs normalizadas
  /// 
  /// [imageBytes]: Bytes de la imagen
  /// [width]: Ancho de la imagen en píxeles
  /// [height]: Alto de la imagen en píxeles
  /// 
  /// Retorna lista de ROIs con tipo [RoiType.faceAuto]
  Future<List<ROI>> execute(
    Uint8List imageBytes,
    int width,
    int height,
  ) async {
    return await _faceDetector.detectFaces(imageBytes, width, height);
  }
}
