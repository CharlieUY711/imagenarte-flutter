import 'dart:io';

/// Helper para generar nombres de archivo versionados
/// 
/// Genera nombres como: Nombre_V001.ext, Nombre_V002.ext, etc.
class FileVersioning {
  /// Genera el siguiente nombre de archivo versionado disponible
  /// 
  /// [originalPath] - Ruta completa del archivo original
  /// Retorna la ruta del nuevo archivo versionado
  static Future<String> buildVersionedName(String originalPath) async {
    final file = File(originalPath);
    final directory = file.parent;
    final fileName = file.uri.pathSegments.last;
    
    // Separar nombre y extensión
    final lastDot = fileName.lastIndexOf('.');
    if (lastDot == -1) {
      // Sin extensión
      return _findNextVersion(directory, fileName, '');
    }
    
    final nameWithoutExt = fileName.substring(0, lastDot);
    final extension = fileName.substring(lastDot);
    
    return _findNextVersion(directory, nameWithoutExt, extension);
  }

  static Future<String> _findNextVersion(
    Directory directory,
    String baseName,
    String extension,
  ) async {
    int version = 1;
    String versionedName;
    File versionedFile;
    
    do {
      final versionStr = version.toString().padLeft(3, '0');
      versionedName = '${baseName}_V$versionStr$extension';
      versionedFile = File('${directory.path}${Platform.pathSeparator}$versionedName');
      version++;
    } while (await versionedFile.exists() && version < 1000);
    
    return versionedFile.path;
  }
}
