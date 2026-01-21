import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'custom_icons.dart';

/// Panel de control inferior según el diseño de la imagen
/// Incluye: barra de herramientas naranja, botones de opciones, controles de aspecto, etc.
class BottomControlPanel extends StatelessWidget {
  final VoidCallback? onPixelateFace;
  final VoidCallback? onBlurSelective;
  final VoidCallback? onCropIntensity;

  const BottomControlPanel({
    super.key,
    this.onPixelateFace,
    this.onBlurSelective,
    this.onCropIntensity,
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
                _buildToolIcon(Icons.home, onTap: () {}),
                _buildToolIcon(Icons.crop_free, onTap: () {}),
                _buildToolIcon(Icons.open_with, onTap: () {}),
                _buildToolIcon(Icons.content_cut, onTap: () {}),
                _buildCustomIcon(
                  const AdjustmentsIcon(isActive: false, color: Colors.white),
                  onTap: () {},
                ),
                _buildCustomIcon(
                  const ColorPresetsIcon(isActive: false, color: Colors.white),
                  onTap: () {},
                ),
                _buildToolIcon(Icons.undo, onTap: () {}),
                _buildToolIcon(Icons.save, onTap: () {}),
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

  Widget _buildCustomIcon(Widget icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: icon,
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
