import 'dart:io';
import 'dart:typed_data';
import 'package:core/application/editor_controller.dart';
import 'package:core/application/usecases/detect_faces.dart';
import 'package:core/application/ports/face_detector.dart';
import 'package:core/usecases/export_media.dart';
import 'package:core/privacy/exif_sanitizer.dart';
import 'package:core/domain/roi.dart';
import 'package:watermark/visible/visible_watermark.dart';
import 'package:watermark/invisible/invisible_watermark.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// Import de infrastructure solo aquí (fuera de presentation/widgets)
import 'package:processing/infrastructure/face_detection/mlkit_face_detector.dart';
import 'package:processing/infrastructure/face_detection/noop_face_detector_web.dart';
import 'package:processing/infrastructure/imaging/roi_image_processor.dart';

// Re-export EffectMode para uso en factory
export 'package:core/application/editor_controller.dart' show EffectMode;

/// Factory para crear EditorController con todas sus dependencias
/// 
/// Este factory puede importar infrastructure porque no está en presentation/widgets.
/// Se usa para instanciar el controller antes de pasarlo al ViewModel.
class EditorControllerFactory {
  /// Crea un EditorController con todas sus dependencias configuradas
  static EditorController create() {
    // Crear FaceDetector (infrastructure)
    // En web usa NoopFaceDetectorWeb, en mobile usa MlKitFaceDetector
    final FaceDetector faceDetector = kIsWeb
        ? NoopFaceDetectorWeb()
        : MlKitFaceDetector(
            minFaceSize: 0.15,
          );

    // Crear DetectFacesUseCase
    final detectFacesUseCase = DetectFacesUseCase(faceDetector);

    // Crear EditorController
    return EditorController(detectFacesUseCase);
  }

  /// Crea ExportMedia con todas sus dependencias
  static ExportMedia createExportMedia() {
    return ExportMedia(
      ExifSanitizer(),
      VisibleWatermark(),
      InvisibleWatermark(),
    );
  }

  /// Procesa ROIs en una imagen antes de exportar
  /// 
  /// Aplica efectos (pixelate/blur) solo en las ROIs especificadas.
  /// Retorna el path de la imagen procesada.
  static Future<String> processRois({
    required String imagePath,
    required List<ROI> rois,
    required EffectMode effectMode,
    required int effectIntensity,
  }) async {
    final processor = RoiImageProcessor();
    
    final imageBytes = await File(imagePath).readAsBytes();
    Uint8List processedBytes;
    
    if (effectMode == EffectMode.pixelate) {
      processedBytes = await processor.applyPixelateToRois(
        imageBytes: imageBytes,
        rois: rois,
        intensity: effectIntensity,
      );
    } else {
      processedBytes = await processor.applyBlurToRois(
        imageBytes: imageBytes,
        rois: rois,
        intensity: effectIntensity,
      );
    }
    
    // Guardar temporal procesado
    final tempPath = '${Directory.systemTemp.path}/processed_${DateTime.now().millisecondsSinceEpoch}.png';
    await File(tempPath).writeAsBytes(processedBytes);
    
    return tempPath;
  }
}
