import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:html' as html;

/// Widget de imagen compatible con web
/// Usa Image.memory cuando hay bytes, o intenta cargar desde URL/path
class PlatformImage extends StatefulWidget {
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
  State<PlatformImage> createState() => _PlatformImageState();
}

class _PlatformImageState extends State<PlatformImage> {
  Uint8List? _loadedBytes;
  bool _isLoading = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _loadImageIfNeeded();
  }

  @override
  void didUpdateWidget(PlatformImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagePath != widget.imagePath || 
        oldWidget.imageBytes != widget.imageBytes) {
      _loadImageIfNeeded();
    }
  }

  Future<void> _loadImageIfNeeded() async {
    // Si ya tenemos bytes, no hacer nada
    if (widget.imageBytes != null) {
      setState(() {
        _loadedBytes = widget.imageBytes;
        _isLoading = false;
        _error = null;
      });
      return;
    }

    // Si no hay path, no hacer nada
    if (widget.imagePath == null) {
      return;
    }

    // Intentar cargar desde URL si el path parece ser una URL
    final path = widget.imagePath!;
    if (path.startsWith('http://') || path.startsWith('https://') || 
        path.startsWith('data:') || path.startsWith('blob:')) {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      try {
        // Intentar cargar como URL
        final response = await html.HttpRequest.request(
          path,
          method: 'GET',
          responseType: 'arraybuffer',
        );
        
        final arrayBuffer = response.response as html.ArrayBuffer;
        final bytes = Uint8List.view(arrayBuffer);
        
        if (mounted) {
          setState(() {
            _loadedBytes = bytes;
            _isLoading = false;
            _error = null;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _error = e;
          });
        }
      }
    } else {
      // Path local - no podemos cargarlo en web sin bytes
      setState(() {
        _isLoading = false;
        _error = Exception('Local file path not supported on web. Use imageBytes instead.');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Prioridad: bytes pasados directamente > bytes cargados > error/placeholder
    final bytesToUse = widget.imageBytes ?? _loadedBytes;

    if (bytesToUse != null) {
      return Image.memory(
        bytesToUse,
        fit: widget.fit,
        width: widget.width,
        height: widget.height,
        errorBuilder: widget.errorBuilder,
      );
    }

    if (_isLoading) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.grey[200],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return widget.errorBuilder?.call(
            context,
            _error!,
            StackTrace.current,
          ) ??
          Container(
            width: widget.width,
            height: widget.height,
            color: Colors.grey[300],
            child: const Center(
              child: Icon(
                Icons.image_not_supported,
                size: 64,
                color: Colors.grey,
              ),
            ),
          );
    }

    // Sin bytes ni path
    return widget.errorBuilder?.call(
          context,
          Exception('No image path or bytes provided'),
          StackTrace.current,
        ) ??
        const SizedBox.shrink();
  }
}
