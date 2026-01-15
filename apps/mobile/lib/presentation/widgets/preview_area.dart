import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../../ui/widgets/roi_overlay.dart';
import '../../ui/widgets/platform_image.dart';
import 'package:core/domain/roi.dart';

/// Widget que muestra la imagen en pantalla completa, sin bordes
/// La imagen siempre es protagonista
class PreviewArea extends StatelessWidget {
  final String? imagePath;
  final Uint8List? imageBytes;
  final Widget? placeholder;
  final List<ROI>? rois;
  final Function(ROI)? onRoiSelected;
  final Function(String id, double x, double y, double width, double height)? onRoiUpdated;
  final Function(String id)? onRoiDeleted;

  const PreviewArea({
    super.key,
    this.imagePath,
    this.imageBytes,
    this.placeholder,
    this.rois,
    this.onRoiSelected,
    this.onRoiUpdated,
    this.onRoiDeleted,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (imagePath != null || imageBytes != null) {
      imageWidget = PlatformImage(
        imagePath: imagePath,
        imageBytes: imageBytes,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
          );
        },
      );
    } else {
      imageWidget = placeholder ?? 
        const Center(
          child: Icon(
            Icons.image_outlined,
            size: 64,
            color: Colors.white38,
          ),
        );
    }

    // Si hay ROIs, envolver con RoiOverlay
    if (rois != null && rois!.isNotEmpty) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: RoiOverlay(
          rois: rois!,
          onRoiSelected: onRoiSelected ?? (_) {},
          onRoiUpdated: onRoiUpdated ?? (_, __, ___, ____, _____) {},
          onRoiDeleted: onRoiDeleted ?? (_) {},
          child: imageWidget,
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: imageWidget,
    );
  }
}
