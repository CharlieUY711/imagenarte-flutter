import 'package:core/domain/export_profile.dart';
import 'package:core/domain/export_manifest.dart';
import 'package:core/domain/operation.dart';
import 'package:core/privacy/exif_sanitizer.dart';
import 'package:core/privacy/watermark_token.dart';
import 'package:core/usecases/export_encoders/export_encoders.dart';
import 'package:watermark/visible/visible_watermark.dart';
import 'package:watermark/invisible/invisible_watermark.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;

/// Caso de uso: Exportar imagen con todas las opciones de privacidad
class ExportMedia {
  final ExifSanitizer _exifSanitizer;
  final VisibleWatermark _visibleWatermark;
  final InvisibleWatermark _invisibleWatermark;

  ExportMedia(
    this._exifSanitizer,
    this._visibleWatermark,
    this._invisibleWatermark,
  );

  /// Exporta imagen con todas las opciones configuradas
  /// 
  /// Si invisibleWatermark está habilitado:
  /// - Genera token HMAC-SHA256
  /// - Embebe token en imagen
  /// - Calcula hash final
  /// - Genera manifest si exportManifest está habilitado
  Future<String> execute({
    required String imagePath,
    required String outputPath,
    required ExportProfile profile,
    List<Operation> operations = const [],
    String? sessionId,
  }) async {
    String currentPath = imagePath;
    List<int>? token;
    List<int>? nonce;
    List<int>? imageBytesPreWatermark;

    // 1. Sanitizar metadatos (por defecto ON)
    if (profile.sanitizeMetadata) {
      currentPath = await _exifSanitizer.sanitize(
        currentPath,
        format: profile.format,
        quality: profile.quality,
      );
    }

    // 2. Watermark visible (opcional)
    if (profile.visibleWatermark && profile.visibleWatermarkText != null) {
      currentPath = await _visibleWatermark.apply(
        imagePath: currentPath,
        text: profile.visibleWatermarkText!,
      );
    }

    // 3. Watermark invisible (básico)
    if (profile.invisibleWatermark) {
      // Leer bytes antes de watermark para calcular fingerprint
      final preWatermarkFile = File(currentPath);
      imageBytesPreWatermark = await preWatermarkFile.readAsBytes();
      
      // Generar nonce
      nonce = WatermarkToken.generateNonce();
      
      // Generar token
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      token = await WatermarkToken.generate(
        imageBytesPreWatermark: imageBytesPreWatermark,
        timestamp: timestamp,
        nonce: nonce,
      );
      
      // Embebir token
      currentPath = await _invisibleWatermark.embed(
        imagePath: currentPath,
        token: token,
        nonce: nonce,
      );
    }

    // 4. Codificar en el formato final especificado
    final finalFile = File(currentPath);
    final finalBytes = await finalFile.readAsBytes();
    final finalImage = img.decodeImage(finalBytes);
    
    if (finalImage == null) {
      throw Exception('No se pudo decodificar la imagen final');
    }

    // Codificar en el formato elegido usando el helper condicional
    final encodedBytes = ExportEncoders.encodeImage(
      image: finalImage,
      format: profile.format,
      quality: profile.quality,
    );

    // Guardar al destino final
    await File(outputPath).writeAsBytes(encodedBytes);

    // 5. Calcular hash final y generar manifest si está habilitado
    if (profile.exportManifest && profile.invisibleWatermark && token != null && nonce != null) {
      final exportHashFinal = await ExportManifest.calculateFileHash(outputPath);
      final tokenHash = WatermarkToken.hashToken(token);
      
      final manifest = ExportManifest(
        sessionId: sessionId,
        exportedAt: DateTime.now(),
        operationsApplied: ExportManifest.operationsToSafeStrings(operations),
        exportHashFinal: exportHashFinal,
        tokenHash: tokenHash,
        nonce: nonce,
        tokenLength: token.length,
      );
      
      // Guardar manifest junto al archivo exportado
      final manifestPath = outputPath.replaceAll(RegExp(r'\.[^.]+$'), '_manifest.json');
      await manifest.saveToFile(manifestPath);
    }

    return outputPath;
  }
}
