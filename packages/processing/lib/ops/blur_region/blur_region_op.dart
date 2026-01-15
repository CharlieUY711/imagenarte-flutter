import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:core/domain/operation.dart';

/// Operación: Blur selectivo en una región
/// 
/// Por ahora aplica blur general
/// En el futuro permitirá marcar zonas específicas
class BlurRegionOp {
  /// Aplica blur a la imagen
  /// 
  /// params:
  ///   - intensity: int (1-10, por defecto 5)
  ///   - region: Map con x, y, width, height (futuro)
  Future<String?> apply(String imagePath, OperationParams params) async {
    final intensity = params.get<int>('intensity') ?? 5;
    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    
    final image = img.decodeImage(bytes);
    if (image == null) return null;

    // Blur simple usando convolución
    final radius = intensity.clamp(1, 10);
    final blurred = img.gaussianBlur(image, radius: radius);

    final outputPath = '${imagePath}_blurred.jpg';
    await File(outputPath).writeAsBytes(img.encodeJpg(blurred));
    
    return outputPath;
  }
}
