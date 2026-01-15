import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:core/domain/operation.dart';

/// Operación: Crop inteligente
/// 
/// Aplica recortes basados en presets (1:1, 16:9, 4:3, etc.)
class SmartCropOp {
  /// Aplica crop inteligente
  /// 
  /// params:
  ///   - aspectRatio: String ('1:1', '16:9', '4:3', etc.)
  Future<String?> apply(String imagePath, OperationParams params) async {
    final aspectRatio = params.get<String>('aspectRatio') ?? '1:1';
    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    
    final image = img.decodeImage(bytes);
    if (image == null) return null;

    // Parsear aspect ratio
    final parts = aspectRatio.split(':');
    if (parts.length != 2) return null;
    
    final targetAspect = double.parse(parts[0]) / double.parse(parts[1]);
    final currentAspect = image.width / image.height;

    int cropWidth = image.width;
    int cropHeight = image.height;
    int offsetX = 0;
    int offsetY = 0;

    if (currentAspect > targetAspect) {
      // Imagen más ancha, recortar laterales
      cropWidth = (image.height * targetAspect).round();
      offsetX = (image.width - cropWidth) ~/ 2;
    } else {
      // Imagen más alta, recortar arriba/abajo
      cropHeight = (image.width / targetAspect).round();
      offsetY = (image.height - cropHeight) ~/ 2;
    }

    final cropped = img.copyCrop(
      image,
      x: offsetX,
      y: offsetY,
      width: cropWidth,
      height: cropHeight,
    );

    final outputPath = '${imagePath}_cropped.jpg';
    await File(outputPath).writeAsBytes(img.encodeJpg(cropped));
    
    return outputPath;
  }
}
