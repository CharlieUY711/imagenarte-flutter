import 'dart:io';

/// Utilidad para limpiar archivos temporales de una sesión
class TempCleanup {
  /// Elimina un archivo temporal si existe
  static Future<void> deleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Silencioso: no fallar si el archivo ya no existe
    }
  }

  /// Elimina múltiples archivos temporales
  static Future<void> deleteFiles(List<String> paths) async {
    for (final path in paths) {
      await deleteFile(path);
    }
  }
}
