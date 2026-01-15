import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';

/// Widget de imagen compatible con plataformas IO (mobile/desktop)
/// Usa Image.file cuando hay un path disponible
class PlatformImage extends StatelessWidget {
  final String? imagePath;
  final Uint8List? imageBytes;
  final BoxFit? fit;
  final double? width;
  final double? height;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const PlatformImage({
    super.key,
    this.imagePath,
    this.imageBytes,
    this.fit,
    this.width,
    this.height,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath != null) {
      return Image.file(
        File(imagePath!),
        fit: fit,
        width: width,
        height: height,
        errorBuilder: errorBuilder,
      );
    } else if (imageBytes != null) {
      return Image.memory(
        imageBytes!,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: errorBuilder,
      );
    } else {
      return errorBuilder?.call(
            context,
            Exception('No image path or bytes provided'),
            StackTrace.current,
          ) ??
          const SizedBox.shrink();
    }
  }
}
