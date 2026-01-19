import 'dart:math' as math;
import 'dart:typed_data';
import 'package:imagenarte/domain/classic_adjustments_params.dart';

/// Procesador de ajustes clásicos de imagen
/// 
/// Aplica brillo, contraste, saturación y nitidez a datos de imagen RGBA.
/// Es una clase pura (sin dependencias de UI).
class ClassicAdjustmentsProcessor {
  /// Aplica los ajustes clásicos a los datos de imagen
  /// 
  /// [imageData] - Datos de imagen en formato RGBA (Uint8List)
  /// [width] - Ancho de la imagen
  /// [height] - Alto de la imagen
  /// [params] - Parámetros de ajustes
  /// [mask] - Máscara opcional para aplicar solo a una región (null = toda la imagen)
  /// 
  /// Retorna nuevos datos de imagen con los ajustes aplicados
  static Uint8List apply({
    required Uint8List imageData,
    required int width,
    required int height,
    required ClassicAdjustmentsParams params,
    Uint8List? mask,
  }) {
    // Si todos los ajustes están en default, retornar sin modificar
    if (params.isDefault) {
      return Uint8List.fromList(imageData);
    }

    final result = Uint8List.fromList(imageData);
    final hasMask = mask != null;

    // Aplicar ajustes en orden: brillo -> contraste -> saturación -> nitidez
    // (nitidez al final porque es una convolución que necesita los valores finales)

    // Paso 1: Brillo y Contraste (se pueden combinar)
    if (params.brightness != 0.0 || params.contrast != 0.0) {
      _applyBrightnessAndContrast(
        result,
        width,
        height,
        params.brightness,
        params.contrast,
        hasMask ? mask : null,
      );
    }

    // Paso 2: Saturación
    if (params.saturation != 0.0) {
      _applySaturation(
        result,
        width,
        height,
        params.saturation,
        hasMask ? mask : null,
      );
    }

    // Paso 3: Nitidez (convolución)
    if (params.sharpness > 0.0) {
      _applySharpness(
        result,
        width,
        height,
        params.sharpness,
        hasMask ? mask : null,
      );
    }

    return result;
  }

  /// Aplica brillo y contraste
  static void _applyBrightnessAndContrast(
    Uint8List imageData,
    int width,
    int height,
    double brightness,
    double contrast,
    Uint8List? mask,
  ) {
    // Brillo: sumar offset a RGB
    // brightness está en rango -100..+100, mapear a -255..+255
    final brightnessOffset = (brightness / 100.0) * 255.0;

    // Contraste: factor alrededor de 128
    // contrast está en rango -100..+100
    // factor = 1 + (contrast / 100) * 2 (para -100 => -1, +100 => +3)
    final contrastFactor = 1.0 + (contrast / 100.0) * 2.0;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index = (y * width + x) * 4;

        // Verificar máscara si existe
        if (mask != null) {
          final maskIndex = y * width + x;
          if (mask[maskIndex] == 0) {
            continue;
          }
        }

        final r = imageData[index].toDouble();
        final g = imageData[index + 1].toDouble();
        final b = imageData[index + 2].toDouble();
        final a = imageData[index + 3];

        // Aplicar contraste primero (alrededor de 128)
        double r2 = (r - 128.0) * contrastFactor + 128.0;
        double g2 = (g - 128.0) * contrastFactor + 128.0;
        double b2 = (b - 128.0) * contrastFactor + 128.0;

        // Aplicar brillo (sumar offset)
        r2 += brightnessOffset;
        g2 += brightnessOffset;
        b2 += brightnessOffset;

        // Clamp a 0-255
        imageData[index] = r2.round().clamp(0, 255);
        imageData[index + 1] = g2.round().clamp(0, 255);
        imageData[index + 2] = b2.round().clamp(0, 255);
        // Alpha sin cambios
      }
    }
  }

  /// Aplica saturación
  static void _applySaturation(
    Uint8List imageData,
    int width,
    int height,
    double saturation,
    Uint8List? mask,
  ) {
    // Saturación: convertir a luma y mezclar
    // saturation está en rango -100..+100
    // satFactor = 1 + (saturation / 100) (para -100 => 0, +100 => 2)
    final satFactor = 1.0 + (saturation / 100.0);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index = (y * width + x) * 4;

        // Verificar máscara si existe
        if (mask != null) {
          final maskIndex = y * width + x;
          if (mask[maskIndex] == 0) {
            continue;
          }
        }

        final r = imageData[index].toDouble();
        final g = imageData[index + 1].toDouble();
        final b = imageData[index + 2].toDouble();
        final a = imageData[index + 3];

        // Calcular luma (0.2126*R + 0.7152*G + 0.0722*B)
        final luma = 0.2126 * r + 0.7152 * g + 0.0722 * b;

        // Mezclar: color = luma + (color - luma) * satFactor
        double r2 = luma + (r - luma) * satFactor;
        double g2 = luma + (g - luma) * satFactor;
        double b2 = luma + (b - luma) * satFactor;

        // Clamp a 0-255
        imageData[index] = r2.round().clamp(0, 255);
        imageData[index + 1] = g2.round().clamp(0, 255);
        imageData[index + 2] = b2.round().clamp(0, 255);
        // Alpha sin cambios
      }
    }
  }

  /// Aplica nitidez usando convolución 3x3
  static void _applySharpness(
    Uint8List imageData,
    int width,
    int height,
    double sharpness,
    Uint8List? mask,
  ) {
    // sharpness está en rango 0..100
    final amountNorm = sharpness / 100.0;

    // Kernel de sharpening 3x3
    // [ 0, -1,  0]
    // [-1,  5, -1]
    // [ 0, -1,  0]
    const kernel = [
      [0, -1, 0],
      [-1, 5, -1],
      [0, -1, 0],
    ];

    // Crear copia temporal para la convolución
    final tempData = Uint8List.fromList(imageData);

    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        final index = (y * width + x) * 4;

        // Verificar máscara si existe
        if (mask != null) {
          final maskIndex = y * width + x;
          if (mask[maskIndex] == 0) {
            continue;
          }
        }

        // Aplicar convolución para cada canal RGB
        for (int c = 0; c < 3; c++) {
          double sum = 0.0;
          for (int ky = -1; ky <= 1; ky++) {
            for (int kx = -1; kx <= 1; kx++) {
              final px = x + kx;
              final py = y + ky;
              final pIndex = (py * width + px) * 4;
              final kernelValue = kernel[ky + 1][kx + 1];
              sum += imageData[pIndex + c] * kernelValue;
            }
          }
          // Clamp el resultado de la convolución
          final convolved = sum.round().clamp(0, 255).toDouble();
          final original = imageData[index + c].toDouble();

          // Mezclar: lerp(original, convolved, amountNorm)
          final result = original + (convolved - original) * amountNorm;
          tempData[index + c] = result.round().clamp(0, 255);
        }
        // Alpha sin cambios
        tempData[index + 3] = imageData[index + 3];
      }
    }

    // Copiar resultados de vuelta
    for (int i = 0; i < imageData.length; i++) {
      imageData[i] = tempData[i];
    }
  }
}
