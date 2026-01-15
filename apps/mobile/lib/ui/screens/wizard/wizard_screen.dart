import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../../../navigation/app_router.dart';
import 'package:core/domain/operation.dart';
import 'package:core/application/editor_controller.dart';
import 'package:core/application/usecases/detect_faces.dart';
import 'package:core/application/ports/face_detector.dart';
import 'package:core/domain/roi.dart';
import 'package:processing/infrastructure/face_detection/mlkit_face_detector.dart';
import '../../widgets/roi_overlay.dart';
import '../../widgets/platform_image.dart';

class WizardScreen extends StatefulWidget {
  const WizardScreen({super.key});

  @override
  State<WizardScreen> createState() => _WizardScreenState();
}

class _WizardScreenState extends State<WizardScreen> {
  final ImagePicker _picker = ImagePicker();
  String? _selectedImagePath;
  int _currentStep = 0;
  
  // EditorController
  late final EditorController _editorController;
  late final MlKitFaceDetector _faceDetector;
  bool _isLoadingImage = false;

  // Operaciones
  bool _pixelateFaceEnabled = false;
  int _pixelateIntensity = 5;
  bool _blurEnabled = false;
  int _blurIntensity = 5;
  bool _removeBackgroundEnabled = false;
  bool _smartCropEnabled = false;
  String _cropAspectRatio = '1:1';
  
  @override
  void initState() {
    super.initState();
    // Inicializar EditorController con MLKit
    _faceDetector = MlKitFaceDetector();
    final detectFacesUseCase = DetectFacesUseCase(_faceDetector);
    _editorController = EditorController(detectFacesUseCase);
  }
  
  @override
  void dispose() {
    // Limpiar recursos
    _faceDetector.dispose();
    super.dispose();
  }

  List<Operation> get _operations {
    final ops = <Operation>[];
    
    if (_pixelateFaceEnabled) {
      ops.add(Operation(
        type: OperationType.pixelateFace,
        enabled: true,
        params: OperationParams({'intensity': _pixelateIntensity}),
      ));
    }
    
    if (_blurEnabled) {
      ops.add(Operation(
        type: OperationType.blurRegion,
        enabled: true,
        params: OperationParams({'intensity': _blurIntensity}),
      ));
    }
    
    if (_removeBackgroundEnabled) {
      ops.add(Operation(
        type: OperationType.removeBackground,
        enabled: true,
        params: OperationParams({}),
      ));
    }
    
    if (_smartCropEnabled) {
      ops.add(Operation(
        type: OperationType.smartCrop,
        enabled: true,
        params: OperationParams({'aspectRatio': _cropAspectRatio}),
      ));
    }
    
    return ops;
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _selectedImagePath = image.path;
        _isLoadingImage = true;
      });
      
      // Cargar imagen en el controller
      try {
        await _editorController.loadImage(image.path);
        // Sincronizar modo de efecto con operaciones
        if (_pixelateFaceEnabled) {
          _editorController.setEffectMode(EffectMode.pixelate);
          _editorController.setEffectIntensity(_pixelateIntensity);
        } else if (_blurEnabled) {
          _editorController.setEffectMode(EffectMode.blur);
          _editorController.setEffectIntensity(_blurIntensity);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al cargar imagen: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoadingImage = false;
            _currentStep = 1;
          });
        }
      }
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar Imagen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Cámara'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wizard de Tratamiento'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() => _currentStep++);
          } else {
            // Ir a export (pasar también el controller o sus datos)
            Navigator.pushNamed(
              context,
              AppRouter.export,
              arguments: {
                'imagePath': _selectedImagePath,
                'operations': _operations,
                'rois': _editorController.rois,
                'effectMode': _editorController.effectMode,
                'effectIntensity': _editorController.effectIntensity,
              },
            );
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          } else {
            Navigator.pop(context);
          }
        },
        steps: [
          Step(
            title: const Text('Seleccionar Imagen'),
            content: Column(
              children: [
                if (_selectedImagePath != null)
                  PlatformImage(
                    imagePath: _selectedImagePath,
                    imageBytes: _editorController.imageBytes,
                    height: 200,
                    fit: BoxFit.contain,
                  )
                else
                  const Text('No hay imagen seleccionada'),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _showImageSourceDialog,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Seleccionar Imagen'),
                ),
              ],
            ),
            isActive: _currentStep >= 0,
            state: _selectedImagePath != null
                ? StepState.complete
                : StepState.indexed,
          ),
          Step(
            title: const Text('Acciones'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Controles de ROI (mínimos)
                if (_selectedImagePath != null) ...[
                  const Divider(),
                  const Text(
                    'Zonas de Protección',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Auto detectar rostro'),
                    value: _editorController.autoFaceEnabled,
                    onChanged: (value) async {
                      await _editorController.toggleAutoFace(value);
                      setState(() {});
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await _editorController.redetectFaces();
                            setState(() {});
                          },
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Re-detectar'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Agregar ROI manual en el centro
                            final centerX = 0.4;
                            final centerY = 0.4;
                            final width = 0.2;
                            final height = 0.2;
                            _editorController.addManualRoi(
                              shape: RoiShape.rect,
                              x: centerX,
                              y: centerY,
                              width: width,
                              height: height,
                            );
                            setState(() {});
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Agregar zona'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Zonas: ${_editorController.rois.length}'),
                  const Divider(),
                ],
                
                // Pixelar rostro
                SwitchListTile(
                  title: const Text('Pixelar Rostro'),
                  value: _pixelateFaceEnabled,
                  onChanged: (value) {
                    setState(() {
                      _pixelateFaceEnabled = value;
                      if (value) {
                        _editorController.setEffectMode(EffectMode.pixelate);
                        _blurEnabled = false;
                      }
                    });
                  },
                ),
                if (_pixelateFaceEnabled)
                  Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Intensidad: $_pixelateIntensity'),
                        Slider(
                          value: _pixelateIntensity.toDouble(),
                          min: 1,
                          max: 10,
                          divisions: 9,
                          onChanged: (value) {
                            setState(() {
                              _pixelateIntensity = value.round();
                              _editorController.setEffectIntensity(_pixelateIntensity);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                
                // Blur selectivo
                SwitchListTile(
                  title: const Text('Blur Selectivo'),
                  value: _blurEnabled,
                  onChanged: (value) {
                    setState(() {
                      _blurEnabled = value;
                      if (value) {
                        _editorController.setEffectMode(EffectMode.blur);
                        _pixelateFaceEnabled = false;
                      }
                    });
                  },
                ),
                if (_blurEnabled)
                  Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Intensidad: $_blurIntensity'),
                        Slider(
                          value: _blurIntensity.toDouble(),
                          min: 1,
                          max: 10,
                          divisions: 9,
                          onChanged: (value) {
                            setState(() {
                              _blurIntensity = value.round();
                              _editorController.setEffectIntensity(_blurIntensity);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                
                // Quitar fondo
                SwitchListTile(
                  title: const Text('Quitar Fondo'),
                  subtitle: const Text('(próximamente)'),
                  value: _removeBackgroundEnabled,
                  onChanged: null, // Deshabilitado por ahora
                ),
                
                // Crop inteligente
                SwitchListTile(
                  title: const Text('Crop Inteligente'),
                  value: _smartCropEnabled,
                  onChanged: (value) {
                    setState(() => _smartCropEnabled = value);
                  },
                ),
                if (_smartCropEnabled)
                  Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 16),
                    child: DropdownButton<String>(
                      value: _cropAspectRatio,
                      items: const [
                        DropdownMenuItem(value: '1:1', child: Text('1:1 (Cuadrado)')),
                        DropdownMenuItem(value: '16:9', child: Text('16:9 (Widescreen)')),
                        DropdownMenuItem(value: '4:3', child: Text('4:3 (Clásico)')),
                        DropdownMenuItem(value: '9:16', child: Text('9:16 (Vertical)')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _cropAspectRatio = value);
                        }
                      },
                    ),
                  ),
              ],
            ),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Preview'),
            content: Column(
              children: [
                if (_selectedImagePath != null)
                  SizedBox(
                    height: 300,
                    child: RoiOverlay(
                      rois: _editorController.rois,
                      onRoiSelected: (roi) {
                        // ROI seleccionada (puede usarse para mostrar info)
                      },
                      onRoiUpdated: (id, x, y, width, height) {
                        _editorController.updateRoi(id, x: x, y: y, width: width, height: height);
                        setState(() {});
                      },
                      onRoiDeleted: (id) {
                        _editorController.deleteRoi(id);
                        setState(() {});
                      },
                      child: PlatformImage(
                        imagePath: _selectedImagePath,
                        imageBytes: _editorController.imageBytes,
                        fit: BoxFit.contain,
                      ),
                    ),
                  )
                else
                  const Text('No hay imagen para previsualizar'),
                const SizedBox(height: 16),
                const Text(
                  'Vista previa (procesamiento real en export)',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
                if (_selectedImagePath != null && _editorController.rois.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            final selectedRoi = _editorController.rois.isNotEmpty 
                                ? _editorController.rois.last 
                                : null;
                            if (selectedRoi != null) {
                              _editorController.deleteRoi(selectedRoi.id);
                              setState(() {});
                            }
                          },
                          tooltip: 'Eliminar última zona',
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            isActive: _currentStep >= 2,
          ),
        ],
      ),
    );
  }
}
