import 'package:core/privacy/exif_sanitizer.dart';

/// Caso de uso: Sanitizar metadatos EXIF de una imagen
class SanitizeMetadata {
  final ExifSanitizer _exifSanitizer;

  SanitizeMetadata(this._exifSanitizer);

  Future<String> execute(String imagePath) async {
    return await _exifSanitizer.sanitize(imagePath);
  }
}
