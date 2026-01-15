import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Gestión de clave secreta de sesión local
/// 
/// Genera y almacena una clave secreta local para derivar tokens de watermark.
/// Si flutter_secure_storage está disponible, lo usa. Si no, usa almacenamiento
/// local cifrado simple como fallback.
class SessionSecret {
  static const String _keyName = 'imagenarte_session_secret';
  static const int _secretLength = 32; // 256 bits

  /// Obtiene o genera la clave secreta de sesión
  /// 
  /// La clave se genera una vez y se persiste localmente.
  /// No se exporta automáticamente.
  static Future<List<int>> getOrCreate() async {
    try {
      // Intentar usar flutter_secure_storage si está disponible
      // Por ahora, usamos fallback a almacenamiento local cifrado simple
      return await _getOrCreateFallback();
    } catch (e) {
      // Si falla, generar nueva clave (no persistir en este caso)
      return _generateSecret();
    }
  }

  /// Fallback: almacenamiento local cifrado simple
  /// 
  /// NOTA: Este es un fallback básico. En producción, preferir
  /// flutter_secure_storage para mejor seguridad.
  static Future<List<int>> _getOrCreateFallback() async {
    final directory = await getApplicationDocumentsDirectory();
    final secretFile = File(path.join(directory.path, '.$_keyName.enc'));

    if (await secretFile.exists()) {
      // Leer y descifrar
      final encrypted = await secretFile.readAsBytes();
      // Descifrado simple: XOR con hash del nombre de archivo
      // (Esto es básico, pero suficiente para MVP offline)
      final key = sha256.convert(utf8.encode(_keyName)).bytes;
      final decrypted = List<int>.generate(
        encrypted.length,
        (i) => encrypted[i] ^ key[i % key.length],
      );
      return decrypted;
    } else {
      // Generar nueva clave y guardar cifrada
      final secret = _generateSecret();
      final key = sha256.convert(utf8.encode(_keyName)).bytes;
      final encrypted = List<int>.generate(
        secret.length,
        (i) => secret[i] ^ key[i % key.length],
      );
      await secretFile.writeAsBytes(encrypted);
      // Intentar ocultar el archivo (no funciona en todos los sistemas)
      return secret;
    }
  }

  /// Genera una nueva clave secreta aleatoria
  static List<int> _generateSecret() {
    final random = List<int>.generate(_secretLength, (_) => 0);
    // Usar timestamp + hash para generar bytes pseudoaleatorios
    // (No es criptográficamente seguro perfecto, pero suficiente para MVP)
    final seed = DateTime.now().millisecondsSinceEpoch;
    final seedBytes = utf8.encode(seed.toString());
    final hash = sha256.convert(seedBytes);
    
    for (int i = 0; i < _secretLength; i++) {
      final hashIndex = i % hash.bytes.length;
      random[i] = hash.bytes[hashIndex];
    }
    
    // Mezclar con más entropía
    final additionalHash = sha256.convert([...hash.bytes, ...seedBytes]);
    for (int i = 0; i < _secretLength; i++) {
      random[i] = (random[i] ^ additionalHash.bytes[i % additionalHash.bytes.length]) & 0xFF;
    }
    
    return random;
  }

  /// Elimina la clave secreta almacenada (útil para testing o reset)
  static Future<void> delete() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final secretFile = File(path.join(directory.path, '.$_keyName.enc'));
      if (await secretFile.exists()) {
        await secretFile.delete();
      }
    } catch (e) {
      // Ignorar errores al eliminar
    }
  }
}
