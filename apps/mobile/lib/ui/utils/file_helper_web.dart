import 'dart:typed_data';

/// Helper para operaciones de archivos en web (stub)
/// En web, las operaciones de archivos no están disponibles
class FileHelper {
  static Future<Uint8List> readFileAsBytes(String path) async {
    throw UnsupportedError('File operations not supported on web. Use imageBytes instead.');
  }

  static Future<void> writeFileAsBytes(String path, Uint8List bytes) async {
    throw UnsupportedError('File operations not supported on web.');
  }

  static String getSystemTempPath() {
    throw UnsupportedError('System temp path not available on web.');
  }
}
