import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/preview_area.dart';
import '../widgets/toolbar_orange.dart';
import '../widgets/bottom_control_panel.dart';

/// Versión visual simplificada del Editor
/// Solo muestra la UI sin funcionalidades complejas
/// Para corregir la parte gráfica antes de integrar funcionalidades
class EditorScreenVisual extends StatefulWidget {
  const EditorScreenVisual({super.key});

  @override
  State<EditorScreenVisual> createState() => _EditorScreenVisualState();
}

class _EditorScreenVisualState extends State<EditorScreenVisual> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.darkEditorTheme,
      child: Scaffold(
        backgroundColor: AppTokens.editorBackground,
        body: SafeArea(
          child: Column(
            children: [
              // Toolbar naranja (25px)
              ToolbarOrange(
                leading: IconButton(
                  icon: const Icon(Icons.close, size: 18, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
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
              
              // Preview Area (imagen protagonista) - Ocupa 2/3 de la pantalla
              Expanded(
                flex: 2,
                child: Stack(
                  children: [
                    // Imagen de ejemplo (placeholder)
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: AppTokens.editorBackground,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_outlined,
                              size: 80,
                              color: AppTokens.neutralMedium,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Imagen de ejemplo',
                              style: TextStyle(
                                color: AppTokens.neutralMedium,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Luna',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Badge "CONECTADA" (esquina superior derecha)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTokens.accentOrange,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'CONECTADA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Bottom Control Panel (panel inferior según diseño) - Ocupa 1/3 de la pantalla
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                child: BottomControlPanel(
                  onPixelateFace: () {
                    // Mock - solo para visualización
                    HapticFeedback.lightImpact();
                  },
                  onBlurSelective: () {
                    // Mock - solo para visualización
                    HapticFeedback.lightImpact();
                  },
                  onCropIntensity: () {
                    // Mock - solo para visualización
                    HapticFeedback.lightImpact();
                  },
                  onSave: () {
                    // Mock - solo para visualización
                    setState(() {
                      _isSaving = true;
                    });
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted) {
                        setState(() {
                          _isSaving = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Guardado (mock)'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                    });
                  },
                  hasImage: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
