import 'dart:typed_data';
import 'dart:io';
import 'package:image/image.dart' as img;
import '../domain/roi.dart';
import '../domain/roi_rules.dart';
import '../application/usecases/detect_faces.dart';
import '../application/ports/face_detector.dart';

/// Modo de efecto a aplicar
enum EffectMode {
  pixelate,
  blur,
}

/// Preset de color
enum ColorPreset {
  color,    // Sin filtro
  grayscale, // Escala de grises
  sepia,    // Sepia
  bw,       // Blanco y negro
}

/// Controller único para el editor de imágenes
/// 
/// Orquesta la detección facial, gestión de ROIs y exportación.
/// NO depende de Flutter UI (no importa material.dart).
class EditorController {
  final DetectFacesUseCase _detectFacesUseCase;

  // Estado
  Uint8List? _imageBytes;
  int? _imageWidth;
  int? _imageHeight;
  String? _imagePath;
  
  bool _autoFaceEnabled = true;
  List<ROI> _rois = [];
  String? _selectedRoiId;
  EffectMode _effectMode = EffectMode.pixelate;
  int _effectIntensity = 5;
  
  // Ajustes clásicos (brightness, contrast, saturation)
  // Valores en rango -100 a +100, donde 0 es neutral
  double _brightness = 0.0;
  double _contrast = 0.0;
  double _saturation = 0.0;
  
  // Preset de color
  ColorPreset _colorPreset = ColorPreset.color;

  EditorController(this._detectFacesUseCase);

  // Getters de estado
  Uint8List? get imageBytes => _imageBytes;
  int? get imageWidth => _imageWidth;
  int? get imageHeight => _imageHeight;
  String? get imagePath => _imagePath;
  bool get autoFaceEnabled => _autoFaceEnabled;
  List<ROI> get rois => List.unmodifiable(_rois);
  String? get selectedRoiId => _selectedRoiId;
  EffectMode get effectMode => _effectMode;
  int get effectIntensity => _effectIntensity;
  double get brightness => _brightness;
  double get contrast => _contrast;
  double get saturation => _saturation;
  ColorPreset get colorPreset => _colorPreset;
  
  /// Obtiene la ROI activa (seleccionada) si existe
  ROI? getActiveRoi() {
    if (_selectedRoiId == null) return null;
    try {
      return _rois.firstWhere((roi) => roi.id == _selectedRoiId);
    } catch (_) {
      return null;
    }
  }
  
  /// Verifica si hay una ROI activa
  bool hasActiveRoi() => getActiveRoi() != null;

  /// Carga una imagen desde un archivo
  Future<void> loadImage(String imagePath) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      throw Exception('Archivo no existe: $imagePath');
    }

    final bytes = await file.readAsBytes();
    final image = await _decodeImage(bytes);
    
    if (image == null) {
      throw Exception('No se pudo decodificar la imagen');
    }

    _imagePath = imagePath;
    _imageBytes = bytes;
    _imageWidth = image.width;
    _imageHeight = image.height;

    // Si auto-face está habilitado, detectar automáticamente
    if (_autoFaceEnabled) {
      await _detectFaces();
    }
  }

  /// Carga una imagen desde bytes
  Future<void> loadImageFromBytes(Uint8List bytes) async {
    final image = await _decodeImage(bytes);
    
    if (image == null) {
      throw Exception('No se pudo decodificar la imagen');
    }

    _imagePath = null;
    _imageBytes = bytes;
    _imageWidth = image.width;
    _imageHeight = image.height;

    // Si auto-face está habilitado, detectar automáticamente
    if (_autoFaceEnabled) {
      await _detectFaces();
    }
  }

  /// Toggle de detección automática de rostro
  Future<void> toggleAutoFace(bool enabled) async {
    _autoFaceEnabled = enabled;
    
    if (enabled) {
      // Detectar rostros
      await _detectFaces();
    } else {
      // Eliminar solo ROIs automáticas no-locked
      _rois = _rois.where((roi) => 
        roi.type != RoiType.faceAuto || roi.locked
      ).toList();
    }
  }

  /// Re-detecta rostros (solo si auto-face está habilitado)
  Future<void> redetectFaces() async {
    if (!_autoFaceEnabled) return;
    
    // Eliminar solo ROIs automáticas no-locked
    _rois = _rois.where((roi) => 
      roi.type != RoiType.faceAuto || roi.locked
    ).toList();
    
    // Detectar nuevamente
    await _detectFaces();
  }

  /// Detecta rostros y actualiza ROIs aplicando reglas de negocio
  Future<void> _detectFaces() async {
    if (_imageBytes == null || _imageWidth == null || _imageHeight == null) {
      return;
    }

    // Detectar rostros
    final detectedRois = await _detectFacesUseCase.execute(
      _imageBytes!,
      _imageWidth!,
      _imageHeight!,
    );

    // Separar ROIs manuales y automáticas
    final manualRois = _rois.where((r) => r.type == RoiType.manual).toList();
    final autoRois = detectedRois;

    // Aplicar reglas de negocio: merge de ROIs
    _rois = RoiRules.mergeRois(
      autoRois: autoRois,
      manualRois: manualRois,
    );
  }

  /// Agrega una ROI manual
  void addManualRoi({
    required RoiShape shape,
    required double x,
    required double y,
    required double width,
    required double height,
  }) {
    if (_imageWidth == null || _imageHeight == null) {
      throw Exception('No hay imagen cargada');
    }

    final roiId = 'manual_${DateTime.now().millisecondsSinceEpoch}';
    final roi = ROI(
      id: roiId,
      type: RoiType.manual,
      shape: shape,
      x: x,
      y: y,
      width: width,
      height: height,
      locked: false,
    );

    if (!RoiRules.isValid(roi)) {
      throw Exception('ROI inválida: fuera de límites');
    }

    _rois.add(roi);
  }

  /// Actualiza una ROI existente
  void updateRoi(String id, {
    double? x,
    double? y,
    double? width,
    double? height,
  }) {
    final index = _rois.indexWhere((r) => r.id == id);
    if (index == -1) {
      throw Exception('ROI no encontrada: $id');
    }

    final existingRoi = _rois[index];
    
    // Si es una ROI automática, convertirla a manual o lockearla
    ROI updatedRoi;
    if (existingRoi.type == RoiType.faceAuto) {
      // Convertir a manual cuando el usuario la modifica
      updatedRoi = RoiRules.convertAutoToManual(existingRoi);
    } else {
      updatedRoi = existingRoi;
    }

    // Actualizar coordenadas
    updatedRoi = updatedRoi.copyWith(
      x: x ?? updatedRoi.x,
      y: y ?? updatedRoi.y,
      width: width ?? updatedRoi.width,
      height: height ?? updatedRoi.height,
    );

    if (!RoiRules.isValid(updatedRoi)) {
      throw Exception('ROI inválida: fuera de límites');
    }

    _rois[index] = updatedRoi;
  }

  /// Elimina una ROI
  void deleteRoi(String id) {
    final index = _rois.indexWhere((r) => r.id == id);
    if (index == -1) {
      throw Exception('ROI no encontrada: $id');
    }

    final roi = _rois[index];
    
    // Aplicar regla: manuales siempre se pueden eliminar manualmente
    if (roi.type == RoiType.manual) {
      _rois.removeAt(index);
      return;
    }

    // Auto solo se puede eliminar si no está locked
    if (RoiRules.canDeleteAutomatically(roi)) {
      _rois.removeAt(index);
      return;
    }

    throw Exception('No se puede eliminar esta ROI (locked o protegida)');
  }

  /// Limpia todas las ROIs automáticas (no-locked)
  void clearAutoRois() {
    _rois = _rois.where((roi) => 
      roi.type != RoiType.faceAuto || roi.locked
    ).toList();
  }

  /// Establece el modo de efecto
  void setEffectMode(EffectMode mode) {
    _effectMode = mode;
  }

  /// Establece la intensidad del efecto
  void setEffectIntensity(int intensity) {
    _effectIntensity = intensity.clamp(1, 10);
  }
  
  /// Establece la ROI seleccionada (activa)
  void setSelectedRoiId(String? roiId) {
    if (roiId != null) {
      // Verificar que la ROI existe
      final exists = _rois.any((roi) => roi.id == roiId);
      if (!exists) {
        throw Exception('ROI no encontrada: $roiId');
      }
    }
    _selectedRoiId = roiId;
  }
  
  /// Establece el brillo (-100 a +100, 0 es neutral)
  void setBrightness(double value) {
    _brightness = value.clamp(-100.0, 100.0);
  }
  
  /// Establece el contraste (-100 a +100, 0 es neutral)
  void setContrast(double value) {
    _contrast = value.clamp(-100.0, 100.0);
  }
  
  /// Establece la saturación (-100 a +100, 0 es neutral)
  void setSaturation(double value) {
    _saturation = value.clamp(-100.0, 100.0);
  }
  
  /// Establece el preset de color
  void setColorPreset(ColorPreset preset) {
    _colorPreset = preset;
  }

  /// Restaura el estado completo del editor (para undo/redo)
  /// 
  /// Este método permite restaurar un estado anterior guardado en el historial.
  /// Úsese con precaución: solo para operaciones de undo/redo.
  void restoreState({
    required List<ROI> rois,
    required bool autoFaceEnabled,
    required EffectMode effectMode,
    required int effectIntensity,
    String? selectedRoiId,
    double? brightness,
    double? contrast,
    double? saturation,
    ColorPreset? colorPreset,
  }) {
    // Deep copy de la lista de ROIs para evitar mutaciones externas
    _rois = rois.map((roi) => roi.copyWith()).toList();
    _autoFaceEnabled = autoFaceEnabled;
    _effectMode = effectMode;
    _effectIntensity = effectIntensity.clamp(1, 10);
    _selectedRoiId = selectedRoiId;
    if (brightness != null) _brightness = brightness.clamp(-100.0, 100.0);
    if (contrast != null) _contrast = contrast.clamp(-100.0, 100.0);
    if (saturation != null) _saturation = saturation.clamp(-100.0, 100.0);
    if (colorPreset != null) _colorPreset = colorPreset;
  }

  /// Obtiene los bytes de la imagen procesada con efectos aplicados en ROIs
  /// 
  /// Este método NO exporta directamente, solo procesa.
  /// El procesamiento real debe hacerse en la capa de infrastructure.
  /// 
  /// Retorna los bytes procesados (o originales si no hay ROIs)
  Uint8List? getProcessedImageBytes() {
    if (_imageBytes == null) return null;
    
    // Si no hay ROIs, retornar imagen sin cambios
    if (_rois.isEmpty) {
      return _imageBytes;
    }
    
    // El procesamiento real se hace en infrastructure
    // Este método solo expone el estado necesario
    return _imageBytes;
  }

  /// Decodifica una imagen desde bytes
  Future<({int width, int height})?> _decodeImage(Uint8List bytes) async {
    try {
      // Usar el paquete image para decodificar
      final image = img.decodeImage(bytes);
      if (image == null) return null;
      return (width: image.width, height: image.height);
    } catch (_) {
      return null;
    }
  }
}
