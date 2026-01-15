import 'dart:io';
import 'dart:typed_data';

/// Helper para operaciones de archivos en plataformas IO
class FileHelper {
  static Future<Uint8List> readFileAsBytes(String path) async {
    final file = File(path);
    return await file.readAsBytes();
  }

  static Future<void> writeFileAsBytes(String path, Uint8List bytes) async {
    final file = File(path);
    await file.writeAsBytes(bytes);
  }

  static String getSystemTempPath() {
    return Directory.systemTemp.path;
  }
}
