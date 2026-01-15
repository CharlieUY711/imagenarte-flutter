import 'operation.dart';

/// Representa una sesión de trabajo con una imagen
class Session {
  final String id;
  final DateTime createdAt;
  final String? originalImagePath;
  final List<Operation> operations;
  final String? processedImagePath;

  Session({
    required this.id,
    required this.createdAt,
    this.originalImagePath,
    List<Operation>? operations,
    this.processedImagePath,
  }) : operations = operations ?? [];

  Session copyWith({
    String? id,
    DateTime? createdAt,
    String? originalImagePath,
    List<Operation>? operations,
    String? processedImagePath,
  }) {
    return Session(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      originalImagePath: originalImagePath ?? this.originalImagePath,
      operations: operations ?? this.operations,
      processedImagePath: processedImagePath ?? this.processedImagePath,
    );
  }
}
