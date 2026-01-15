import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Encoders de imagen para plataformas IO (mobile/desktop)
/// 
/// Incluye soporte para WebP
class ExportEncoders {
  /// Codifica una imagen en el formato especificado
  /// 
  /// [image]: Imagen decodificada
  /// [format]: 'png', 'jpg', 'jpeg', o 'webp'
  /// [quality]: Calidad para JPG/WebP (1-100), ignorado para PNG
  /// 
  /// Retorna bytes codificados
  static Uint8List encodeImage({
    required img.Image image,
    required String format,
    int quality = 85,
  }) {
    switch (format.toLowerCase()) {
      case 'png':
        return Uint8List.fromList(img.encodePng(image));
      case 'jpg':
      case 'jpeg':
        return Uint8List.fromList(img.encodeJpg(image, quality: quality));
      case 'webp':
        return Uint8List.fromList(img.encodeWebP(image, quality: quality));
      default:
        // Por defecto JPG
        return Uint8List.fromList(img.encodeJpg(image, quality: quality));
    }
  }
}
