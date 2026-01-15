import 'dart:typed_data';
import 'package:core/domain/roi.dart';

/// Procesador de imágenes que aplica efectos SOLO en ROIs (stub para web)
/// 
/// En web, retorna la imagen sin modificar (NO-OP)
class RoiImageProcessor {
  /// Aplica pixelado SOLO en las ROIs especificadas (NO-OP en web)
  /// 
  /// [imageBytes]: Bytes de la imagen original
  /// [rois]: Lista de ROIs donde aplicar el efecto
  /// [intensity]: Intensidad del pixelado (1-10)
  /// 
  /// Retorna bytes de la imagen sin modificar
  Future<Uint8List> applyPixelateToRois({
    required Uint8List imageBytes,
    required List<ROI> rois,
    required int intensity,
  }) async {
    // En web, retornar imagen sin cambios (passthrough)
    return imageBytes;
  }

  /// Aplica blur SOLO en las ROIs especificadas (NO-OP en web)
  /// 
  /// [imageBytes]: Bytes de la imagen original
  /// [rois]: Lista de ROIs donde aplicar el efecto
  /// [intensity]: Intensidad del blur (1-10)
  /// 
  /// Retorna bytes de la imagen sin modificar
  Future<Uint8List> applyBlurToRois({
    required Uint8List imageBytes,
    required List<ROI> rois,
    required int intensity,
  }) async {
    // En web, retornar imagen sin cambios (passthrough)
    return imageBytes;
  }

  /// Codifica una imagen en el formato especificado (NO-OP en web)
  /// 
  /// [imageBytes]: Bytes de la imagen (debe ser decodificable)
  /// [format]: 'jpg' o 'png'
  /// [quality]: Calidad para JPG (1-100), ignorado para PNG
  /// 
  /// Retorna bytes de la imagen sin modificar
  Future<Uint8List> encodeImage({
    required Uint8List imageBytes,
    required String format,
    int quality = 85,
  }) async {
    // En web, retornar imagen sin cambios (passthrough)
    return imageBytes;
  }
}
