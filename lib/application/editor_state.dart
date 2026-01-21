import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:imagenarte/domain/editor_tool.dart';

/// Snapshot inmutable de información de imagen (calculado una sola vez al seleccionar imagen)
class ImageInfoSnapshot {
  final String fileName;
  final int width;
  final int height;
  final int bytes;
  final String resolution; // "W×H px"
  final String fileSize; // "X.XX MB" o "X.XX KB"

  const ImageInfoSnapshot({
    required this.fileName,
    required this.width,
    required this.height,
    required this.bytes,
    required this.resolution,
    required this.fileSize,
  });
}

/// Estado del editor para Track B B2.0+B2.1
/// ChangeNotifier local (NO Provider global)
class EditorState extends ChangeNotifier {
  EditorTool _selectedTool = EditorTool.transform;
  String? _imagePath;
  ImageInfoSnapshot? _imageInfo;
  double _blurIntensity = 0.0;
  double _pixelIntensity = 0.0;
  MaskShape _maskShape = MaskShape.rect;
  int _imageCount = 1;
  
  // Imagen activa visible en el preview
  String? _activePreviewImagePath;
  String _activePreviewName = '';
  int _activePreviewW = 0;
  int _activePreviewH = 0;
  int _activePreviewBytes = 0;

  EditorTool get selectedTool => _selectedTool;
  String? get imagePath => _imagePath;
  ImageInfoSnapshot? get imageInfo => _imageInfo;
  double get blurIntensity => _blurIntensity;
  double get pixelIntensity => _pixelIntensity;
  MaskShape get maskShape => _maskShape;
  int get imageCount => _imageCount;
  bool get hasNavigation => _imageCount > 1;
  
  // Getters para imagen activa visible
  String? get activePreviewImagePath => _activePreviewImagePath;
  String get activePreviewName => _activePreviewName;
  int get activePreviewW => _activePreviewW;
  int get activePreviewH => _activePreviewH;
  int get activePreviewBytes => _activePreviewBytes;

  void setTool(EditorTool tool) {
    if (_selectedTool != tool) {
      _selectedTool = tool;
      notifyListeners();
    }
  }

  void setImagePath(String? path) {
    if (_imagePath != path) {
      _imagePath = path;
      // Resetear imageInfo cuando cambia el path para forzar recálculo
      _imageInfo = null;
      // Calcular snapshot si hay path válido
      if (path != null) {
        _calculateImageInfo(path);
      } else {
        notifyListeners();
      }
    }
  }

  /// Calcula la información de imagen una sola vez y la guarda en el snapshot
  Future<void> _calculateImageInfo(String path) async {
    try {
      final file = File(path);
      final fileName = file.uri.pathSegments.last;
      
      // Obtener tamaño del archivo
      final fileSizeBytes = await file.length();
      final fileSizeMB = fileSizeBytes / (1024 * 1024);
      final fileSizeStr = fileSizeMB >= 1.0
          ? '${fileSizeMB.toStringAsFixed(2)} MB'
          : '${(fileSizeBytes / 1024).toStringAsFixed(2)} KB';

      // Obtener resolución de la imagen
      final imageBytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(imageBytes);
      final frame = await codec.getNextFrame();
      final width = frame.image.width;
      final height = frame.image.height;
      final resolution = '$width×$height px';

      // Crear snapshot inmutable
      _imageInfo = ImageInfoSnapshot(
        fileName: fileName,
        width: width,
        height: height,
        bytes: fileSizeBytes,
        resolution: resolution,
        fileSize: fileSizeStr,
      );

      notifyListeners();
    } catch (e) {
      // Si hay error, mantener imageInfo como null
      _imageInfo = null;
      notifyListeners();
    }
  }

  void setImageCount(int count) {
    if (_imageCount != count) {
      _imageCount = count;
      notifyListeners();
    }
  }

  void setBlurIntensity(double intensity) {
    if (_blurIntensity != intensity) {
      _blurIntensity = intensity.clamp(0.0, 100.0);
      notifyListeners();
    }
  }

  void setPixelIntensity(double intensity) {
    if (_pixelIntensity != intensity) {
      _pixelIntensity = intensity.clamp(0.0, 100.0);
      notifyListeners();
    }
  }

  void setMaskShape(MaskShape shape) {
    if (_maskShape != shape) {
      _maskShape = shape;
      notifyListeners();
    }
  }

  /// Establece la imagen activa visible en el preview
  /// Calcula síncronamente el nombre, dimensiones y tamaño del archivo
  void setActivePreviewImagePath(String path) {
    if (_activePreviewImagePath == path) {
      return; // Ya está establecida, no hacer nada
    }
    
    try {
      final file = File(path);
      _activePreviewImagePath = path;
      
      // Paso A (sincrónico inmediato)
      _activePreviewName = file.uri.pathSegments.last;
      _activePreviewBytes = file.lengthSync();
      notifyListeners(); // para que se vea tamaño rápido aunque W×H demore
      
      // Paso B (W×H real, sin tool dependency)
      // hacerlo SINCRÓNICO si es posible:
      final bytes = file.readAsBytesSync();
      final decoded = img.decodeImage(bytes);
      if (decoded != null) {
        _activePreviewW = decoded.width;
        _activePreviewH = decoded.height;
      } else {
        _activePreviewW = 0;
        _activePreviewH = 0;
      }
      
      notifyListeners(); // repaint definitivo con W×H
    } catch (e) {
      // Si hay error, limpiar valores
      _activePreviewImagePath = null;
      _activePreviewName = '';
      _activePreviewW = 0;
      _activePreviewH = 0;
      _activePreviewBytes = 0;
      notifyListeners();
    }
  }
}

/// Forma de máscara para herramienta Mask
enum MaskShape {
  rect,
  circle,
}
