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
      text,
      font: img.arial_24,
      x: image.width - (text.length * fontSize ~/ 2) - 20,
      y: image.height - fontSize - 20,
      color: img.ColorRgb8(255, 255, 255),
    );

    final outputPath = '${imagePath}_watermarked.jpg';
    await File(outputPath).writeAsBytes(img.encodeJpg(image));
    
    return outputPath;
  }
}
