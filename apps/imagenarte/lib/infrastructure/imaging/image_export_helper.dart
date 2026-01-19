import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:imagenarte/domain/services/metadata_stripper.dart';
import 'package:imagenarte/infrastructure/imaging/metadata_stripper_impl.dart';

/// Helper para exportar imágenes con opción de eliminar metadatos
/// 
/// Esta clase centraliza la lógica de exportación para que todos los
/// lugares donde se guardan imágenes usen la misma lógica.
class ImageExportHelper {
  static final MetadataStripper _metadataStripper = MetadataStripperImpl();

  /// Exporta una imagen img.Image a un archivo
  /// 
  /// [image] - Imagen en formato img.Image
  /// [outputPath] - Ruta donde guardar el archivo
  /// [removeMetadata] - Si es true, elimina metadatos antes de guardar
  /// [quality] - Calidad de compresión (0-100, solo para JPEG/WebP)
  /// 
  /// Retorna la ruta del archivo guardado
  static Future<String> exportImage({
    required img.Image image,
    required String outputPath,
    bool removeMetadata = true,
    int quality = 95,
  }) async {
    // Determinar formato según extensión
    final ext = outputPath.toLowerCase();
    ImageFormat format;
    Uint8List bytes;

    if (ext.endsWith('.png')) {
      format = ImageFormat.png;
      bytes = Uint8List.fromList(img.encodePng(image));
    } else if (ext.endsWith('.jpg') || ext.endsWith('.jpeg')) {
      format = ImageFormat.jpeg;
      bytes = Uint8List.fromList(img.encodeJpg(image, quality: quality));
    } else if (ext.endsWith('.webp')) {
      // WebP encoding no está disponible en image 4.7.2+, usar PNG como fallback
      format = ImageFormat.png;
      bytes = Uint8List.fromList(img.encodePng(image));
    } else {
      // Default a PNG
      format = ImageFormat.png;
      bytes = Uint8List.fromList(img.encodePng(image));
    }

    // Si se solicita eliminar metadatos, procesar
    if (removeMetadata) {
      try {
        bytes = await _metadataStripper.strip(
          bytes,
          format: format,
          quality: quality,
        );
      } catch (e) {
        // Si falla el stripping, usar bytes originales pero registrar el error
        debugPrint('Warning: No se pudieron eliminar metadatos: $e');
        // Continuar con bytes originales
      }
    }

    // Guardar archivo
    final file = File(outputPath);
    await file.writeAsBytes(bytes);

    return outputPath;
  }

  /// Exporta bytes de imagen directamente
  /// 
  /// [imageBytes] - Bytes de la imagen
  /// [outputPath] - Ruta donde guardar el archivo
  /// [removeMetadata] - Si es true, elimina metadatos antes de guardar
  /// [quality] - Calidad de compresión (0-100, solo para JPEG/WebP)
  /// 
  /// Retorna la ruta del archivo guardado
  static Future<String> exportImageBytes({
    required Uint8List imageBytes,
    required String outputPath,
    bool removeMetadata = true,
    int quality = 95,
  }) async {
    // Determinar formato según extensión
    final ext = outputPath.toLowerCase();
    ImageFormat format;

    if (ext.endsWith('.png')) {
      format = ImageFormat.png;
    } else if (ext.endsWith('.jpg') || ext.endsWith('.jpeg')) {
      format = ImageFormat.jpeg;
    } else if (ext.endsWith('.webp')) {
      format = ImageFormat.webp;
    } else {
      // Default a PNG
      format = ImageFormat.png;
    }

    Uint8List finalBytes = imageBytes;

    // Si se solicita eliminar metadatos, procesar
    if (removeMetadata) {
      try {
        finalBytes = await _metadataStripper.strip(
          imageBytes,
          format: format,
          quality: quality,
        );
      } catch (e) {
        // Si falla el stripping, usar bytes originales pero registrar el error
        debugPrint('Warning: No se pudieron eliminar metadatos: $e');
        // Continuar con bytes originales
      }
    }

    // Guardar archivo
    final file = File(outputPath);
    await file.writeAsBytes(finalBytes);

    return outputPath;
  }
}
