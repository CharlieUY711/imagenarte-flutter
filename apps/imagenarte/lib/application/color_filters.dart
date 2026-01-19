import 'dart:typed_data';
import 'package:imagenarte/application/editor_ui_state.dart';

/// Aplica un filtro de color a los datos de imagen
/// 
/// [imageData] - Datos de imagen (Uint8ClampedArray o equivalente)
/// [width] - Ancho de la imagen
/// [height] - Alto de la imagen
/// [presetType] - Tipo de preset de color
/// [intensity] - Intensidad del filtro (0.0-1.0)
/// [mask] - Máscara opcional para aplicar solo a una región (null = toda la imagen)
/// 
/// Retorna nuevos datos de imagen con el filtro aplicado
Uint8List applyColorPreset({
  required Uint8List imageData,
  required int width,
  required int height,
  required ColorMode presetType,
  required double intensity,
  Uint8List? mask,
}) {
  // Si es Original, retornar sin modificar
  if (presetType == ColorMode.color) {
    return Uint8List.fromList(imageData);
  }

  // Si intensidad es 0, retornar original
  if (intensity <= 0.0) {
    return Uint8List.fromList(imageData);
  }

  final result = Uint8List.fromList(imageData);
  final hasMask = mask != null;

  // Procesar cada pixel
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final index = (y * width + x) * 4;
      
      // Verificar máscara si existe
      if (hasMask) {
        final maskIndex = y * width + x;
        if (mask[maskIndex] == 0) {
          // Pixel fuera de la máscara, saltar
          continue;
        }
      }

      final r = imageData[index];
      final g = imageData[index + 1];
      final b = imageData[index + 2];
      final a = imageData[index + 3];

      // Aplicar filtro según preset
      int r2, g2, b2;
      switch (presetType) {
        case ColorMode.grayscale:
          // Luma = 0.299*R + 0.587*G + 0.114*B
          final luma = (0.299 * r + 0.587 * g + 0.114 * b).round();
          r2 = luma;
          g2 = luma;
          b2 = luma;
          break;
        
        case ColorMode.sepia:
          // Fórmulas sepia
          r2 = ((0.393 * r + 0.769 * g + 0.189 * b)).round().clamp(0, 255);
          g2 = ((0.349 * r + 0.686 * g + 0.168 * b)).round().clamp(0, 255);
          b2 = ((0.272 * r + 0.534 * g + 0.131 * b)).round().clamp(0, 255);
          break;
        
        case ColorMode.blackAndWhite:
          // Paso 1: convertir a grises (luma)
          final luma = (0.299 * r + 0.587 * g + 0.114 * b);
          // Paso 2: contraste fuerte sin threshold duro
          // y = (luma - 128) * C + 128
          const contrastFactor = 1.8;
          final y = ((luma - 128) * contrastFactor + 128).clamp(0.0, 255.0).round();
          r2 = y;
          g2 = y;
          b2 = y;
          break;
        
        case ColorMode.color:
          // No debería llegar aquí, pero por seguridad
          r2 = r;
          g2 = g;
          b2 = b;
          break;
      }

      // Mezclar por intensidad: lerp(pixelOriginal, pixelFiltrado, intensity)
      if (intensity >= 1.0) {
        // Intensidad completa
        result[index] = r2;
        result[index + 1] = g2;
        result[index + 2] = b2;
      } else {
        // Mezcla lineal
        result[index] = (r + (r2 - r) * intensity).round().clamp(0, 255);
        result[index + 1] = (g + (g2 - g) * intensity).round().clamp(0, 255);
        result[index + 2] = (b + (b2 - b) * intensity).round().clamp(0, 255);
      }
      result[index + 3] = a; // Alpha sin cambios
    }
  }

  return result;
}
