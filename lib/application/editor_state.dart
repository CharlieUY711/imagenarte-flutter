import 'package:flutter/material.dart';
import 'package:imagenarte/domain/editor_tool.dart';

/// Estado del editor para Track B B2.0+B2.1
/// ChangeNotifier local (NO Provider global)
class EditorState extends ChangeNotifier {
  EditorTool _selectedTool = EditorTool.transform;
  String? _imagePath;
  double _blurIntensity = 0.0;
  double _pixelIntensity = 0.0;
  MaskShape _maskShape = MaskShape.rect;

  EditorTool get selectedTool => _selectedTool;
  String? get imagePath => _imagePath;
  double get blurIntensity => _blurIntensity;
  double get pixelIntensity => _pixelIntensity;
  MaskShape get maskShape => _maskShape;

  void setTool(EditorTool tool) {
    if (_selectedTool != tool) {
      _selectedTool = tool;
      notifyListeners();
    }
  }

  void setImagePath(String? path) {
    if (_imagePath != path) {
      _imagePath = path;
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
}

/// Forma de máscara para herramienta Mask
enum MaskShape {
  rect,
  circle,
}
