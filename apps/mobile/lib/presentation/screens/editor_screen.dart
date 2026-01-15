import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:core/domain/export_profile.dart';
import '../theme/app_theme.dart';
import '../widgets/preview_area.dart';
import '../widgets/toolbar_orange.dart';
import '../widgets/dial_button.dart';
import '../widgets/action_dial_expanded.dart';
import '../widgets/classic_adjustments_panel.dart';
import '../widgets/navigation_buttons.dart';
import '../widgets/bottom_control_panel.dart';
import '../adapters/editor_view_model.dart';
import '../adapters/editor_controller_factory.dart';
import 'package:core/domain/roi.dart';

/// Pantalla principal del Editor
/// Layout general que integra todos los componentes UI
class EditorScreen extends StatefulWidget {
  final String? imagePath;

  const EditorScreen({
    super.key,
    this.imagePath,
  });

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late final EditorViewModel _viewModel;
  bool _isActionDialExpanded = false;
  bool _isAdjustmentsPanelVisible = false;
  
  // Valores de ajustes (mock, sin lógica real)
  double _brightness = 0.0;
  double _contrast = 0.0;
  double _saturation = 0.0;

  // Formato de export (default JPG)
  String _exportFormat = 'jpg';

  @override
  void initState() {
    super.initState();
    
    // Crear ViewModel con controller y export media
    _viewModel = EditorViewModel(
      controller: EditorControllerFactory.create(),
      exportMedia: EditorControllerFactory.createExportMedia(),
    );

    // Cargar imagen al inicializar
    _loadImage();
  }

  Future<void> _loadImage() async {
    if (widget.imagePath != null) {
      // Cargar desde path
      await _viewModel.initWithImagePath(widget.imagePath!);
    }
  }

  void _toggleActionDial() {
    setState(() {
      _isActionDialExpanded = !_isActionDialExpanded;
    });
  }

  void _toggleAdjustmentsPanel() {
    setState(() {
      _isAdjustmentsPanelVisible = !_isAdjustmentsPanelVisible;
    });
  }

  void _handleDialAction(String label) {
    if (label == 'Ajustes') {
      _toggleAdjustmentsPanel();
      _toggleActionDial();
    } else if (label == 'Auto-detectar') {
      _viewModel.toggleAutoFace(!_viewModel.autoFaceEnabled);
      _toggleActionDial();
    } else if (label == 'Re-detectar') {
      _viewModel.redetectFaces();
      _toggleActionDial();
    } else if (label == 'Agregar zona') {
      _viewModel.addZone();
      _toggleActionDial();
    } else {
      _toggleActionDial();
    }
  }

  void _handleBack() {
    Navigator.of(context).pop();
  }

  Future<void> _handleSave() async {
    // Crear perfil de export
    final profile = ExportProfile(
      format: _exportFormat,
      quality: 85,
      sanitizeMetadata: true,
    );

    // Exportar
    final exportedPath = await _viewModel.export(profile);

    if (exportedPath != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Imagen exportada: ${exportedPath.split('/').last}'),
          duration: const Duration(seconds: 3),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.error ?? 'Error al exportar'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  List<DialAction> _getDialActions() {
    return [
      DialAction(
        label: 'Auto-detectar',
        isActive: _viewModel.autoFaceEnabled,
        onTap: () => _handleDialAction('Auto-detectar'),
      ),
      DialAction(
        label: 'Re-detectar',
        isActive: false,
        onTap: () => _handleDialAction('Re-detectar'),
      ),
      DialAction(
        label: 'Agregar zona',
        isActive: false,
        onTap: () => _handleDialAction('Agregar zona'),
      ),
      DialAction(
        label: 'Ajustes',
        isActive: false,
        onTap: () => _handleDialAction('Ajustes'),
      ),
    ];
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.darkEditorTheme,
      child: Scaffold(
        backgroundColor: AppTokens.editorBackground,
        body: SafeArea(
          child: AnimatedBuilder(
            animation: _viewModel,
            builder: (context, _) {
              // Mostrar error si existe
              if (_viewModel.error != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_viewModel.error!),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                });
              }

              return Column(
                children: [
                  // Toolbar naranja (25px)
                  ToolbarOrange(
                    leading: IconButton(
                      icon: const Icon(Icons.close, size: 18, color: Colors.white),
                      onPressed: _handleBack,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    title: const Center(
                      child: Text(
                        'Editor',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  // Preview Area (imagen protagonista) con ROIs - Ocupa 2/3 de la pantalla
                  Expanded(
                    flex: 2,
                    child: Stack(
                      children: [
                        PreviewArea(
                          imagePath: _viewModel.imagePath,
                          imageBytes: _viewModel.imageBytes,
                          rois: _viewModel.rois,
                          onRoiSelected: (_) {},
                          onRoiUpdated: (id, x, y, width, height) {
                            _viewModel.updateRoi(id, x: x, y: y, width: width, height: height);
                          },
                          onRoiDeleted: (id) {
                            _viewModel.deleteRoi(id);
                          },
                        ),
                        
                        // Loading overlay si está procesando
                        if (_viewModel.isBusy)
                          Container(
                            color: Colors.black54,
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(AppTokens.accentOrange),
                              ),
                            ),
                          ),
                        
                        // Dial Button flotante (solo visible cuando no hay panel de ajustes)
                        if (!_viewModel.isBusy && _isAdjustmentsPanelVisible)
                          Positioned(
                            bottom: _isActionDialExpanded ? 200 : 80,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: DialButton(
                                label: 'Acciones',
                                onTap: _toggleActionDial,
                                isActive: _isActionDialExpanded,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Action Dial Expanded (si está abierto)
                  if (_isActionDialExpanded && !_viewModel.isBusy)
                    ActionDialExpanded(
                      actions: _getDialActions(),
                      onClose: _toggleActionDial,
                    ),
                  
                  // Classic Adjustments Panel (si está visible)
                  if (_isAdjustmentsPanelVisible && !_viewModel.isBusy)
                    ClassicAdjustmentsPanel(
                      brightness: _brightness,
                      contrast: _contrast,
                      saturation: _saturation,
                      onBrightnessChanged: (value) {
                        setState(() => _brightness = value);
                      },
                      onContrastChanged: (value) {
                        setState(() => _contrast = value);
                      },
                      onSaturationChanged: (value) {
                        setState(() => _saturation = value);
                      },
                    ),
                  
                  // Bottom Control Panel (panel inferior según diseño) - Ocupa 1/3 de la pantalla
                  if (!_isAdjustmentsPanelVisible && !_isActionDialExpanded)
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: BottomControlPanel(
                        onPixelateFace: () {
                          // TODO: Implementar pixelar rostro
                        },
                        onBlurSelective: () {
                          // TODO: Implementar blur selectivo
                        },
                        onCropIntensity: () {
                          // TODO: Implementar intensidad de crop
                        },
                        onBack: _handleBack,
                        onSave: _viewModel.isBusy ? null : _handleSave,
                        isSaving: _viewModel.isBusy,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
