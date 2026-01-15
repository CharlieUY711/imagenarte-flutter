/// Tipo de operación que se puede aplicar a una imagen
enum OperationType {
  pixelateFace,
  blurRegion,
  removeBackground,
  smartCrop,
}

/// Parámetros de una operación
class OperationParams {
  final Map<String, dynamic> data;

  OperationParams(this.data);

  T? get<T>(String key) => data[key] as T?;
  void set(String key, dynamic value) => data[key] = value;
}

/// Representa una operación a aplicar en el pipeline
class Operation {
  final OperationType type;
  final bool enabled;
  final OperationParams params;

  Operation({
    required this.type,
    this.enabled = true,
    OperationParams? params,
  }) : params = params ?? OperationParams({});
}
