import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:imagenarte/domain/transformable_geometry.dart';

enum EditorTool {
  none,
  home,
  geometricSelection,
  freeSelection,
  scissors,
  color,
  classicAdjustments,
  undo,
  save,
  // Herramientas movidas a Action List
  blur,
  pixelate,
  watermark,
  metadata,
}

enum CropPreset {
  p9_16, // 9:16
  p1_1, // 1:1
  p16_9, // 16:9
  p4_3, // 4:3
  circular, // Circular
}

enum ColorMode {
  color,
  grayscale,
  sepia,
  blackAndWhite,
}

enum ClassicAdjustment {
  brightness,
  contrast,
  saturation,
  sharpness,
}

/// Target de transformación activo
/// Define qué objeto está siendo transformado actualmente
enum TransformTarget {
  none,
  selection, // ROI/Selección
  watermarkText, // Marca de agua de texto
  watermarkLogo, // Marca de agua de logo
}

/// Contexto activo único del editor
/// Define qué overlay debe mostrarse (SOLO UNO a la vez)
enum EditorContext {
  none,
  selectionRatios,
  freeSelection,
  scissors,
  colorPresets,
  classicAdjustments,
  action_blur,
  action_pixelate,
  action_watermark,
  action_metadata,
}

/// Modo de la barra blanca
enum WhiteBarMode {
  structured, // Muestra info estructurada (Selección/versión) con márgenes 16-16
  support, // Muestra mensajes de soporte usando ancho interior entre iconos
}

  /// Snapshot del estado del editor para undo
class EditorSnapshot {
  final EditorTool activeTool;
  final CropPreset? cropPreset;
  final TransformTarget activeTransformTarget;
  final TransformableGeometry? selectionGeometry;
  final TransformableGeometry? watermarkGeometry;

  EditorSnapshot({
    required this.activeTool,
    required this.cropPreset,
    required this.activeTransformTarget,
    required this.selectionGeometry,
    required this.watermarkGeometry,
  });
}

class EditorUiState extends ChangeNotifier {
  EditorTool _activeTool = EditorTool.none;
  CropPreset? _cropPreset;
  TransformTarget _activeTransformTarget = TransformTarget.none;
  
  // Contexto activo único (SINGLE SOURCE OF TRUTH)
  EditorContext _activeContext = EditorContext.none;
  
  // Action List: acción activa en modo foco (nullable)
  // Si es null → Estado A (reposo): lista completa
  // Si no es null → Estado B (foco): solo esta acción visible
  EditorTool? _activeAction;
  
  // Geometría de selección (ROI)
  TransformableGeometry? _selectionGeometry;
  
  // Path para selección libre (mano alzada)
  Path? _freeSelectionPath;
  
  // Geometría de watermark (stub por ahora)
  TransformableGeometry? _watermarkGeometry;
  bool _watermarkVisible = true;
  bool _watermarkIsText = true; // true = texto, false = logo

  // Color mode
  ColorMode _colorMode = ColorMode.color;
  
  // Classic adjustments (0-100, donde 50 es neutro)
  ClassicAdjustment? _activeClassicAdjustment;
  double _brightness = 50.0; // 0-100
  double _contrast = 50.0; // 0-100
  double _saturation = 50.0; // 0-100
  double _sharpness = 50.0; // 0-100
  
  // Intensidades de efectos (0-100)
  double _blurIntensity = 50.0; // 0-100
  double _pixelateIntensity = 50.0; // 0-100
  double _watermarkOpacity = 100.0; // 0-100

  // Nombre de versión de selección (editable)
  String? _selectionVersionBaseName;
  String? _originalFileExtension; // Extensión del archivo original (fija)

  // Mensaje de estado para la barra blanca
  String? _statusMessage;

  // Barra blanca: modo y textos
  WhiteBarMode _whiteBarMode = WhiteBarMode.support;
  String? _structuredInfoText; // Ej: "Selección: ... · 185×329 px · ~0.10 MB"
  String? _supportMessageText; // Ej: "Selecciona una herramienta para comenzar"

  // Undo stack con capacidad de 10
  final List<EditorSnapshot> _undoStack = [];
  static const int _maxUndoLevels = 10;

  EditorTool get activeTool => _activeTool;
  EditorContext get activeContext => _activeContext;
  EditorTool? get activeAction => _activeAction;
  CropPreset? get cropPreset => _cropPreset;
  TransformTarget get activeTransformTarget => _activeTransformTarget;
  TransformableGeometry? get selectionGeometry => _selectionGeometry;
  Path? get freeSelectionPath => _freeSelectionPath;
  TransformableGeometry? get watermarkGeometry => _watermarkGeometry;
  bool get watermarkVisible => _watermarkVisible;
  bool get watermarkIsText => _watermarkIsText;
  ColorMode get colorMode => _colorMode;
  ClassicAdjustment? get activeClassicAdjustment => _activeClassicAdjustment;
  double get brightness => _brightness;
  double get contrast => _contrast;
  double get saturation => _saturation;
  double get sharpness => _sharpness;
  double get blurIntensity => _blurIntensity;
  double get pixelateIntensity => _pixelateIntensity;
  double get watermarkOpacity => _watermarkOpacity;
  bool get canUndo => _undoStack.isNotEmpty;
  bool get hasValidSelection => _selectionGeometry != null || _freeSelectionPath != null;
  String? get selectionVersionBaseName => _selectionVersionBaseName;
  String? get originalFileExtension => _originalFileExtension;
  String? get selectionVersionFullName {
    if (_selectionVersionBaseName == null || _originalFileExtension == null) {
      return null;
    }
    return '$_selectionVersionBaseName$_originalFileExtension';
  }
  String? get statusMessage => _statusMessage;
  WhiteBarMode get whiteBarMode => _whiteBarMode;
  String? get structuredInfoText => _structuredInfoText;
  String? get supportMessageText => _supportMessageText;

  /// Establece el contexto activo único
  /// REEMPLAZA cualquier contexto anterior (limpia overlays previos)
  void setContext(EditorContext ctx) {
    debugPrint("setContext: $ctx  stateHash=${identityHashCode(this)}");
    _activeContext = ctx;
    
    // Limpiar estados incompatibles
    if (ctx == EditorContext.none) {
      _activeAction = null;
    } else if (ctx == EditorContext.action_blur ||
               ctx == EditorContext.action_pixelate ||
               ctx == EditorContext.action_watermark ||
               ctx == EditorContext.action_metadata) {
      // Si se entra por action list, mantener activeAction
      // (se establece en toggleTool)
    } else {
      // Si se entra por toolbar, limpiar activeAction
      _activeAction = null;
    }
    
    notifyListeners();
  }

  /// Limpia el contexto activo (cierra overlay)
  void clearActiveAction() {
    _activeAction = null;
    notifyListeners();
  }

  void setActiveTool(EditorTool tool) {
    // Undo y Save no cambian el tool activo, solo ejecutan acciones
    if (tool == EditorTool.undo) {
      undo();
      return;
    }
    if (tool == EditorTool.save) {
      requestSave();
      // Salida de foco: limpiar activeAction y contexto
      _activeAction = null;
      setContext(EditorContext.none);
      return;
    }
    
    // Home limpia activeAction y contexto (salida de foco)
    if (tool == EditorTool.home) {
      _activeAction = null;
      setContext(EditorContext.none);
      _activeTool = tool;
      notifyListeners();
      return;
    }
    
    _activeTool = tool;
    
    // Mapear tool a contexto y establecerlo (esto reemplaza cualquier contexto anterior)
    switch (tool) {
      case EditorTool.geometricSelection:
        setContext(EditorContext.selectionRatios);
        break;
      case EditorTool.freeSelection:
        setContext(EditorContext.freeSelection);
        break;
      case EditorTool.scissors:
        setContext(EditorContext.scissors);
        break;
      case EditorTool.color:
        setContext(EditorContext.colorPresets);
        break;
      case EditorTool.classicAdjustments:
        setContext(EditorContext.classicAdjustments);
        break;
      case EditorTool.blur:
        setContext(EditorContext.action_blur);
        break;
      case EditorTool.pixelate:
        setContext(EditorContext.action_pixelate);
        break;
      case EditorTool.watermark:
        setContext(EditorContext.action_watermark);
        break;
      case EditorTool.metadata:
        setContext(EditorContext.action_metadata);
        break;
      default:
        setContext(EditorContext.none);
        break;
    }
    
    // Lógica para selección geométrica
    if (tool == EditorTool.geometricSelection) {
      _cropPreset ??= CropPreset.p1_1; // Default temporal (se calculará automáticamente cuando se conozca el tamaño de la imagen)
      _activeTransformTarget = TransformTarget.selection;
    } else if (tool == EditorTool.freeSelection) {
      // Selección libre: limpiar path anterior si existe
      _freeSelectionPath = null;
      _activeTransformTarget = TransformTarget.none;
    } else if (tool == EditorTool.color || tool == EditorTool.classicAdjustments) {
      // Color y ajustes no usan transform target
      _activeTransformTarget = TransformTarget.none;
    } else if (tool == EditorTool.watermark) {
      if (_watermarkGeometry != null) {
        _activeTransformTarget = _watermarkIsText 
            ? TransformTarget.watermarkText 
            : TransformTarget.watermarkLogo;
      } else {
        _activeTransformTarget = TransformTarget.none;
      }
    } else if (tool == EditorTool.blur || tool == EditorTool.pixelate) {
      // Para herramientas que usan selección ROI
      _activeTransformTarget = TransformTarget.selection;
    } else {
      _activeTransformTarget = TransformTarget.none;
    }
  }

  void toggleTool(EditorTool tool) {
    // Verificar si es una acción de la Action List
    final isActionListTool = tool == EditorTool.blur ||
        tool == EditorTool.pixelate ||
        tool == EditorTool.watermark ||
        tool == EditorTool.metadata;
    
    if (isActionListTool) {
      // Si se toca la misma acción, salir de foco
      if (_activeAction == tool) {
        _activeAction = null;
        _activeTool = EditorTool.none;
        setContext(EditorContext.none);
      } else {
        // Cambiar foco a la nueva acción
        _activeAction = tool;
        setActiveTool(tool);
      }
      return;
    }
    
    // Para otras herramientas, comportamiento normal
    if (_activeTool == tool) {
      // Si se toca el mismo tool, resetearlo y cerrar contexto
      _resetTool(tool);
      setContext(EditorContext.none);
    } else {
      // Activar el nuevo tool (esto establece el contexto)
      setActiveTool(tool);
    }
  }

  void _resetTool(EditorTool tool) {
    switch (tool) {
      case EditorTool.geometricSelection:
        // Resetear cropPreset al valor default
        _cropPreset = CropPreset.p1_1;
        _selectionGeometry = null;
        break;
      case EditorTool.freeSelection:
        _freeSelectionPath = null;
        break;
      case EditorTool.color:
        _colorMode = ColorMode.color;
        break;
      case EditorTool.classicAdjustments:
        _brightness = 0.0;
        _contrast = 0.0;
        _saturation = 0.0;
        _sharpness = 0.0;
        break;
      default:
        // Otros tools no tienen estado que resetear
        break;
    }
    notifyListeners();
  }

  void setCropPreset(CropPreset preset) {
    _cropPreset = preset;
    notifyListeners();
  }

  void setActiveTransformTarget(TransformTarget target) {
    _activeTransformTarget = target;
    notifyListeners();
  }

  void setWatermarkGeometry(TransformableGeometry? geometry) {
    _watermarkGeometry = geometry;
    if (geometry != null && _activeTool == EditorTool.watermark) {
      _activeTransformTarget = _watermarkIsText 
          ? TransformTarget.watermarkText 
          : TransformTarget.watermarkLogo;
    }
    notifyListeners();
  }

  void updateWatermarkGeometry(TransformableGeometry geometry) {
    _watermarkGeometry = geometry;
    notifyListeners();
  }

  /// Calcula la proporción más cercana a la imagen original
  CropPreset calculateClosestPreset(double imageWidth, double imageHeight) {
    if (imageWidth <= 0 || imageHeight <= 0) return CropPreset.p1_1;
    
    final imageRatio = imageWidth / imageHeight;
    
    final ratios = {
      CropPreset.p9_16: 9.0 / 16.0,
      CropPreset.p1_1: 1.0,
      CropPreset.p16_9: 16.0 / 9.0,
      CropPreset.p4_3: 4.0 / 3.0,
    };
    
    CropPreset closest = CropPreset.p1_1;
    double minDiff = double.infinity;
    
    for (final entry in ratios.entries) {
      final diff = (imageRatio - entry.value).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = entry.key;
      }
    }
    
    return closest;
  }

  /// Inicializa selección geométrica con proporción automática
  void initializeGeometricSelection(Size canvasSize, Size? imageSize) {
    if (_activeTool != EditorTool.geometricSelection) return;
    
    // Calcular proporción más cercana
    if (imageSize != null) {
      _cropPreset = calculateClosestPreset(imageSize.width, imageSize.height);
    } else {
      _cropPreset = calculateClosestPreset(canvasSize.width, canvasSize.height);
    }
    
    // Crear selección centrada con la proporción calculada
    final center = Offset(canvasSize.width * 0.5, canvasSize.height * 0.5);
    final maxSize = math.min(canvasSize.width, canvasSize.height) * 0.8;
    
    double width, height;
    if (_cropPreset == CropPreset.circular) {
      width = height = maxSize;
      _selectionGeometry = TransformableGeometry(
        shape: TransformableShape.circle,
        center: center,
        size: Size(width, height),
        rotation: 0.0,
      );
    } else {
      double ratio;
      switch (_cropPreset!) {
        case CropPreset.p9_16:
          ratio = 9.0 / 16.0;
          break;
        case CropPreset.p1_1:
          ratio = 1.0;
          break;
        case CropPreset.p16_9:
          ratio = 16.0 / 9.0;
          break;
        case CropPreset.p4_3:
          ratio = 4.0 / 3.0;
          break;
        case CropPreset.circular:
          ratio = 1.0; // No debería llegar aquí
          break;
      }
      
      if (ratio < 1.0) {
        // Vertical
        height = maxSize;
        width = height * ratio;
      } else {
        // Horizontal
        width = maxSize;
        height = width / ratio;
      }
      
      _selectionGeometry = TransformableGeometry(
        shape: TransformableShape.rect,
        center: center,
        size: Size(width, height),
        rotation: 0.0,
      );
    }
    
    _activeTransformTarget = TransformTarget.selection;
    notifyListeners();
  }

  void initializeSelectionIfNeeded(Size canvasSize) {
    if (_selectionGeometry == null && 
        (_activeTool == EditorTool.blur || 
         _activeTool == EditorTool.pixelate)) {
      // Crear círculo por defecto centrado en el canvas
      final radius = math.min(canvasSize.width, canvasSize.height) * 0.2;
      _selectionGeometry = TransformableGeometry(
        shape: TransformableShape.circle,
        center: Offset(canvasSize.width * 0.5, canvasSize.height * 0.5),
        size: Size(radius * 2, radius * 2),
        rotation: 0.0,
      );
      _activeTransformTarget = TransformTarget.selection;
      notifyListeners();
    }
  }

  void updateSelectionGeometry(TransformableGeometry geometry) {
    _selectionGeometry = geometry;
    notifyListeners();
  }

  void setFreeSelectionPath(Path? path) {
    _freeSelectionPath = path;
    notifyListeners();
  }

  void setColorMode(ColorMode mode) {
    _colorMode = mode;
    notifyListeners();
  }

  void setWatermarkVisible(bool visible) {
    _watermarkVisible = visible;
    notifyListeners();
  }

  void setWatermarkIsText(bool isText) {
    _watermarkIsText = isText;
    if (_activeTool == EditorTool.watermark && _watermarkGeometry != null) {
      _activeTransformTarget = isText 
          ? TransformTarget.watermarkText 
          : TransformTarget.watermarkLogo;
    }
    notifyListeners();
  }

  /// Inicializa un watermark por defecto si no existe
  void initializeWatermarkIfNeeded(Size canvasSize) {
    if (_watermarkGeometry == null) {
      _watermarkGeometry = TransformableGeometry(
        shape: TransformableShape.rect,
        center: Offset(canvasSize.width * 0.5, canvasSize.height * 0.5),
        size: const Size(150, 50),
        rotation: 0.0,
      );
      if (_activeTool == EditorTool.watermark) {
        _activeTransformTarget = _watermarkIsText 
            ? TransformTarget.watermarkText 
            : TransformTarget.watermarkLogo;
      }
      notifyListeners();
    }
  }

  /// Crea un snapshot del estado actual
  EditorSnapshot _createSnapshot() {
    return EditorSnapshot(
      activeTool: _activeTool,
      cropPreset: _cropPreset,
      activeTransformTarget: _activeTransformTarget,
      selectionGeometry: _selectionGeometry != null
          ? TransformableGeometry(
              shape: _selectionGeometry!.shape,
              center: _selectionGeometry!.center,
              size: _selectionGeometry!.size,
              rotation: _selectionGeometry!.rotation,
            )
          : null,
      watermarkGeometry: _watermarkGeometry != null
          ? TransformableGeometry(
              shape: _watermarkGeometry!.shape,
              center: _watermarkGeometry!.center,
              size: _watermarkGeometry!.size,
              rotation: _watermarkGeometry!.rotation,
            )
          : null,
    );
  }

  /// Guarda el estado actual en el undo stack
  void pushUndo() {
    final snapshot = _createSnapshot();
    _undoStack.add(snapshot);
    // Limitar a 10 niveles
    if (_undoStack.length > _maxUndoLevels) {
      _undoStack.removeAt(0);
    }
  }

  /// Restaura el último snapshot del undo stack
  void undo() {
    if (_undoStack.isEmpty) return;

    final snapshot = _undoStack.removeLast();
    _activeTool = snapshot.activeTool;
    _cropPreset = snapshot.cropPreset;
    _activeTransformTarget = snapshot.activeTransformTarget;
    _selectionGeometry = snapshot.selectionGeometry != null
        ? TransformableGeometry(
            shape: snapshot.selectionGeometry!.shape,
            center: snapshot.selectionGeometry!.center,
            size: snapshot.selectionGeometry!.size,
            rotation: snapshot.selectionGeometry!.rotation,
          )
        : null;
    _watermarkGeometry = snapshot.watermarkGeometry != null
        ? TransformableGeometry(
            shape: snapshot.watermarkGeometry!.shape,
            center: snapshot.watermarkGeometry!.center,
            size: snapshot.watermarkGeometry!.size,
            rotation: snapshot.watermarkGeometry!.rotation,
          )
        : null;

    notifyListeners();
  }

  /// Stub para requestSave
  void requestSave() {
    // TODO: Implementar lógica de guardado
    notifyListeners();
  }
  
  // Métodos para ajustes clásicos
  void setActiveClassicAdjustment(ClassicAdjustment? adjustment) {
    _activeClassicAdjustment = adjustment;
    notifyListeners();
  }
  
  void setBrightness(double value) {
    _brightness = value.clamp(0.0, 100.0);
    notifyListeners();
  }
  
  void setContrast(double value) {
    _contrast = value.clamp(0.0, 100.0);
    notifyListeners();
  }
  
  void setSaturation(double value) {
    _saturation = value.clamp(0.0, 100.0);
    notifyListeners();
  }
  
  void setSharpness(double value) {
    _sharpness = value.clamp(0.0, 100.0);
    notifyListeners();
  }
  
  // Métodos para intensidades de efectos
  void setBlurIntensity(double value) {
    _blurIntensity = value.clamp(0.0, 100.0);
    notifyListeners();
  }
  
  void setPixelateIntensity(double value) {
    _pixelateIntensity = value.clamp(0.0, 100.0);
    notifyListeners();
  }
  
  void setWatermarkOpacity(double value) {
    _watermarkOpacity = value.clamp(0.0, 100.0);
    notifyListeners();
  }

  /// Establece la extensión del archivo original (fija)
  void setOriginalFileExtension(String? extension) {
    _originalFileExtension = extension;
    notifyListeners();
  }

  /// Establece el nombre base de la versión de selección (editable, sin extensión)
  void setSelectionVersionBaseName(String? baseName) {
    _selectionVersionBaseName = baseName;
    notifyListeners();
  }

  /// Inicializa el nombre base de la versión si no existe
  void initializeSelectionVersionNameIfNeeded(String originalFileName) {
    if (_selectionVersionBaseName == null) {
      // Extraer nombre base sin extensión
      final dotIndex = originalFileName.lastIndexOf('.');
      final baseName = dotIndex > 0 
          ? originalFileName.substring(0, dotIndex)
          : originalFileName;
      _selectionVersionBaseName = baseName;
      
      // Extraer extensión
      if (dotIndex > 0 && dotIndex < originalFileName.length - 1) {
        _originalFileExtension = originalFileName.substring(dotIndex);
      } else {
        _originalFileExtension = '';
      }
      notifyListeners();
    }
  }

  /// Establece el mensaje de estado para la barra blanca
  void setStatusMessage(String? message) {
    _statusMessage = message;
    notifyListeners();
  }

  /// Establece el texto estructurado de la barra blanca
  void setStructuredInfoText(String? text) {
    if (_structuredInfoText == text) return;
    _structuredInfoText = text;
    final newMode = (text != null && text.isNotEmpty) 
        ? WhiteBarMode.structured 
        : WhiteBarMode.support;
    if (_whiteBarMode != newMode) {
      _whiteBarMode = newMode;
    }
    notifyListeners();
  }

  /// Establece el mensaje de soporte de la barra blanca
  void setSupportMessageText(String? text) {
    if (_supportMessageText == text) return;
    _supportMessageText = text;
    if (_structuredInfoText == null || _structuredInfoText!.isEmpty) {
      if (_whiteBarMode != WhiteBarMode.support) {
        _whiteBarMode = WhiteBarMode.support;
      }
    }
    notifyListeners();
  }
}
