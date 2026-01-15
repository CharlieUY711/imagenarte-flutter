import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'session_secret.dart';

/// Utilidades para generar tokens de watermark
class WatermarkToken {
  /// Genera un token HMAC-SHA256 para embedding
  /// 
  /// token = HMAC-SHA256(session_secret, export_fingerprint)
  /// export_fingerprint = SHA256(bytes_pre_watermark) + timestamp + nonce
  /// 
  /// Retorna 16-24 bytes truncados del HMAC para embedding
  static Future<List<int>> generate({
    required List<int> imageBytesPreWatermark,
    required int timestamp,
    required List<int> nonce,
  }) async {
    // Calcular export_fingerprint
    final imageHash = sha256.convert(imageBytesPreWatermark);
    final timestampBytes = utf8.encode(timestamp.toString());
    final fingerprintBytes = [
      ...imageHash.bytes,
      ...timestampBytes,
      ...nonce,
    ];
    final exportFingerprint = sha256.convert(fingerprintBytes);

    // Obtener session_secret
    final sessionSecret = await SessionSecret.getOrCreate();

    // Calcular HMAC-SHA256
    final hmac = Hmac(sha256, sessionSecret);
    final tokenFull = hmac.convert(exportFingerprint.bytes);

    // Truncar a 20 bytes (160 bits) para embedding
    // Balance entre robustez y espacio necesario
    return tokenFull.bytes.take(20).toList();
  }

  /// Genera un nonce aleatorio de 16 bytes
  static List<int> generateNonce() {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final random = timestamp.toString() + DateTime.now().toString();
    final hash = sha256.convert(utf8.encode(random));
    return hash.bytes.take(16).toList();
  }

  /// Calcula el hash SHA256 de un token (para almacenar en manifest)
  static String hashToken(List<int> token) {
    final hash = sha256.convert(token);
    return hash.toString();
  }
}
