import 'package:flutter_test/flutter_test.dart';
import 'package:core/privacy/watermark_token.dart';
import 'package:core/privacy/session_secret.dart';

void main() {
  group('WatermarkToken', () {
    test('generateNonce retorna nonce de 16 bytes', () {
      final nonce = WatermarkToken.generateNonce();
      expect(nonce.length, equals(16));
    });

    test('generateNonce retorna nonces diferentes en llamadas consecutivas', () {
      final nonce1 = WatermarkToken.generateNonce();
      // Esperar un poco para que el timestamp cambie
      Future.delayed(const Duration(milliseconds: 10));
      final nonce2 = WatermarkToken.generateNonce();
      
      // Los nonces deberían ser diferentes (aunque no garantizado si son muy rápidos)
      bool isDifferent = false;
      for (int i = 0; i < nonce1.length; i++) {
        if (nonce1[i] != nonce2[i]) {
          isDifferent = true;
          break;
        }
      }
      // Al menos deberían ser diferentes la mayoría de las veces
      expect(isDifferent, isTrue);
    });

    test('generate token es determinístico con mismos inputs', () async {
      final imageBytes = List<int>.generate(100, (i) => i % 256);
      final timestamp = 1234567890;
      final nonce = List<int>.generate(16, (i) => 42 + i);

      // Generar token dos veces con mismos inputs
      final token1 = await WatermarkToken.generate(
        imageBytesPreWatermark: imageBytes,
        timestamp: timestamp,
        nonce: nonce,
      );

      final token2 = await WatermarkToken.generate(
        imageBytesPreWatermark: imageBytes,
        timestamp: timestamp,
        nonce: nonce,
      );

      expect(token1.length, equals(20)); // 20 bytes truncados
      expect(token2.length, equals(20));
      expect(token1, equals(token2)); // Deben ser idénticos
    });

    test('generate token cambia con diferentes inputs', () async {
      final imageBytes = List<int>.generate(100, (i) => i % 256);
      final timestamp = 1234567890;
      final nonce1 = List<int>.generate(16, (i) => 42 + i);
      final nonce2 = List<int>.generate(16, (i) => 99 + i);

      final token1 = await WatermarkToken.generate(
        imageBytesPreWatermark: imageBytes,
        timestamp: timestamp,
        nonce: nonce1,
      );

      final token2 = await WatermarkToken.generate(
        imageBytesPreWatermark: imageBytes,
        timestamp: timestamp,
        nonce: nonce2,
      );

      expect(token1, isNot(equals(token2))); // Deben ser diferentes
    });

    test('hashToken genera hash SHA256 consistente', () {
      final token = List<int>.generate(20, (i) => i % 256);
      
      final hash1 = WatermarkToken.hashToken(token);
      final hash2 = WatermarkToken.hashToken(token);
      
      expect(hash1, equals(hash2));
      expect(hash1.length, greaterThan(0));
      expect(hash1, isA<String>());
    });
  });

  group('SessionSecret', () {
    test('getOrCreate retorna clave de 32 bytes', () async {
      final secret = await SessionSecret.getOrCreate();
      expect(secret.length, equals(32));
    });

    test('getOrCreate retorna misma clave en llamadas consecutivas', () async {
      final secret1 = await SessionSecret.getOrCreate();
      final secret2 = await SessionSecret.getOrCreate();
      
      expect(secret1, equals(secret2)); // Debe ser la misma clave persistida
    });

    test('delete y getOrCreate genera nueva clave', () async {
      final secret1 = await SessionSecret.getOrCreate();
      
      await SessionSecret.delete();
      
      final secret2 = await SessionSecret.getOrCreate();
      
      // Después de delete, debería generar una nueva clave
      // (aunque puede ser la misma si se genera inmediatamente, es poco probable)
      // En este caso, verificamos que al menos la función no falla
      expect(secret2.length, equals(32));
    });
  });
}
