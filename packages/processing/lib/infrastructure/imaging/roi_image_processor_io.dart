import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:core/domain/roi.dart';

/// Procesador de imágenes que aplica efectos SOLO en ROIs
class RoiImageProcessor {
  /// Aplica pixelado SOLO en las ROIs especificadas
  /// 
  /// [imageBytes]: Bytes de la imagen original
  /// [rois]: Lista de ROIs donde aplicar el efecto
  /// [intensity]: Intensidad del pixelado (1-10)
  /// 
  /// Retorna bytes de la imagen procesada
  Future<Uint8List> applyPixelateToRois({
    required Uint8List imageBytes,
    required List<ROI> rois,
    required int intensity,
  }) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('No se pudo decodificar la imagen');
    }

    if (rois.isEmpty) {
      // Si no hay ROIs, retornar imagen sin cambios
      return imageBytes;
    }

    // Crear una copia de la imagen
    final processed = image.clone();

    // Aplicar pixelado en cada ROI
    for (final roi in rois) {
      final rect = roi.toAbsolute(image.width, image.height);
      
      // Recortar región
      final cropped = img.copyCrop(
        processed,
        rect.x,
        rect.y,
        rect.width,
        rect.height,
      );

      // Aplicar pixelado
      final pixelSize = (intensity * 2).clamp(2, 20);
      final small = img.copyResize(
        cropped,
        width: cropped.width ~/ pixelSize,
        height: cropped.height ~/ pixelSize,
      );
      final pixelated = img.copyResize(
        small,
        width: cropped.width,
        height: cropped.height,
        interpolation: img.Interpolation.nearest,
      );

      // Componer de vuelta en la imagen original
      img.drawImage(
        processed,
        pixelated,
        dstX: rect.x,
        dstY: rect.y,
        blend: true,
      );
    }

    // Codificar como PNG para mantener calidad (el formato se decide en export)
    return Uint8List.fromList(img.encodePng(processed));
  }

  /// Aplica blur SOLO en las ROIs especificadas
  /// 
  /// [imageBytes]: Bytes de la imagen original
  /// [rois]: Lista de ROIs donde aplicar el efecto
  /// [intensity]: Intensidad del blur (1-10)
  /// 
  /// Retorna bytes de la imagen procesada
  Future<Uint8List> applyBlurToRois({
    required Uint8List imageBytes,
    required List<ROI> rois,
    required int intensity,
  }) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('No se pudo decodificar la imagen');
    }

    if (rois.isEmpty) {
      // Si no hay ROIs, retornar imagen sin cambios
      return imageBytes;
    }

    // Crear una copia de la imagen
    final processed = image.clone();

    // Aplicar blur en cada ROI
    for (final roi in rois) {
      final rect = roi.toAbsolute(image.width, image.height);
      
      // Recortar región
      final cropped = img.copyCrop(
        processed,
        rect.x,
        rect.y,
        rect.width,
        rect.height,
      );

      // Aplicar blur
      final radius = intensity.clamp(1, 10);
      final blurred = img.gaussianBlur(cropped, radius);

      // Componer de vuelta en la imagen original
      img.drawImage(
        processed,
        blurred,
        dstX: rect.x,
        dstY: rect.y,
        blend: true,
      );
    }

    // Codificar como PNG para mantener calidad (el formato se decide en export)
    return Uint8List.fromList(img.encodePng(processed));
  }

  /// Codifica una imagen en el formato especificado
  /// 
  /// [imageBytes]: Bytes de la imagen (debe ser decodificable)
  /// [format]: 'jpg' o 'png'
  /// [quality]: Calidad para JPG (1-100), ignorado para PNG
  Future<Uint8List> encodeImage({
    required Uint8List imageBytes,
    required String format,
    int quality = 85,
  }) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('No se pudo decodificar la imagen');
    }

    switch (format.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return Uint8List.fromList(img.encodeJpg(image, quality: quality));
      case 'png':
        return Uint8List.fromList(img.encodePng(image));
      default:
        throw Exception('Formato no soportado: $format');
    }
  }
}
