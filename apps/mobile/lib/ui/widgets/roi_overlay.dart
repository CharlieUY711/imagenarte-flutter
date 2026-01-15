import 'package:flutter/material.dart';
import 'package:core/domain/roi.dart';

/// Widget overlay para mostrar y editar ROIs sobre una imagen
/// 
/// Permite:
/// - Mostrar ROIs en preview
/// - Tap para seleccionar ROI
/// - Drag para mover
/// - Handles para escalar (4 corners)
/// - Botón para borrar ROI seleccionada
class RoiOverlay extends StatefulWidget {
  final List<ROI> rois;
  final Function(ROI) onRoiSelected;
  final Function(String id, double x, double y, double width, double height) onRoiUpdated;
  final Function(String id) onRoiDeleted;
  final Widget child; // Imagen de fondo

  const RoiOverlay({
    super.key,
    required this.rois,
    required this.onRoiSelected,
    required this.onRoiUpdated,
    required this.onRoiDeleted,
    required this.child,
  });

  @override
  State<RoiOverlay> createState() => _RoiOverlayState();
}

class _RoiOverlayState extends State<RoiOverlay> {
  String? _selectedRoiId;
  Offset? _dragStart;
  Rect? _selectedRoiRect;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Imagen de fondo
        widget.child,
        
        // Overlay de ROIs
        ...widget.rois.map((roi) => _buildRoiWidget(roi)),
      ],
    );
  }

  Widget _buildRoiWidget(ROI roi) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageWidth = constraints.maxWidth;
        final imageHeight = constraints.maxHeight;
        
        // Convertir coordenadas normalizadas a píxeles
        final x = roi.x * imageWidth;
        final y = roi.y * imageHeight;
        final width = roi.width * imageWidth;
        final height = roi.height * imageHeight;
        
        final isSelected = _selectedRoiId == roi.id;
        
        return Positioned(
          left: x,
          top: y,
          width: width,
          height: height,
          child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedRoiId = roi.id;
                });
                widget.onRoiSelected(roi);
              },
              onPanStart: (details) {
                if (isSelected) {
                  _dragStart = details.localPosition;
                  _selectedRoiRect = Rect.fromLTWH(x, y, width, height);
                }
              },
              onPanUpdate: (details) {
                if (_dragStart != null && _selectedRoiRect != null && isSelected) {
                  final delta = details.localPosition - _dragStart!;
                  final newX = (_selectedRoiRect!.left + delta.dx).clamp(0.0, imageWidth - _selectedRoiRect!.width);
                  final newY = (_selectedRoiRect!.top + delta.dy).clamp(0.0, imageHeight - _selectedRoiRect!.height);
                  
                  // Actualizar ROI
                  widget.onRoiUpdated(
                    roi.id,
                    newX / imageWidth,
                    newY / imageHeight,
                    _selectedRoiRect!.width / imageWidth,
                    _selectedRoiRect!.height / imageHeight,
                  );
                }
              },
              onPanEnd: (_) {
                _dragStart = null;
                _selectedRoiRect = null;
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.red,
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    // Handles de escalado (solo si está seleccionado)
                    if (isSelected) ..._buildResizeHandles(roi, imageWidth, imageHeight),
                  ],
                ),
              ),
            ),
          );
      },
    );
  }

  List<Widget> _buildResizeHandles(ROI roi, double imageWidth, double imageHeight) {
    return [
      // Top-left
      Positioned(
        left: -8,
        top: -8,
        child: GestureDetector(
          onPanUpdate: (details) => _handleResize(roi, details, imageWidth, imageHeight, 'top-left'),
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
      // Top-right
      Positioned(
        right: -8,
        top: -8,
        child: GestureDetector(
          onPanUpdate: (details) => _handleResize(roi, details, imageWidth, imageHeight, 'top-right'),
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
      // Bottom-left
      Positioned(
        left: -8,
        bottom: -8,
        child: GestureDetector(
          onPanUpdate: (details) => _handleResize(roi, details, imageWidth, imageHeight, 'bottom-left'),
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
      // Bottom-right
      Positioned(
        right: -8,
        bottom: -8,
        child: GestureDetector(
          onPanUpdate: (details) => _handleResize(roi, details, imageWidth, imageHeight, 'bottom-right'),
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    ];
  }

  void _handleResize(ROI roi, DragUpdateDetails details, double imageWidth, double imageHeight, String corner) {
    final currentX = roi.x * imageWidth;
    final currentY = roi.y * imageHeight;
    final currentWidth = roi.width * imageWidth;
    final currentHeight = roi.height * imageHeight;
    
    double newX = currentX;
    double newY = currentY;
    double newWidth = currentWidth;
    double newHeight = currentHeight;
    
    switch (corner) {
      case 'top-left':
        newX = (currentX + details.delta.dx).clamp(0.0, currentX + currentWidth - 20);
        newY = (currentY + details.delta.dy).clamp(0.0, currentY + currentHeight - 20);
        newWidth = (currentX + currentWidth) - newX;
        newHeight = (currentY + currentHeight) - newY;
        break;
      case 'top-right':
        newY = (currentY + details.delta.dy).clamp(0.0, currentY + currentHeight - 20);
        newWidth = (currentWidth + details.delta.dx).clamp(20.0, imageWidth - currentX);
        newHeight = (currentY + currentHeight) - newY;
        break;
      case 'bottom-left':
        newX = (currentX + details.delta.dx).clamp(0.0, currentX + currentWidth - 20);
        newWidth = (currentX + currentWidth) - newX;
        newHeight = (currentHeight + details.delta.dy).clamp(20.0, imageHeight - currentY);
        break;
      case 'bottom-right':
        newWidth = (currentWidth + details.delta.dx).clamp(20.0, imageWidth - currentX);
        newHeight = (currentHeight + details.delta.dy).clamp(20.0, imageHeight - currentY);
        break;
    }
    
    widget.onRoiUpdated(
      roi.id,
      newX / imageWidth,
      newY / imageHeight,
      newWidth / imageWidth,
      newHeight / imageHeight,
    );
  }
}
