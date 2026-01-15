import 'package:core/domain/operation.dart';
import 'package:processing/pipeline/image_pipeline.dart';

/// Caso de uso: Aplicar una operación a una imagen
class ApplyOperation {
  final ImagePipeline _pipeline;

  ApplyOperation(this._pipeline);

  Future<String?> execute({
    required String imagePath,
    required Operation operation,
  }) async {
    if (!operation.enabled) {
      return imagePath;
    }

    return await _pipeline.applyOperation(
      imagePath: imagePath,
      operation: operation,
    );
  }
}
