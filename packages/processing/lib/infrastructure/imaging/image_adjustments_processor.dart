import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:core/domain/roi.dart';
import 'package:core/application/editor_controller.dart';

/// Procesador de ajustes de imagen (brightness, contrast, saturation, color presets)
/// 
/// Soporta aplicación con máscara:
/// - Si se proporciona una ROI, aplica solo dentro de esa región
/// - Si no se proporciona ROI, aplica globalmente a toda la imagen
class ImageAdjustmentsProcessor {
  /// Aplica ajustes a una imagen con soporte de máscara
  /// 
  /// [imageBytes]: Bytes de la imagen original
  /// [brightness]: Ajuste de brillo (-100 a +100, 0 es neutral)
  /// [contrast]: Ajuste de contraste (-100 a +100, 0 es neutral)
  /// [saturation]: Ajuste de saturación (-100 a +100, 0 es neutral)
  /// [colorPreset]: Preset de color a aplicar
  /// [roi]: ROI opcional. Si se proporciona, aplica solo dentro de esta región
  /// [imageWidth]: Ancho de la imagen (necesario para generar máscara)
  /// [imageHeight]: Alto de la imagen (necesario para generar máscara)
  /// 
  /// Retorna bytes de la imagen procesada
  Future<Uint8List> applyAdjustments({
    required Uint8List imageBytes,
    required double brightness,
    required double contrast,
    required double saturation,
    required ColorPreset colorPreset,
    ROI? roi,
    required int imageWidth,
    required int imageHeight,
  }) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('No se pudo decodificar la imagen');
    }

    // Si no hay ajustes ni preset, retornar imagen sin cambios
    if (brightness == 0.0 && contrast == 0.0 && saturation == 0.0 && colorPreset == ColorPreset.color) {
      return imageBytes;
    }

    // Crear una copia de la imagen
    final processed = image.clone();

    if (roi != null) {
      // Aplicar con máscara: solo dentro de la ROI
      await _applyAdjustmentsWithMask(
        processed,
        brightness: brightness,
        contrast: contrast,
        saturation: saturation,
        colorPreset: colorPreset,
        roi: roi,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
      );
    } else {
      // Aplicar globalmente a toda la imagen
      _applyAdjustmentsGlobal(
        processed,
        brightness: brightness,
        contrast: contrast,
        saturation: saturation,
        colorPreset: colorPreset,
      );
    }

    // Codificar como PNG para mantener calidad
    return Uint8List.fromList(img.encodePng(processed));
  }

  /// Aplica ajustes globalmente a toda la imagen
  void _applyAdjustmentsGlobal(
    img.Image image, {
    required double brightness,
    required double contrast,
    required double saturation,
    required ColorPreset colorPreset,
  }) {
    final data = image.data;
    final length = data.length;

    for (int i = 0; i < length; i += 4) {
      int r = data[i];
      int g = data[i + 1];
      int b = data[i + 2];
      int a = data[i + 3];

      // Aplicar preset de color primero
      if (colorPreset != ColorPreset.color) {
        final colorResult = _applyColorPreset(r, g, b, colorPreset);
        r = colorResult.r;
        g = colorResult.g;
        b = colorResult.b;
      }

      // Aplicar ajustes
      if (brightness != 0.0) {
        final brightnessFactor = 1.0 + (brightness / 100.0);
        r = (r * brightnessFactor).clamp(0, 255).round();
        g = (g * brightnessFactor).clamp(0, 255).round();
        b = (b * brightnessFactor).clamp(0, 255).round();
      }

      if (contrast != 0.0) {
        final contrastFactor = (259 * (contrast + 255)) / (255 * (259 - contrast));
        r = ((r - 128) * contrastFactor + 128).clamp(0, 255).round();
        g = ((g - 128) * contrastFactor + 128).clamp(0, 255).round();
        b = ((b - 128) * contrastFactor + 128).clamp(0, 255).round();
      }

      if (saturation != 0.0) {
        final saturationFactor = 1.0 + (saturation / 100.0);
        final gray = (0.299 * r + 0.587 * g + 0.114 * b).round();
        r = ((r - gray) * saturationFactor + gray).clamp(0, 255).round();
        g = ((g - gray) * saturationFactor + gray).clamp(0, 255).round();
        b = ((b - gray) * saturationFactor + gray).clamp(0, 255).round();
      }

      data[i] = r;
      data[i + 1] = g;
      data[i + 2] = b;
      // a permanece igual
    }
  }

  /// Aplica ajustes con máscara (solo dentro de la ROI)
  Future<void> _applyAdjustmentsWithMask(
    img.Image image, {
    required double brightness,
    required double contrast,
    required double saturation,
    required ColorPreset colorPreset,
    required ROI roi,
    required int imageWidth,
    required int imageHeight,
  }) async {
    // Convertir ROI a coordenadas absolutas
    final rect = roi.toAbsolute(imageWidth, imageHeight);
    
    // Crear máscara para la ROI
    final mask = _createMask(
      imageWidth: imageWidth,
      imageHeight: imageHeight,
      roi: roi,
      rect: rect,
    );

    // Aplicar ajustes solo donde la máscara es > 0
    final data = image.data;
    final width = image.width;
    final height = image.height;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final maskValue = mask[y * width + x];
        if (maskValue == 0) continue; // Fuera de la ROI, saltar

        final i = (y * width + x) * 4;
        int r = data[i];
        int g = data[i + 1];
        int b = data[i + 2];
        int a = data[i + 3];

        // Aplicar preset de color primero
        if (colorPreset != ColorPreset.color) {
          final colorResult = _applyColorPreset(r, g, b, colorPreset);
          r = colorResult.r;
          g = colorResult.g;
          b = colorResult.b;
        }

        // Aplicar ajustes
        if (brightness != 0.0) {
          final brightnessFactor = 1.0 + (brightness / 100.0);
          r = (r * brightnessFactor).clamp(0, 255).round();
          g = (g * brightnessFactor).clamp(0, 255).round();
          b = (b * brightnessFactor).clamp(0, 255).round();
        }

        if (contrast != 0.0) {
          final contrastFactor = (259 * (contrast + 255)) / (255 * (259 - contrast));
          r = ((r - 128) * contrastFactor + 128).clamp(0, 255).round();
          g = ((g - 128) * contrastFactor + 128).clamp(0, 255).round();
          b = ((b - 128) * contrastFactor + 128).clamp(0, 255).round();
        }

        if (saturation != 0.0) {
          final saturationFactor = 1.0 + (saturation / 100.0);
          final gray = (0.299 * r + 0.587 * g + 0.114 * b).round();
          r = ((r - gray) * saturationFactor + gray).clamp(0, 255).round();
          g = ((g - gray) * saturationFactor + gray).clamp(0, 255).round();
          b = ((b - gray) * saturationFactor + gray).clamp(0, 255).round();
        }

        data[i] = r;
        data[i + 1] = g;
        data[i + 2] = b;
        // a permanece igual
      }
    }
  }

  /// Crea una máscara binaria para la ROI
  /// 
  /// Retorna una lista de enteros donde 255 = dentro de ROI, 0 = fuera
  List<int> _createMask({
    required int imageWidth,
    required int imageHeight,
    required ROI roi,
    required RectAbsolute rect,
  }) {
    final mask = List<int>.filled(imageWidth * imageHeight, 0);

    if (roi.shape == RoiShape.rect) {
      // Máscara rectangular: simple
      for (int y = rect.y; y < rect.y + rect.height && y < imageHeight; y++) {
        for (int x = rect.x; x < rect.x + rect.width && x < imageWidth; x++) {
          mask[y * imageWidth + x] = 255;
        }
      }
    } else if (roi.shape == RoiShape.ellipse) {
      // Máscara elíptica: verificar si el punto está dentro de la elipse
      final centerX = rect.x + rect.width / 2;
      final centerY = rect.y + rect.height / 2;
      final radiusX = rect.width / 2;
      final radiusY = rect.height / 2;

      for (int y = rect.y; y < rect.y + rect.height && y < imageHeight; y++) {
        for (int x = rect.x; x < rect.x + rect.width && x < imageWidth; x++) {
          final dx = (x - centerX) / radiusX;
          final dy = (y - centerY) / radiusY;
          if (dx * dx + dy * dy <= 1.0) {
            mask[y * imageWidth + x] = 255;
          }
        }
      }
    }

    return mask;
  }

  /// Aplica un preset de color a un píxel RGB
  ({int r, int g, int b}) _applyColorPreset(int r, int g, int b, ColorPreset preset) {
    switch (preset) {
      case ColorPreset.color:
        return (r: r, g: g, b: b);
      case ColorPreset.grayscale:
        // Luminancia: 0.299*R + 0.587*G + 0.114*B
        final lum = (0.299 * r + 0.587 * g + 0.114 * b).round();
        return (r: lum, g: lum, b: lum);
      case ColorPreset.sepia:
        // Sepia: matriz de transformación
        final newR = (0.393 * r + 0.769 * g + 0.189 * b).clamp(0, 255).round();
        final newG = (0.349 * r + 0.686 * g + 0.168 * b).clamp(0, 255).round();
        final newB = (0.272 * r + 0.534 * g + 0.131 * b).clamp(0, 255).round();
        return (r: newR, g: newG, b: newB);
      case ColorPreset.bw:
        // Blanco y negro (alto contraste): luminancia y threshold
        final lum = (0.299 * r + 0.587 * g + 0.114 * b).round();
        final value = lum >= 128 ? 255 : 0;
        return (r: value, g: value, b: value);
    }
  }
}
