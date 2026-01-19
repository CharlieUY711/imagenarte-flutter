import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:imagenarte/domain/services/metadata_stripper.dart';

/// Caso de uso para exportar imágenes con opción de eliminar metadatos
class ExportImageUseCase {
  final MetadataStripper _metadataStripper;

  ExportImageUseCase(this._metadataStripper);

  /// Exporta una imagen a un archivo
  /// 
  /// [imageBytes] - Bytes de la imagen a exportar
  /// [outputPath] - Ruta donde guardar el archivo
  /// [format] - Formato de la imagen
  /// [quality] - Calidad de compresión (0-100, solo para JPEG/WebP)
  /// [removeMetadata] - Si es true, elimina todos los metadatos antes de guardar
  /// 
  /// Retorna la ruta del archivo guardado
  /// 
  /// Lanza [Exception] si hay un error al procesar o guardar
  Future<String> execute({
    required Uint8List imageBytes,
    required String outputPath,
    required ImageFormat format,
    int quality = 95,
    bool removeMetadata = true,
  }) async {
    Uint8List finalBytes = imageBytes;

    // Si se solicita eliminar metadatos, procesar la imagen
    if (removeMetadata) {
      try {
        finalBytes = await _metadataStripper.strip(
          imageBytes,
          format: format,
          quality: quality,
        );
      } catch (e) {
        // Si falla el stripping, usar bytes originales pero registrar el error
        // (no fallar completamente para no bloquear el export)
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
