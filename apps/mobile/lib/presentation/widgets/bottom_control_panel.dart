import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Panel de control inferior según el diseño de la imagen
/// Incluye: barra de herramientas naranja, botones de opciones, controles de aspecto, etc.
class BottomControlPanel extends StatelessWidget {
  final VoidCallback? onPixelateFace;
  final VoidCallback? onBlurSelective;
  final VoidCallback? onCropIntensity;
  final VoidCallback? onBack;
  final VoidCallback? onSave;
  final bool isSaving;

  const BottomControlPanel({
    super.key,
    this.onPixelateFace,
    this.onBlurSelective,
    this.onCropIntensity,
    this.onBack,
    this.onSave,
    this.isSaving = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTokens.neutralDark,
        border: Border(
          top: BorderSide(
            color: AppTokens.neutralMedium.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Barra de herramientas naranja (iconos)
          Container(
            height: 50,
            color: AppTokens.accentOrange,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildToolIcon(Icons.crop_free, onTap: () {}),
                _buildToolIcon(Icons.open_with, onTap: () {}),
                _buildToolIcon(Icons.aspect_ratio, onTap: () {}),
                _buildToolIcon(Icons.rotate_right, onTap: () {}),
                _buildToolIcon(Icons.pan_tool, onTap: () {}),
                _buildToolIcon(Icons.undo, onTap: () {}),
              ],
            ),
          ),
          
          // Panel de opciones (scrollable) - Ocupa espacio restante
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Botón Pixelar rostro
                    _buildOptionButton(
                      label: 'Pixelar rostro',
                      onTap: onPixelateFace,
                    ),
                    const SizedBox(height: 12),
                    
                    // Botón Blur selectivo
                    _buildOptionButton(
                      label: 'Blur selectivo',
                      onTap: onBlurSelective,
                    ),
                    const SizedBox(height: 12),
                    
                    // Botón Intensidad de crop
                    _buildOptionButton(
                      label: 'Intensidad de crop',
                      onTap: onCropIntensity,
                    ),
                    const SizedBox(height: 16),
                    
                    // Controles de relación de aspecto
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildAspectIcon(Icons.phone_android, isSelected: true),
                        _buildAspectIcon(Icons.phone_iphone),
                        _buildAspectIcon(Icons.crop_square),
                        _buildAspectIcon(Icons.circle_outlined),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Iconos de ajuste de imagen (primera fila)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildAdjustmentIcon(Icons.palette, isSelected: true),
                        _buildAdjustmentIcon(Icons.tune),
                        _buildAdjustmentIcon(Icons.local_cafe),
                        _buildAdjustmentIcon(Icons.lightbulb_outline),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Iconos de ajuste de imagen (segunda fila)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildAdjustmentIcon(Icons.circle),
                        _buildAdjustmentIcon(Icons.water_drop),
                        _buildAdjustmentIcon(Icons.wb_sunny),
                        _buildAdjustmentIcon(Icons.flash_on),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
          
          // Botones de navegación (Volver / Grabar)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTokens.neutralDark,
              border: Border(
                top: BorderSide(
                  color: AppTokens.neutralMedium.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Botón Volver
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onBack,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTokens.accentOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('Volver'),
                  ),
                ),
                const SizedBox(width: 12),
                // Botón Grabar
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isSaving ? null : onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTokens.accentOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.save, size: 18),
                    label: const Text('Grabar'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolIcon(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required String label,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTokens.editorSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTokens.neutralMedium.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildAspectIcon(IconData icon, {bool isSelected = false}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isSelected ? AppTokens.accentOrange : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? AppTokens.accentOrange : AppTokens.neutralMedium,
          width: 1,
        ),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildAdjustmentIcon(IconData icon, {bool isSelected = false}) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isSelected ? AppTokens.accentOrange : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 20,
      ),
    );
  }
}
