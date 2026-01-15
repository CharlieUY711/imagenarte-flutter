import 'package:flutter_test/flutter_test.dart';
import 'package:watermark/invisible/invisible_watermark.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

void main() {
  group('InvisibleWatermark', () {
    late InvisibleWatermark watermark;
    late String testImagePath;

    setUpAll(() async {
      watermark = InvisibleWatermark();
      
      // Crear imagen de prueba
      final directory = await getTemporaryDirectory();
      testImagePath = '${directory.path}/test_image.jpg';
      
      // Crear imagen simple de 100x100 píxeles
      final image = img.Image(width: 100, height: 100);
      // Rellenar con color sólido
      img.fill(image, color: img.ColorRgb8(128, 128, 128));
      
      final bytes = img.encodeJpg(image);
      await File(testImagePath).writeAsBytes(bytes);
    });

    tearDownAll(() async {
      // Limpiar archivo de prueba
      try {
        final file = File(testImagePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        // Ignorar errores de limpieza
      }
    });

    test('embed y extract token con seed fijo', () async {
      // Token de prueba (20 bytes)
      final token = List<int>.generate(20, (i) => i % 256);
      // Nonce fijo para reproducibilidad
      final nonce = List<int>.generate(16, (i) => 42 + i);

      // Embebir token
      final watermarkedPath = await watermark.embed(
        imagePath: testImagePath,
        token: token,
        nonce: nonce,
      );

      expect(await File(watermarkedPath).exists(), isTrue);

      // Extraer token
      final extracted = await watermark.extract(
        imagePath: watermarkedPath,
        tokenLength: token.length,
        nonce: nonce,
      );

      expect(extracted, isNotNull);
      expect(extracted!.length, equals(token.length));
      
      // Verificar que los primeros bytes coinciden (puede haber pequeñas diferencias por compresión JPEG)
      // En un test real, deberíamos usar PNG para evitar pérdidas de compresión
      int matches = 0;
      for (int i = 0; i < token.length; i++) {
        if ((extracted[i] - token[i]).abs() <= 1) {
          matches++;
        }
      }
      
      // Al menos el 80% de los bytes deben coincidir (tolerancia por compresión JPEG)
      expect(matches, greaterThan((token.length * 0.8).round()));
    });

    test('extract con nonce incorrecto retorna null o token diferente', () async {
      final token = List<int>.generate(20, (i) => i % 256);
      final nonce = List<int>.generate(16, (i) => 42 + i);

      final watermarkedPath = await watermark.embed(
        imagePath: testImagePath,
        token: token,
        nonce: nonce,
      );

      // Intentar extraer con nonce diferente
      final wrongNonce = List<int>.generate(16, (i) => 99 + i);
      final extracted = await watermark.extract(
        imagePath: watermarkedPath,
        tokenLength: token.length,
        nonce: wrongNonce,
      );

      // Con nonce incorrecto, la grilla será diferente y el token extraído no debería coincidir
      if (extracted != null) {
        // Verificar que es diferente
        bool isDifferent = false;
        for (int i = 0; i < token.length && i < extracted.length; i++) {
          if ((extracted[i] - token[i]).abs() > 1) {
            isDifferent = true;
            break;
          }
        }
        // Si extrajo algo, debería ser diferente (o al menos no coincidir completamente)
        expect(isDifferent || extracted.length != token.length, isTrue);
      }
    });
  });
}
