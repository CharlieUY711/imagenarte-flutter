import 'dart:io';
import 'dart:typed_data';
import 'package:exif/exif.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;

/// Sanitiza metadatos EXIF de una imagen
class ExifSanitizer {
  /// Elimina todos los metadatos EXIF de una imagen
  /// 
  /// [imagePath]: Ruta de la imagen a sanitizar
  /// [format]: Formato de salida ('jpg', 'png'). Si es null, intenta detectar del archivo original
  /// [quality]: Calidad para JPG (1-100), ignorado para PNG
  Future<String> sanitize(
    String imagePath, {
    String? format,
    int quality = 95,
  }) async {
    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    
    // Decodificar imagen
    final image = img.decodeImage(bytes);
    if (image == null) {
      throw Exception('No se pudo decodificar la imagen');
    }

    // Detectar formato si no se especifica
    String outputFormat = format ?? _detectFormat(imagePath);
    
    // Codificar sin metadatos (crea nueva imagen limpia)
    Uint8List cleanBytes;
    String extension;
    
    switch (outputFormat.toLowerCase()) {
      case 'png':
        cleanBytes = Uint8List.fromList(img.encodePng(image));
        extension = 'png';
        break;
      case 'jpg':
      case 'jpeg':
      default:
        cleanBytes = Uint8List.fromList(img.encodeJpg(image, quality: quality));
        extension = 'jpg';
        break;
    }
    
    // Guardar en archivo temporal
    final tempPath = '${imagePath}_clean.$extension';
    await File(tempPath).writeAsBytes(cleanBytes);
    
    return tempPath;
  }

  /// Detecta el formato de una imagen desde su extensión
  String _detectFormat(String imagePath) {
    final ext = path.extension(imagePath).toLowerCase();
    if (ext == '.png') return 'png';
    if (ext == '.jpg' || ext == '.jpeg') return 'jpg';
    // Por defecto, usar JPG
    return 'jpg';
  }
}
