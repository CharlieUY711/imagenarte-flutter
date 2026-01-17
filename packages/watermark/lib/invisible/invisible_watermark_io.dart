import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:crypto/crypto.dart';
import 'dart:math';

/// Watermark invisible básico usando LSB (Least Significant Bit)
/// 
/// NOTA: Este es un watermark básico/no forense. Sus límites:
/// - Vulnerable a recodificación, rescale, filtros, screenshot, re-encode
/// - No es robusto contra ataques forenses avanzados
/// - Adecuado para MVP y verificación local básica
/// 
/// Para mayor robustez, se requeriría DCT/frecuencia (futuro).
class InvisibleWatermark {
  /// Embebe un token en la imagen usando LSB disperso
  /// 
  /// Estrategia:
  /// - Usa una grilla pseudoaleatoria basada en nonce (seed)
  /// - Modifica solo los LSB de píxeles seleccionados
  /// - Distribuye el token de forma dispersa para reducir visibilidad
  /// 
  /// Retorna la ruta del archivo con watermark embebido
  Future<String> embed({
    required String imagePath,
    required List<int> token,
    required List<int> nonce,
  }) async {
    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    
    // Decodificar imagen
    final image = img.decodeImage(bytes);
    if (image == null) {
      throw Exception('No se pudo decodificar la imagen');
    }

    // Generar grilla pseudoaleatoria basada en nonce
    final seed = _nonceToSeed(nonce);
    final random = Random(seed);
    final positions = _generateSparseGrid(
      width: image.width,
      height: image.height,
      tokenLength: token.length,
      random: random,
    );

    // Embebir token en LSB de píxeles seleccionados
    // Estrategia: 3 bits por píxel (uno por canal RGB)
    // Necesitamos aproximadamente token.length * 8 / 3 píxeles
    int bitIndex = 0;
    for (final pos in positions) {
      if (bitIndex >= token.length * 8) break;
      
      final pixel = image.getPixel(pos.x, pos.y);
      
      // Extraer componentes RGB
      int r = img.getRed(pixel);
      int g = img.getGreen(pixel);
      int b = img.getBlue(pixel);
      
      // Embebir 3 bits (uno por canal)
      if (bitIndex < token.length * 8) {
        final byteIndex = bitIndex ~/ 8;
        final bitOffset = bitIndex % 8;
        final bit = (token[byteIndex] >> (7 - bitOffset)) & 0x01;
        r = (r & 0xFE) | bit;
        bitIndex++;
      }
      
      if (bitIndex < token.length * 8) {
        final byteIndex = bitIndex ~/ 8;
        final bitOffset = bitIndex % 8;
        final bit = (token[byteIndex] >> (7 - bitOffset)) & 0x01;
        g = (g & 0xFE) | bit;
        bitIndex++;
      }
      
      if (bitIndex < token.length * 8) {
        final byteIndex = bitIndex ~/ 8;
        final bitOffset = bitIndex % 8;
        final bit = (token[byteIndex] >> (7 - bitOffset)) & 0x01;
        b = (b & 0xFE) | bit;
        bitIndex++;
      }
      
      // Crear nuevo pixel usando getColor (formato ARGB)
      final newPixel = img.getColor(r, g, b);
      image.setPixel(pos.x, pos.y, newPixel);
    }

    // Codificar imagen de vuelta
    final outputBytes = img.encodeJpg(image, quality: 95);
    
    // Guardar en archivo temporal
    final outputPath = '${imagePath}_watermarked.jpg';
    await File(outputPath).writeAsBytes(outputBytes);
    
    return outputPath;
  }

  /// Extrae un token embebido de la imagen
  /// 
  /// Requiere el nonce original para regenerar la grilla
  Future<List<int>?> extract({
    required String imagePath,
    required int tokenLength,
    required List<int> nonce,
  }) async {
    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    
    final image = img.decodeImage(bytes);
    if (image == null) {
      return null;
    }

    // Regenerar grilla usando el mismo nonce
    final seed = _nonceToSeed(nonce);
    final random = Random(seed);
    final positions = _generateSparseGrid(
      width: image.width,
      height: image.height,
      tokenLength: tokenLength,
      random: random,
    );

    // Extraer bits de LSB
    final extracted = <int>[];
    int bitBuffer = 0;
    int bitCount = 0;
    final totalBits = tokenLength * 8;

    for (final pos in positions) {
      if (bitCount >= totalBits) break;
      
      final pixel = image.getPixel(pos.x, pos.y);
      final r = img.getRed(pixel);
      final g = img.getGreen(pixel);
      final b = img.getBlue(pixel);
      
      // Extraer LSB de cada canal (3 bits por píxel)
      if (bitCount < totalBits) {
        final bit = r & 0x01;
        bitBuffer = (bitBuffer << 1) | bit;
        bitCount++;
      }
      
      if (bitCount < totalBits) {
        final bit = g & 0x01;
        bitBuffer = (bitBuffer << 1) | bit;
        bitCount++;
      }
      
      if (bitCount < totalBits) {
        final bit = b & 0x01;
        bitBuffer = (bitBuffer << 1) | bit;
        bitCount++;
      }
      
      // Cuando tenemos 8 bits, agregar byte
      if (bitCount >= 8 && extracted.length < tokenLength) {
        extracted.add(bitBuffer & 0xFF);
        bitBuffer = 0;
      }
    }

    return extracted.length >= tokenLength 
        ? extracted.take(tokenLength).toList()
        : null;
  }

  /// Convierte nonce a seed para Random
  int _nonceToSeed(List<int> nonce) {
    int seed = 0;
    for (int i = 0; i < nonce.length; i++) {
      seed = (seed << 8) | (nonce[i] & 0xFF);
    }
    return seed;
  }

  /// Genera una grilla dispersa pseudoaleatoria de posiciones
  /// 
  /// Distribuye píxeles de forma que no sean adyacentes para reducir
  /// visibilidad del watermark.
  List<_Position> _generateSparseGrid({
    required int width,
    required int height,
    required int tokenLength,
    required Random random,
  }) {
    final positions = <_Position>[];
    final used = <String>{};
    
    // Necesitamos aproximadamente tokenLength * 3 píxeles
    // (3 bits por píxel, 8 bits por byte)
    final neededPixels = (tokenLength * 8 / 3).ceil();
    
    // Espaciado mínimo entre píxeles (para dispersión)
    final minSpacing = max(10, min(width, height) ~/ 50);
    
    int attempts = 0;
    while (positions.length < neededPixels && attempts < neededPixels * 10) {
      final x = random.nextInt(width);
      final y = random.nextInt(height);
      final key = '$x,$y';
      
      // Verificar que no esté muy cerca de otros píxeles
      bool tooClose = false;
      for (final pos in positions) {
        final dx = (x - pos.x).abs();
        final dy = (y - pos.y).abs();
        if (dx < minSpacing && dy < minSpacing) {
          tooClose = true;
          break;
        }
      }
      
      if (!used.contains(key) && !tooClose) {
        positions.add(_Position(x, y));
        used.add(key);
      }
      
      attempts++;
    }
    
    return positions;
  }

  /// Método legacy para compatibilidad (deprecated)
  /// 
  /// Usar embed() en su lugar
  @Deprecated('Usar embed() en su lugar')
  Future<String> apply(String imagePath) async {
    // Mantener compatibilidad pero no hacer nada real
    return imagePath;
  }
}

/// Posición de píxel
class _Position {
  final int x;
  final int y;
  
  _Position(this.x, this.y);
}
