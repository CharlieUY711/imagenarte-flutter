import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:imagenarte/application/editor_ui_state.dart';
import 'package:imagenarte/application/color_filters.dart';
import 'package:imagenarte/application/classic_adjustments_processor.dart';
import 'package:imagenarte/domain/classic_adjustments_params.dart';

/// Widget que muestra una imagen con filtros de color y ajustes clásicos aplicados
/// 
/// Cachea la imagen procesada y solo recalcula cuando cambian
/// el colorMode, colorIntensity o los ajustes clásicos.
class FilteredImageWidget extends StatefulWidget {
  final String imagePath;
  final ColorMode colorMode;
  final double colorIntensity;
  final BoxFit fit;
  
  // Ajustes clásicos opcionales
  final double? brightness;
  final double? contrast;
  final double? saturation;
  final double? sharpness;

  const FilteredImageWidget({
    super.key,
    required this.imagePath,
    required this.colorMode,
    required this.colorIntensity,
    this.fit = BoxFit.contain,
    this.brightness,
    this.contrast,
    this.saturation,
    this.sharpness,
  });

  @override
  State<FilteredImageWidget> createState() => _FilteredImageWidgetState();
}

class _FilteredImageWidgetState extends State<FilteredImageWidget> {
  Uint8List? _cachedImageBytes;
  ColorMode? _lastColorMode;
  double? _lastColorIntensity;
  String? _lastImagePath;
  ClassicAdjustmentsParams? _lastClassicAdjustments;

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  @override
  void didUpdateWidget(FilteredImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentAdjustments = _getClassicAdjustments();
    final oldAdjustments = _getClassicAdjustments(oldWidget);
    
    if (oldWidget.imagePath != widget.imagePath ||
        oldWidget.colorMode != widget.colorMode ||
        oldWidget.colorIntensity != widget.colorIntensity ||
        currentAdjustments != oldAdjustments) {
      _processImage();
    }
  }

  ClassicAdjustmentsParams? _getClassicAdjustments([FilteredImageWidget? w]) {
    final w = this.widget;
    if (w.brightness == null && w.contrast == null && 
        w.saturation == null && w.sharpness == null) {
      return null;
    }
    return ClassicAdjustmentsParams(
      brightness: w.brightness ?? 0.0,
      contrast: w.contrast ?? 0.0,
      saturation: w.saturation ?? 0.0,
      sharpness: w.sharpness ?? 0.0,
    );
  }

  Future<void> _processImage() async {
    final currentAdjustments = _getClassicAdjustments();
    
    // Si no cambió nada relevante, no recalcular
    if (_lastImagePath == widget.imagePath &&
        _lastColorMode == widget.colorMode &&
        _lastColorIntensity == widget.colorIntensity &&
        _lastClassicAdjustments == currentAdjustments &&
        _cachedImageBytes != null) {
      return;
    }

    try {
      final file = File(widget.imagePath);
      final imageBytes = await file.readAsBytes();
      
      // Si es Original, usar imagen sin procesar
      if (widget.colorMode == ColorMode.color || widget.colorIntensity <= 0.0) {
        if (mounted) {
          setState(() {
            _cachedImageBytes = imageBytes;
            _lastImagePath = widget.imagePath;
            _lastColorMode = widget.colorMode;
            _lastColorIntensity = widget.colorIntensity;
          });
        }
        return;
      }

      // Decodificar imagen usando el paquete image
      final decodedImage = img.decodeImage(imageBytes);
      if (decodedImage == null) {
        if (mounted) {
          setState(() {
            _cachedImageBytes = imageBytes; // Fallback a original
            _lastImagePath = widget.imagePath;
            _lastColorMode = widget.colorMode;
            _lastColorIntensity = widget.colorIntensity;
          });
        }
        return;
      }

      final width = decodedImage.width;
      final height = decodedImage.height;

      // Convertir imagen a datos RGBA
      // Trabajar directamente con los píxeles usando getPixel
      final imageData = Uint8List(width * height * 4);
      
      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final pixel = decodedImage.getPixel(x, y);
          final index = (y * width + x) * 4;
          
          // Extraer componentes de color del pixel
          // El paquete image almacena píxeles como int32, extraer componentes
          imageData[index] = (pixel.r).toInt(); // R
          imageData[index + 1] = (pixel.g).toInt(); // G
          imageData[index + 2] = (pixel.b).toInt(); // B
          imageData[index + 3] = (pixel.a).toInt(); // A
        }
      }

      // Aplicar filtro de color
      final intensity = widget.colorIntensity / 100.0; // Convertir 0-100 a 0-1
      var processedData = applyColorPreset(
        imageData: imageData,
        width: width,
        height: height,
        presetType: widget.colorMode,
        intensity: intensity,
      );

      // Aplicar ajustes clásicos si están presentes
      final classicAdjustments = _getClassicAdjustments();
      if (classicAdjustments != null && !classicAdjustments.isDefault) {
        processedData = ClassicAdjustmentsProcessor.apply(
          imageData: processedData,
          width: width,
          height: height,
          params: classicAdjustments,
        );
      }

      // Crear nueva imagen copiando la original y aplicando los datos filtrados
      final filteredImage = img.Image(width: width, height: height);
      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final index = (y * width + x) * 4;
          final r = processedData[index].toInt();
          final g = processedData[index + 1].toInt();
          final b = processedData[index + 2].toInt();
          final a = processedData[index + 3].toInt();
          filteredImage.setPixelRgba(x, y, r, g, b, a);
        }
      }

      // Codificar a PNG o JPEG según el formato original
      final outputBytes = widget.imagePath.toLowerCase().endsWith('.png')
          ? Uint8List.fromList(img.encodePng(filteredImage))
          : Uint8List.fromList(img.encodeJpg(filteredImage, quality: 95));

      if (mounted) {
        setState(() {
          _cachedImageBytes = outputBytes;
          _lastImagePath = widget.imagePath;
          _lastColorMode = widget.colorMode;
          _lastColorIntensity = widget.colorIntensity;
          _lastClassicAdjustments = currentAdjustments;
        });
      }
    } catch (e) {
      // En caso de error, usar imagen original
      try {
        final file = File(widget.imagePath);
        final imageBytes = await file.readAsBytes();
        if (mounted) {
          setState(() {
            _cachedImageBytes = imageBytes;
            _lastImagePath = widget.imagePath;
            _lastColorMode = widget.colorMode;
            _lastColorIntensity = widget.colorIntensity;
            _lastClassicAdjustments = _getClassicAdjustments();
          });
        }
      } catch (_) {
        // Si falla todo, mostrar placeholder
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cachedImageBytes == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Image.memory(
      _cachedImageBytes!,
      fit: widget.fit,
    );
  }
}
