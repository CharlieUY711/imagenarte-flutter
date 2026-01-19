import 'dart:typed_data';

/// Formato de imagen soportado
enum ImageFormat {
  jpeg,
  png,
  webp,
}

/// Interfaz para eliminar metadatos de imágenes
/// 
/// Esta interfaz define el contrato para eliminar metadatos (EXIF, XMP, IPTC)
/// de imágenes, garantizando que el resultado no contenga información sensible.
abstract class MetadataStripper {
  /// Elimina todos los metadatos de la imagen
  /// 
  /// [bytes] - Bytes de la imagen original
  /// [format] - Formato de la imagen (jpeg, png, webp)
  /// [quality] - Calidad de compresión (0-100, solo para JPEG/WebP)
  /// 
  /// Retorna los bytes de la imagen sin metadatos
  /// 
  /// Lanza [Exception] si el formato no es soportado o si hay un error al procesar
  Future<Uint8List> strip(
    Uint8List bytes, {
    required ImageFormat format,
    int quality = 95,
  });

  /// Detecta qué metadatos están presentes en la imagen
  /// 
  /// [bytes] - Bytes de la imagen
  /// 
  /// Retorna un mapa indicando qué metadatos están presentes:
  /// - 'exif': true si hay datos EXIF
  /// - 'xmp': true si hay datos XMP
  /// - 'iptc': true si hay datos IPTC
  Future<Map<String, bool>> detectMetadata(Uint8List bytes);
}
