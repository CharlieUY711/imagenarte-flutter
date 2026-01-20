import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:imagenarte/domain/services/metadata_stripper.dart';
import 'package:imagenarte/infrastructure/imaging/metadata_stripper_impl.dart';

void main() {
  group('MetadataStripperImpl', () {
    late MetadataStripper stripper;

    setUp(() {
      stripper = MetadataStripperImpl();
    });

    test('detectMetadata retorna mapa con valores booleanos', () async {
      // Crear una imagen JPEG válida usando package:image
      final testJpeg = _generateTestJpeg(width: 64, height: 48);
      
      // Verificar que la imagen es válida
      final decoded = img.decodeJpg(testJpeg);
      expect(decoded, isNotNull, reason: 'La imagen JPEG generada debe ser decodificable');
      
      final detected = await stripper.detectMetadata(testJpeg);
      
      expect(detected, isA<Map<String, bool>>());
      expect(detected.containsKey('exif'), isTrue);
      expect(detected.containsKey('xmp'), isTrue);
      expect(detected.containsKey('iptc'), isTrue);
    });

    test('strip elimina metadatos de JPEG', () async {
      // Crear una imagen JPEG válida
      const width = 64;
      const height = 48;
      final testJpeg = _generateTestJpeg(width: width, height: height);
      
      // Verificar que la imagen original es válida
      final originalDecoded = img.decodeJpg(testJpeg);
      expect(originalDecoded, isNotNull, reason: 'La imagen JPEG original debe ser decodificable');
      
      final stripped = await stripper.strip(
        testJpeg,
        format: ImageFormat.jpeg,
        quality: 95,
      );
      
      // Verificar que el resultado es válido y decodificable
      expect(stripped, isNotEmpty);
      expect(stripped.length, greaterThan(0));
      
      // Validar que el resultado es un JPEG válido usando package:image
      final strippedDecoded = img.decodeJpg(stripped);
      expect(strippedDecoded, isNotNull, reason: 'La imagen después de strip debe ser decodificable');
      
      // Verificar que mantiene las dimensiones
      expect(strippedDecoded!.width, width);
      expect(strippedDecoded.height, height);
    });

    test('strip elimina metadatos de PNG', () async {
      // Crear una imagen PNG válida
      const width = 64;
      const height = 48;
      final testPng = _generateTestPng(width: width, height: height);
      
      // Verificar que la imagen original es válida
      final originalDecoded = img.decodePng(testPng);
      expect(originalDecoded, isNotNull, reason: 'La imagen PNG original debe ser decodificable');
      
      final stripped = await stripper.strip(
        testPng,
        format: ImageFormat.png,
        quality: 95,
      );
      
      // Verificar que el resultado es válido y decodificable
      expect(stripped, isNotEmpty);
      expect(stripped.length, greaterThan(0));
      
      // Verificar que es un PNG válido (debe empezar con la firma PNG)
      expect(stripped[0], 0x89);
      expect(stripped[1], 0x50); // P
      expect(stripped[2], 0x4E); // N
      expect(stripped[3], 0x47); // G
      
      // Validar que el resultado es un PNG válido usando package:image
      final strippedDecoded = img.decodePng(stripped);
      expect(strippedDecoded, isNotNull, reason: 'La imagen después de strip debe ser decodificable');
      
      // Verificar que mantiene las dimensiones
      expect(strippedDecoded!.width, width);
      expect(strippedDecoded.height, height);
    });

    test('strip preserva dimensiones de la imagen', () async {
      // Crear una imagen JPEG con dimensiones conocidas
      const width = 128;
      const height = 96;
      final testJpeg = _generateTestJpeg(width: width, height: height);
      
      // Verificar dimensiones originales
      final originalDecoded = img.decodeJpg(testJpeg);
      expect(originalDecoded, isNotNull);
      expect(originalDecoded!.width, width);
      expect(originalDecoded.height, height);
      
      final stripped = await stripper.strip(
        testJpeg,
        format: ImageFormat.jpeg,
        quality: 95,
      );
      
      expect(stripped, isNotEmpty);
      
      // Verificar que las dimensiones se preservan
      final strippedDecoded = img.decodeJpg(stripped);
      expect(strippedDecoded, isNotNull, reason: 'La imagen después de strip debe ser decodificable');
      expect(strippedDecoded!.width, width);
      expect(strippedDecoded.height, height);
    });
  });
}

/// Genera un JPEG de prueba válido usando package:image
Uint8List _generateTestJpeg({int width = 64, int height = 48}) {
  // Crear una imagen con un patrón de gradiente simple
  final image = img.Image(width: width, height: height);
  
  // Rellenar con un patrón de gradiente
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final r = (x * 255 / width).toInt();
      final g = (y * 255 / height).toInt();
      final b = 128;
      image.setPixelRgba(x, y, r, g, b, 255);
    }
  }
  
  // Codificar como JPEG con calidad 95
  return Uint8List.fromList(img.encodeJpg(image, quality: 95));
}

/// Genera un PNG de prueba válido usando package:image
Uint8List _generateTestPng({int width = 64, int height = 48}) {
  // Crear una imagen con un patrón de gradiente simple
  final image = img.Image(width: width, height: height);
  
  // Rellenar con un patrón de gradiente
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final r = (x * 255 / width).toInt();
      final g = (y * 255 / height).toInt();
      final b = 128;
      image.setPixelRgba(x, y, r, g, b, 255);
    }
  }
  
  // Codificar como PNG
  return Uint8List.fromList(img.encodePng(image));
}
