import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:core/domain/operation.dart';

/// Operación: Pixelar rostro
/// 
/// Por ahora es un stub que aplica un efecto de pixelado general
/// En el futuro usará detección facial real (MediaPipe/MLKit)
class PixelateFaceOp {
  /// Aplica pixelado a la imagen
  /// 
  /// params:
  ///   - intensity: int (1-10, por defecto 5)
  Future<String?> apply(String imagePath, OperationParams params) async {
    final intensity = params.get<int>('intensity') ?? 5;
    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    
    final image = img.decodeImage(bytes);
    if (image == null) return null;

    // Pixelado simple: reducir y ampliar
    final pixelSize = (intensity * 2).clamp(2, 20);
    final small = img.copyResize(
      image,
      width: image.width ~/ pixelSize,
      height: image.height ~/ pixelSize,
    );
    final pixelated = img.copyResize(
      small,
      width: image.width,
      height: image.height,
      interpolation: img.Interpolation.nearest,
    );

    final outputPath = '${imagePath}_pixelated.jpg';
    await File(outputPath).writeAsBytes(img.encodeJpg(pixelated));
    
    return outputPath;
  }
}
