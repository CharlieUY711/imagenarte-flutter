import 'package:core/domain/export_profile.dart';
import 'package:core/domain/export_manifest.dart';
import 'package:core/domain/operation.dart';
import 'package:core/privacy/exif_sanitizer.dart';
import 'package:core/privacy/watermark_token.dart';
import 'package:watermark/visible/visible_watermark.dart';
import 'package:watermark/invisible/invisible_watermark.dart';

/// Caso de uso: Exportar imagen con todas las opciones de privacidad (stub para web)
/// 
/// En web, retorna la ruta sin modificar (NO-OP)
class ExportMedia {
  final ExifSanitizer _exifSanitizer;
  final VisibleWatermark _visibleWatermark;
  final InvisibleWatermark _invisibleWatermark;

  ExportMedia(
    this._exifSanitizer,
    this._visibleWatermark,
    this._invisibleWatermark,
  );

  /// Exporta imagen con todas las opciones configuradas (NO-OP en web)
  /// 
  /// En web, simplemente retorna la ruta de salida sin procesar
  Future<String> execute({
    required String imagePath,
    required String outputPath,
    required ExportProfile profile,
    List<Operation> operations = const [],
    String? sessionId,
  }) async {
    // En web, retornar la ruta de salida sin modificar (NO-OP)
    return outputPath;
  }
}
