/// Perfil de exportación con todas las opciones
class ExportProfile {
  final String format; // 'jpg', 'png', 'webp'
  final int quality; // 0-100
  final bool sanitizeMetadata; // Limpiar EXIF por defecto
  final bool visibleWatermark;
  final String? visibleWatermarkText;
  final bool invisibleWatermark;
  final bool exportManifest; // Exportar comprobante (manifest.json)

  ExportProfile({
    this.format = 'jpg',
    this.quality = 85,
    this.sanitizeMetadata = true,
    this.visibleWatermark = false,
    this.visibleWatermarkText,
    this.invisibleWatermark = false,
    this.exportManifest = false,
  });

  ExportProfile copyWith({
    String? format,
    int? quality,
    bool? sanitizeMetadata,
    bool? visibleWatermark,
    String? visibleWatermarkText,
    bool? invisibleWatermark,
    bool? exportManifest,
  }) {
    return ExportProfile(
      format: format ?? this.format,
      quality: quality ?? this.quality,
      sanitizeMetadata: sanitizeMetadata ?? this.sanitizeMetadata,
      visibleWatermark: visibleWatermark ?? this.visibleWatermark,
      visibleWatermarkText: visibleWatermarkText ?? this.visibleWatermarkText,
      invisibleWatermark: invisibleWatermark ?? this.invisibleWatermark,
      exportManifest: exportManifest ?? this.exportManifest,
    );
  }
}
