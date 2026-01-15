import 'dart:typed_data';
import 'dart:io';
import 'package:core/domain/roi.dart';
import 'package:core/application/ports/face_detector.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart' as mlkit;
import 'package:image/image.dart' as img;

/// Implementación de FaceDetector usando ML Kit
class MlKitFaceDetector implements FaceDetector {
  final mlkit.FaceDetectorOptions _options;
  late final mlkit.FaceDetector _detector;

  MlKitFaceDetector({
    bool enableClassification = false,
    bool enableLandmarks = false,
    bool enableTracking = false,
    double minFaceSize = 0.15,
  }) : _options = mlkit.FaceDetectorOptions(
          enableClassification: enableClassification,
          enableLandmarks: enableLandmarks,
          enableTracking: enableTracking,
          minFaceSize: minFaceSize,
        ) {
    _detector = mlkit.FaceDetector(options: _options);
  }

  @override
  Future<List<ROI>> detectFaces(
    Uint8List imageBytes,
    int width,
    int height,
  ) async {
    try {
      // Decodificar imagen usando el paquete image para obtener dimensiones
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        return [];
      }

      // ML Kit necesita un archivo temporal o InputImage desde bytes
      // Crear archivo temporal
      final tempFile = File('${Directory.systemTemp.path}/face_detect_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(imageBytes);

      // Crear InputImage desde archivo
      final inputImage = mlkit.InputImage.fromFilePath(tempFile.path);

      // Detectar rostros
      final faces = await _detector.processImage(inputImage);

      // Limpiar archivo temporal
      try {
        await tempFile.delete();
      } catch (_) {
        // Ignorar errores al eliminar temporal
      }

      // Convertir a ROIs normalizadas
      final rois = <ROI>[];
      int roiIndex = 0;

      for (final face in faces) {
        final boundingBox = face.boundingBox;
        
        // Calcular coordenadas normalizadas
        // ML Kit retorna coordenadas en píxeles de la imagen original
        final x = boundingBox.left / image.width;
        final y = boundingBox.top / image.height;
        final w = boundingBox.width / image.width;
        final h = boundingBox.height / image.height;

        // Validar que estén en rango [0, 1]
        final normalizedX = x.clamp(0.0, 1.0);
        final normalizedY = y.clamp(0.0, 1.0);
        final normalizedW = (x + w).clamp(0.0, 1.0) - normalizedX;
        final normalizedH = (y + h).clamp(0.0, 1.0) - normalizedY;

        // Validar que el tamaño sea válido
        if (normalizedW <= 0 || normalizedH <= 0) continue;

        // Obtener confianza si está disponible
        double? confidence;
        if (face.trackingId != null) {
          // ML Kit no expone confianza directamente, usar trackingId como indicador
          confidence = 0.8; // Valor por defecto razonable
        }

        final roi = ROI(
          id: 'face_auto_${roiIndex++}',
          type: RoiType.faceAuto,
          shape: RoiShape.rect,
          x: normalizedX,
          y: normalizedY,
          width: normalizedW,
          height: normalizedH,
          locked: false,
          confidence: confidence,
        );

        rois.add(roi);
      }

      return rois;
    } catch (e) {
      // En caso de error, retornar lista vacía
      // En producción, podría loguear el error
      return [];
    }
  }

  /// Libera recursos del detector
  void dispose() {
    _detector.close();
  }
}
