import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'package:imagenarte/domain/services/metadata_stripper.dart';

/// Implementación de MetadataStripper usando la librería image
/// 
/// Esta implementación:
/// - Decodifica la imagen a pixeles
/// - Aplica la orientación EXIF si existe (bake rotation)
/// - Re-encodifica sin copiar metadatos
/// - Soporta JPEG, PNG y WebP
class MetadataStripperImpl implements MetadataStripper {
  @override
  Future<Uint8List> strip(
    Uint8List bytes, {
    required ImageFormat format,
    int quality = 95,
  }) async {
    // Decodificar imagen usando Flutter's codec (respeta orientación EXIF)
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final uiImage = frame.image;

    // Convertir ui.Image a img.Image (de la librería image)
    final img.Image decodedImage = await _uiImageToImgImage(uiImage);

    // Re-encodificar sin metadatos
    Uint8List outputBytes;
    switch (format) {
      case ImageFormat.jpeg:
        outputBytes = Uint8List.fromList(
          img.encodeJpg(decodedImage, quality: quality),
        );
        break;
      case ImageFormat.png:
        outputBytes = Uint8List.fromList(img.encodePng(decodedImage));
        break;
      case ImageFormat.webp:
        // WebP encoding no está disponible en image 4.7.2+, usar PNG como fallback
        outputBytes = Uint8List.fromList(img.encodePng(decodedImage));
        break;
    }

    return outputBytes;
  }

  @override
  Future<Map<String, bool>> detectMetadata(Uint8List bytes) async {
    final hasExif = _hasExif(bytes);
    final hasXmp = _hasXmp(bytes);
    final hasIptc = _hasIptc(bytes);

    return {
      'exif': hasExif,
      'xmp': hasXmp,
      'iptc': hasIptc,
    };
  }

  /// Convierte ui.Image a img.Image
  Future<img.Image> _uiImageToImgImage(ui.Image uiImage) async {
    final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) {
      throw Exception('No se pudo convertir ui.Image a bytes');
    }

    final pixels = byteData.buffer.asUint8List();
    // Crear imagen y establecer píxeles manualmente (compatible con image 4.7.2+)
    final img.Image decoded = img.Image(width: uiImage.width, height: uiImage.height);
    
    for (int y = 0; y < uiImage.height; y++) {
      for (int x = 0; x < uiImage.width; x++) {
        final index = (y * uiImage.width + x) * 4;
        final r = pixels[index];
        final g = pixels[index + 1];
        final b = pixels[index + 2];
        final a = pixels[index + 3];
        decoded.setPixelRgba(x, y, r, g, b, a);
      }
    }

    return decoded;
  }

  /// Detecta si hay datos EXIF en JPEG
  bool _hasExif(Uint8List bytes) {
    if (bytes.length < 4) return false;

    // JPEG debe empezar con 0xFF 0xD8
    if (bytes[0] != 0xFF || bytes[1] != 0xD8) return false;

    // Buscar segmentos APP1 (0xFFE1) que contienen EXIF
    int i = 2;
    while (i < bytes.length - 1) {
      if (bytes[i] == 0xFF) {
        final marker = bytes[i + 1];
        if (marker == 0xE1) {
          // APP1 segment - verificar si contiene "Exif"
          if (i + 4 < bytes.length) {
            final segmentLength = (bytes[i + 2] << 8) | bytes[i + 3];
            if (i + segmentLength <= bytes.length) {
              final segmentData = bytes.sublist(i + 4, i + segmentLength);
              final segmentString = String.fromCharCodes(segmentData);
              if (segmentString.contains('Exif') || segmentString.contains('EXIF')) {
                return true;
              }
            }
          }
        } else if (marker == 0xE0 || marker == 0xE2 || marker == 0xE3 ||
                   marker == 0xE4 || marker == 0xE5 || marker == 0xE6 ||
                   marker == 0xE7 || marker == 0xE8 || marker == 0xE9 ||
                   marker == 0xEA || marker == 0xEB || marker == 0xEC ||
                   marker == 0xED || marker == 0xEE || marker == 0xEF) {
          // Otros segmentos APP - saltar
          if (i + 2 < bytes.length) {
            final segmentLength = (bytes[i + 2] << 8) | bytes[i + 3];
            i += 2 + segmentLength;
            continue;
          }
        } else if (marker == 0xDA) {
          // Start of Scan - fin de headers
          break;
        }
      }
      i++;
    }

    return false;
  }

  /// Detecta si hay datos XMP
  bool _hasXmp(Uint8List bytes) {
    final bytesString = String.fromCharCodes(bytes);
    // Buscar marcadores típicos de XMP
    return bytesString.contains('http://ns.adobe.com/xap/1.0/') ||
           bytesString.contains('http://ns.adobe.com/xmp/') ||
           bytesString.contains('xpacket') ||
           bytesString.contains('x:xmpmeta');
  }

  /// Detecta si hay datos IPTC
  bool _hasIptc(Uint8List bytes) {
    if (bytes.length < 4) return false;

    // JPEG: buscar en segmentos APP13 (0xFFED)
    if (bytes[0] == 0xFF && bytes[1] == 0xD8) {
      int i = 2;
      while (i < bytes.length - 1) {
        if (bytes[i] == 0xFF && bytes[i + 1] == 0xED) {
          // APP13 segment - puede contener IPTC
          if (i + 4 < bytes.length) {
            final segmentData = bytes.sublist(i + 4);
            final segmentString = String.fromCharCodes(segmentData);
            if (segmentString.contains('Photoshop') ||
                segmentString.contains('8BIM') ||
                segmentString.contains('IPTC')) {
              return true;
            }
          }
        } else if (bytes[i] == 0xFF && bytes[i + 1] == 0xDA) {
          // Start of Scan
          break;
        }
        i++;
      }
    }

    // PNG: buscar chunks tEXt, zTXt, iTXt
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      int i = 8; // Después del header PNG
      while (i < bytes.length - 8) {
        final chunkLength = (bytes[i] << 24) |
                           (bytes[i + 1] << 16) |
                           (bytes[i + 2] << 8) |
                           bytes[i + 3];
        final chunkType = String.fromCharCodes(bytes.sublist(i + 4, i + 8));
        if (chunkType == 'tEXt' || chunkType == 'zTXt' || chunkType == 'iTXt') {
          // Verificar si contiene datos IPTC
          if (i + 8 + chunkLength <= bytes.length) {
            final chunkData = bytes.sublist(i + 8, i + 8 + chunkLength);
            final chunkString = String.fromCharCodes(chunkData);
            if (chunkString.contains('IPTC') || chunkString.contains('iptc')) {
              return true;
            }
          }
        }
        i += 8 + chunkLength + 4; // +4 para CRC
        if (i >= bytes.length) break;
      }
    }

    return false;
  }
}
