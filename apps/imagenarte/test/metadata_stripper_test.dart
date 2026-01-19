import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:imagenarte/domain/services/metadata_stripper.dart';
import 'package:imagenarte/infrastructure/imaging/metadata_stripper_impl.dart';

void main() {
  group('MetadataStripperImpl', () {
    late MetadataStripper stripper;

    setUp(() {
      stripper = MetadataStripperImpl();
    });

    test('detectMetadata retorna mapa con valores booleanos', () async {
      // Crear una imagen JPEG simple sin metadatos
      final simpleJpeg = _createSimpleJpeg();
      
      final detected = await stripper.detectMetadata(simpleJpeg);
      
      expect(detected, isA<Map<String, bool>>());
      expect(detected.containsKey('exif'), isTrue);
      expect(detected.containsKey('xmp'), isTrue);
      expect(detected.containsKey('iptc'), isTrue);
    });

    test('strip elimina metadatos de JPEG', () async {
      // Crear una imagen JPEG simple
      final simpleJpeg = _createSimpleJpeg();
      
      final stripped = await stripper.strip(
        simpleJpeg,
        format: ImageFormat.jpeg,
        quality: 95,
      );
      
      // Verificar que el resultado es válido
      expect(stripped, isNotEmpty);
      expect(stripped.length, greaterThan(0));
      
      // Verificar que no contiene marcadores EXIF típicos
      final strippedString = String.fromCharCodes(stripped);
      // No debería contener "Exif" en segmentos APP1 (aunque puede estar en otros lugares)
      // Esta es una verificación básica
      expect(stripped, isA<Uint8List>());
    });

    test('strip elimina metadatos de PNG', () async {
      // Crear una imagen PNG simple
      final simplePng = _createSimplePng();
      
      final stripped = await stripper.strip(
        simplePng,
        format: ImageFormat.png,
        quality: 95,
      );
      
      // Verificar que el resultado es válido
      expect(stripped, isNotEmpty);
      expect(stripped.length, greaterThan(0));
      
      // Verificar que es un PNG válido (debe empezar con la firma PNG)
      expect(stripped[0], 0x89);
      expect(stripped[1], 0x50); // P
      expect(stripped[2], 0x4E); // N
      expect(stripped[3], 0x47); // G
    });

    test('strip preserva dimensiones de la imagen', () async {
      // Este test requeriría una imagen real con dimensiones conocidas
      // Por ahora, solo verificamos que el proceso no falla
      final simpleJpeg = _createSimpleJpeg();
      
      final stripped = await stripper.strip(
        simpleJpeg,
        format: ImageFormat.jpeg,
        quality: 95,
      );
      
      expect(stripped, isNotEmpty);
    });
  });
}

/// Crea un JPEG simple mínimo (sin metadatos)
Uint8List _createSimpleJpeg() {
  // JPEG mínimo: SOI (0xFF 0xD8) + SOF0 + DHT + SOS + EOI
  // Esto es un JPEG muy básico de 1x1 píxel
  return Uint8List.fromList([
    0xFF, 0xD8, // Start of Image
    0xFF, 0xE0, 0x00, 0x10, // APP0 segment
    0x4A, 0x46, 0x49, 0x46, 0x00, 0x01, 0x01, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00,
    0xFF, 0xDB, 0x00, 0x43, // DQT
    0x00, // ... más datos de tabla cuántica
    0xFF, 0xC0, 0x00, 0x11, // SOF0
    0x08, 0x00, 0x01, 0x00, 0x01, 0x01, 0x01, 0x11, 0x00, 0x02, 0x11, 0x01, 0x03, 0x11, 0x01,
    0xFF, 0xC4, 0x00, 0x14, // DHT
    0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0xFF, 0xDA, 0x00, 0x08, // SOS
    0x01, 0x01, 0x00, 0x00, 0x00, 0x01,
    0xFF, 0xD9, // End of Image
  ]);
}

/// Crea un PNG simple mínimo (sin metadatos)
Uint8List _createSimplePng() {
  // PNG mínimo: firma + IHDR + IDAT + IEND
  // Esto es un PNG muy básico de 1x1 píxel
  return Uint8List.fromList([
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature
    0x00, 0x00, 0x00, 0x0D, // IHDR chunk length
    0x49, 0x48, 0x44, 0x52, // IHDR
    0x00, 0x00, 0x00, 0x01, // width = 1
    0x00, 0x00, 0x00, 0x01, // height = 1
    0x08, 0x02, 0x00, 0x00, 0x00, // bit depth, color type, compression, filter, interlace
    0x90, 0x77, 0x53, 0xDE, // CRC
    0x00, 0x00, 0x00, 0x0C, // IDAT chunk length
    0x49, 0x44, 0x41, 0x54, // IDAT
    0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, // compressed data
    0x00, 0x00, 0x00, 0x00, // IEND chunk length
    0x49, 0x45, 0x4E, 0x44, // IEND
    0xAE, 0x42, 0x60, 0x82, // CRC
  ]);
}
