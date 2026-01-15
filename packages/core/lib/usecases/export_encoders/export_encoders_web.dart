import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Encoders de imagen para web
/// 
/// NO soporta WebP (usa PNG o JPG como alternativa)
class ExportEncoders {
  /// Codifica una imagen en el formato especificado
  /// 
  /// [image]: Imagen decodificada
  /// [format]: 'png', 'jpg', 'jpeg' (webp se convierte a png)
  /// [quality]: Calidad para JPG (1-100), ignorado para PNG
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
        // En web, WebP no está disponible, usar PNG como alternativa
        return Uint8List.fromList(img.encodePng(image));
      default:
        // Por defecto JPG
        return Uint8List.fromList(img.encodeJpg(image, quality: quality));
    }
  }
}
