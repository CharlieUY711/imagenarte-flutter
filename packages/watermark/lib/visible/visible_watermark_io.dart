import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Watermark visible sobre la imagen
class VisibleWatermark {
  /// Aplica un watermark visible de texto
  Future<String> apply({
    required String imagePath,
    required String text,
  }) async {
    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    
    final image = img.decodeImage(bytes);
    if (image == null) throw Exception('No se pudo decodificar la imagen');

    // Dibujar texto en la esquina inferior derecha
    final fontSize = (image.width * 0.05).round().clamp(12, 48);
    img.drawString(
      image,
      img.arial_24,
      image.width - (text.length * fontSize ~/ 2) - 20,
      image.height - fontSize - 20,
      text,
      color: 0xFFFFFFFF, // Blanco en formato ARGB
    );

    final outputPath = '${imagePath}_watermarked.jpg';
    await File(outputPath).writeAsBytes(img.encodeJpg(image));
    
    return outputPath;
  }
}
