import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:imagenarte/domain/transformable_geometry.dart';
import 'package:imagenarte/domain/collage_config.dart';
import 'package:imagenarte/domain/watermark_config.dart';

/// Pipeline de render unificado para preview y export
/// 
/// Este pipeline garantiza que el preview y el resultado final
/// usen exactamente la misma lógica de renderizado.
class ImageRenderPipeline {
  /// Renderiza la imagen con selección aplicada (para corte)
  /// 
  /// [imagePath] - Ruta de la imagen original
  /// [selectionGeometry] - Geometría de selección (opcional)
  /// [freehandPathImage] - Path de selección libre en coordenadas de imagen (opcional)
  /// [isInterior] - true = mantener interior, false = mantener exterior
  /// 
  /// Retorna ui.Image con el corte aplicado
  static Future<ui.Image> renderCrop({
    required String imagePath,
    TransformableGeometry? selectionGeometry,
    Path? freehandPathImage,
    required bool isInterior,
    required Size canvasSize,
    required Size imageSize,
  }) async {
    // Cargar imagen original
    final file = File(imagePath);
    final imageBytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(imageBytes);
    final frame = await codec.getNextFrame();
    final originalImage = frame.image;

    // Calcular rectángulo de destino de la imagen en el canvas (BoxFit.contain)
    final imageDestRect = _calculateImageDestRect(canvasSize, imageSize);

    // Determinar qué path usar para el clip (en coordenadas de canvas)
    Path? clipPathCanvas;
    if (freehandPathImage != null) {
      // Usar path libre: convertir de coordenadas de imagen a canvas
      clipPathCanvas = _convertImagePathToCanvasPath(
        freehandPathImage,
        imageSize,
        imageDestRect,
      );
    } else if (selectionGeometry != null) {
      // Usar geometría de selección: crear path desde geometría
      clipPathCanvas = _createPathFromGeometry(selectionGeometry);
    }

    if (clipPathCanvas == null) {
      // Sin selección: retornar imagen original
      return originalImage;
    }

    // Calcular bounding box del área a recortar
    Rect outputBounds;
    if (isInterior) {
      // Interior: usar bounds del path de selección
      outputBounds = clipPathCanvas.getBounds();
    } else {
      // Exterior: usar tamaño completo del canvas
      outputBounds = Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height);
    }

    // Crear PictureRecorder para render offscreen del tamaño del output
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, outputBounds);

    // Ajustar canvas para que el origen esté en el offset del bounding box
    canvas.translate(-outputBounds.left, -outputBounds.top);

    // Aplicar transformaciones si la geometría tiene rotación
    if (selectionGeometry != null && selectionGeometry.rotation != 0) {
      canvas.save();
      canvas.translate(selectionGeometry.center.dx, selectionGeometry.center.dy);
      canvas.rotate(selectionGeometry.rotation);
      canvas.translate(-selectionGeometry.center.dx, -selectionGeometry.center.dy);
    }

    // Aplicar clip según modo
    if (isInterior) {
      // Interior: clip al path de selección
      canvas.clipPath(clipPathCanvas);
    } else {
      // Exterior: clip inverso (todo excepto el path)
      final fullPath = Path()
        ..addRect(Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height));
      final inversePath = Path.combine(
        PathOperation.difference,
        fullPath,
        clipPathCanvas,
      );
      canvas.clipPath(inversePath);
    }

    // Dibujar imagen con las transformaciones aplicadas
    final paint = Paint()..filterQuality = FilterQuality.high;
    canvas.drawImageRect(
      originalImage,
      Rect.fromLTWH(0, 0, originalImage.width.toDouble(), originalImage.height.toDouble()),
      imageDestRect,
      paint,
    );

    if (selectionGeometry != null && selectionGeometry.rotation != 0) {
      canvas.restore();
    }

    // Finalizar picture y convertir a imagen
    final picture = recorder.endRecording();
    final outputImage = await picture.toImage(
      outputBounds.width.toInt(),
      outputBounds.height.toInt(),
    );

    return outputImage;
  }

  /// Calcula el rectángulo de destino de la imagen en el canvas (BoxFit.contain)
  static Rect _calculateImageDestRect(Size canvasSize, Size imageSize) {
    if (imageSize.width <= 0 || imageSize.height <= 0) {
      return Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height);
    }

    final imageAspect = imageSize.width / imageSize.height;
    final canvasAspect = canvasSize.width / canvasSize.height;

    double width, height;
    if (imageAspect > canvasAspect) {
      width = canvasSize.width;
      height = width / imageAspect;
    } else {
      height = canvasSize.height;
      width = height * imageAspect;
    }

    final left = (canvasSize.width - width) / 2;
    final top = (canvasSize.height - height) / 2;

    return Rect.fromLTWH(left, top, width, height);
  }

  /// Convierte un path de coordenadas de imagen a coordenadas de canvas
  static Path _convertImagePathToCanvasPath(
    Path imagePath,
    Size imageSize,
    Rect imageDestRect,
  ) {
    final scaleX = imageDestRect.width / imageSize.width;
    final scaleY = imageDestRect.height / imageSize.height;

    final canvasPath = Path();
    
    // Muestrear el path y transformar puntos
    final metrics = imagePath.computeMetrics();
    for (final metric in metrics) {
      const sampleStep = 1.0;
      final length = metric.length;
      bool isFirst = true;

      for (double offset = 0; offset <= length; offset += sampleStep) {
        final tangent = metric.getTangentForOffset(offset.clamp(0.0, length));
        if (tangent != null) {
          final point = tangent.position;
          // Transformar de coordenadas de imagen a canvas
          final canvasPoint = Offset(
            imageDestRect.left + (point.dx * scaleX),
            imageDestRect.top + (point.dy * scaleY),
          );

          if (isFirst) {
            canvasPath.moveTo(canvasPoint.dx, canvasPoint.dy);
            isFirst = false;
          } else {
            canvasPath.lineTo(canvasPoint.dx, canvasPoint.dy);
          }
        }
      }
      
      // Cerrar path si está cerrado
      if (imagePath.getBounds().width > 0 && imagePath.getBounds().height > 0) {
        canvasPath.close();
      }
    }

    return canvasPath;
  }

  /// Crea un Path desde TransformableGeometry
  static Path _createPathFromGeometry(TransformableGeometry geometry) {
    final path = Path();

    if (geometry.shape == TransformableShape.circle) {
      final radius = math.min(geometry.size.width, geometry.size.height) / 2;
      path.addOval(Rect.fromCircle(
        center: geometry.center,
        radius: radius,
      ));
    } else {
      // Rectángulo
      path.addRect(geometry.boundingBox);
    }

    return path;
  }

  /// Renderiza un collage basado en la imagen actual
  /// 
  /// [imagePath] - Ruta de la imagen original
  /// [config] - Configuración del collage
  /// 
  /// Retorna ui.Image con el collage aplicado
  static Future<ui.Image> renderCollage({
    required String imagePath,
    required CollageConfig config,
    required Size canvasSize,
    required Size imageSize,
  }) async {
    // Cargar imagen original
    final file = File(imagePath);
    final imageBytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(imageBytes);
    final frame = await codec.getNextFrame();
    final originalImage = frame.image;

    // Calcular rectángulo de destino de la imagen en el canvas (BoxFit.contain)
    final imageDestRect = _calculateImageDestRect(canvasSize, imageSize);

    // Crear PictureRecorder para render offscreen
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height));

    // Dibujar fondo si está configurado
    if (config.backgroundColor != null) {
      final backgroundPaint = Paint()
        ..color = config.backgroundColor!
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height), backgroundPaint);
    }

    // Calcular tamaño de cada celda del grid
    final availableWidth = canvasSize.width - (config.padding * 2);
    final availableHeight = canvasSize.height - (config.padding * 2);
    
    final cellWidth = (availableWidth - (config.spacing * (config.cols - 1))) / config.cols;
    final cellHeight = (availableHeight - (config.spacing * (config.rows - 1))) / config.rows;

    // Dibujar la imagen en cada celda del grid
    final paint = Paint()..filterQuality = FilterQuality.high;
    
    for (int row = 0; row < config.rows; row++) {
      for (int col = 0; col < config.cols; col++) {
        final cellX = config.padding + (col * (cellWidth + config.spacing));
        final cellY = config.padding + (row * (cellHeight + config.spacing));
        final cellRect = Rect.fromLTWH(cellX, cellY, cellWidth, cellHeight);

        // Dibujar imagen en la celda usando BoxFit.cover para llenar la celda
        final cellAspect = cellWidth / cellHeight;
        final imageAspect = imageSize.width / imageSize.height;

        Rect sourceRect;
        Rect destRect;

        if (imageAspect > cellAspect) {
          // Imagen más ancha: ajustar al alto de la celda
          final scaledWidth = cellHeight * imageAspect;
          final offsetX = (imageSize.width - scaledWidth) / 2;
          sourceRect = Rect.fromLTWH(offsetX, 0, scaledWidth, imageSize.height);
          destRect = cellRect;
        } else {
          // Imagen más alta: ajustar al ancho de la celda
          final scaledHeight = cellWidth / imageAspect;
          final offsetY = (imageSize.height - scaledHeight) / 2;
          sourceRect = Rect.fromLTWH(0, offsetY, imageSize.width, scaledHeight);
          destRect = cellRect;
        }

        canvas.drawImageRect(originalImage, sourceRect, destRect, paint);
      }
    }

    // Finalizar picture y convertir a imagen
    final picture = recorder.endRecording();
    final outputImage = await picture.toImage(
      canvasSize.width.toInt(),
      canvasSize.height.toInt(),
    );

    return outputImage;
  }

  /// Aplica watermark a una imagen ya procesada
  /// 
  /// Este método debe llamarse AL FINAL del pipeline, después de aplicar
  /// todos los efectos (blur, pixelate, crops, etc.).
  /// 
  /// [baseImage] - Imagen base ya procesada (ui.Image)
  /// [watermarkConfig] - Configuración del watermark (opcional)
  /// [canvasSize] - Tamaño del canvas original
  /// [imageSize] - Tamaño de la imagen original
  /// 
  /// Retorna ui.Image con el watermark aplicado
  static Future<ui.Image> applyWatermark({
    required ui.Image baseImage,
    WatermarkConfig? watermarkConfig,
    required Size canvasSize,
    required Size imageSize,
  }) async {
    if (watermarkConfig == null || !watermarkConfig.enabled) {
      return baseImage;
    }

    // Crear PictureRecorder para render offscreen
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, baseImage.width.toDouble(), baseImage.height.toDouble()));

    // Dibujar imagen base
    final paint = Paint()..filterQuality = FilterQuality.high;
    canvas.drawImage(
      baseImage,
      Offset.zero,
      paint,
    );

    // Calcular rectángulo de destino de la imagen en el canvas original (BoxFit.contain)
    final imageDestRect = _calculateImageDestRect(canvasSize, imageSize);

    // Mapear geometría del watermark del canvas al tamaño de la imagen final
    final watermarkGeometry = watermarkConfig.transform;
    
    // Calcular escala: de canvasSize a baseImage.size
    final scaleX = baseImage.width / canvasSize.width;
    final scaleY = baseImage.height / canvasSize.height;
    
    // Mapear posición y tamaño del watermark
    final scaledCenter = Offset(
      watermarkGeometry.center.dx * scaleX,
      watermarkGeometry.center.dy * scaleY,
    );
    final scaledSize = Size(
      watermarkGeometry.size.width * scaleX,
      watermarkGeometry.size.height * scaleY,
    );

    // Renderizar watermark
    if (watermarkConfig.type == WatermarkType.text) {
      _drawTextWatermark(
        canvas,
        watermarkConfig,
        scaledCenter,
        scaledSize,
        watermarkGeometry.rotation,
      );
    } else {
      await _drawImageWatermark(
        canvas,
        watermarkConfig,
        scaledCenter,
        scaledSize,
        watermarkGeometry.rotation,
      );
    }

    // Finalizar picture y convertir a imagen
    final picture = recorder.endRecording();
    final outputImage = await picture.toImage(
      baseImage.width,
      baseImage.height,
    );

    return outputImage;
  }

  /// Dibuja watermark de texto en el canvas
  static void _drawTextWatermark(
    Canvas canvas,
    WatermarkConfig config,
    Offset center,
    Size size,
    double rotation,
  ) {
    final text = config.text;
    if (text.isEmpty) return;

    canvas.save();
    
    // Aplicar rotación
    if (rotation != 0) {
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rotation);
      canvas.translate(-center.dx, -center.dy);
    }

    // Calcular tamaño de fuente proporcional
    final fontSize = math.min(size.width / text.length * 1.2, size.height * 0.8);
    
    final textStyle = TextStyle(
      fontSize: fontSize,
      color: config.color.withOpacity(config.opacity),
      fontWeight: FontWeight.w600,
    );

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout(maxWidth: size.width);

    final textOffset = Offset(
      center.dx - size.width / 2 + (size.width - textPainter.width) / 2,
      center.dy - size.height / 2 + (size.height - textPainter.height) / 2,
    );

    // Aplicar sombra si está habilitada
    if (config.shadow != null && config.shadow!.enabled) {
      canvas.save();
      canvas.translate(config.shadow!.offset.dx, config.shadow!.offset.dy);
      
      final shadowStyle = TextStyle(
        fontSize: fontSize,
        color: config.shadow!.color.withOpacity(config.opacity),
        fontWeight: FontWeight.w600,
      );
      final shadowPainter = TextPainter(
        text: TextSpan(text: text, style: shadowStyle),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      shadowPainter.layout(maxWidth: size.width);
      
      // Aplicar blur simulado (múltiples capas)
      final blurLayers = (config.shadow!.blur / 2).round().clamp(1, 5);
      for (int i = 0; i < blurLayers; i++) {
        shadowPainter.paint(canvas, textOffset);
      }
      
      canvas.restore();
    }

    // Aplicar outline si está habilitado
    if (config.outline != null && config.outline!.enabled) {
      final outlineStyle = TextStyle(
        fontSize: fontSize,
        color: config.outline!.color.withOpacity(config.opacity),
        fontWeight: FontWeight.w600,
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = config.outline!.width
          ..color = config.outline!.color.withOpacity(config.opacity),
      );
      final outlinePainter = TextPainter(
        text: TextSpan(text: text, style: outlineStyle),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      outlinePainter.layout(maxWidth: size.width);
      outlinePainter.paint(canvas, textOffset);
    }

    // Dibujar texto principal
    textPainter.paint(canvas, textOffset);

    canvas.restore();
  }

  /// Dibuja watermark de imagen en el canvas
  static Future<void> _drawImageWatermark(
    Canvas canvas,
    WatermarkConfig config,
    Offset center,
    Size size,
    double rotation,
  ) async {
    final imagePath = config.imagePath;
    if (imagePath == null || !File(imagePath).existsSync()) {
      return;
    }

    try {
      final file = File(imagePath);
      final imageBytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(imageBytes);
      final frame = await codec.getNextFrame();
      final logoImage = frame.image;

      canvas.save();

      // Aplicar rotación
      if (rotation != 0) {
        canvas.translate(center.dx, center.dy);
        canvas.rotate(rotation);
        canvas.translate(-center.dx, -center.dy);
      }

      // Calcular rectángulo de destino manteniendo aspect ratio
      final imageAspect = logoImage.width / logoImage.height;
      final sizeAspect = size.width / size.height;

      Rect destRect;
      if (imageAspect > sizeAspect) {
        // Imagen más ancha: ajustar al ancho
        final height = size.width / imageAspect;
        destRect = Rect.fromLTWH(
          center.dx - size.width / 2,
          center.dy - height / 2,
          size.width,
          height,
        );
      } else {
        // Imagen más alta: ajustar al alto
        final width = size.height * imageAspect;
        destRect = Rect.fromLTWH(
          center.dx - width / 2,
          center.dy - size.height / 2,
          width,
          size.height,
        );
      }

      final paint = Paint()
        ..filterQuality = FilterQuality.high
        ..colorFilter = ColorFilter.mode(
          Colors.white.withOpacity(config.opacity),
          BlendMode.modulate,
        );

      canvas.drawImageRect(
        logoImage,
        Rect.fromLTWH(0, 0, logoImage.width.toDouble(), logoImage.height.toDouble()),
        destRect,
        paint,
      );

      canvas.restore();
    } catch (e) {
      // En caso de error, no dibujar nada
      canvas.restore();
    }
  }
}
