import 'package:core/domain/operation.dart';
import 'package:processing/ops/pixelate_face/pixelate_face_op.dart';
import 'package:processing/ops/blur_region/blur_region_op.dart';
import 'package:processing/ops/remove_background/remove_background_op.dart';
import 'package:processing/ops/smart_crop/smart_crop_op.dart';

/// Pipeline principal de procesamiento de imágenes
class ImagePipeline {
  final PixelateFaceOp _pixelateFaceOp;
  final BlurRegionOp _blurRegionOp;
  final RemoveBackgroundOp _removeBackgroundOp;
  final SmartCropOp _smartCropOp;

  ImagePipeline(
    this._pixelateFaceOp,
    this._blurRegionOp,
    this._removeBackgroundOp,
    this._smartCropOp,
  );

  /// Aplica una operación a una imagen
  Future<String?> applyOperation({
    required String imagePath,
    required Operation operation,
  }) async {
    switch (operation.type) {
      case OperationType.pixelateFace:
        return await _pixelateFaceOp.apply(imagePath, operation.params);
      case OperationType.blurRegion:
        return await _blurRegionOp.apply(imagePath, operation.params);
      case OperationType.removeBackground:
        return await _removeBackgroundOp.apply(imagePath, operation.params);
      case OperationType.smartCrop:
        return await _smartCropOp.apply(imagePath, operation.params);
    }
  }

  /// Aplica múltiples operaciones en orden
  Future<String> applyOperations({
    required String imagePath,
    required List<Operation> operations,
  }) async {
    String currentPath = imagePath;
    
    for (final operation in operations) {
      if (operation.enabled) {
        final result = await applyOperation(
          imagePath: currentPath,
          operation: operation,
        );
        if (result != null) {
          currentPath = result;
        }
      }
    }
    
    return currentPath;
  }
}
