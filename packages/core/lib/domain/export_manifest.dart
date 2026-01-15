import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'operation.dart';

/// Manifest de exportación (comprobante local)
/// 
/// Contiene información necesaria para verificar el watermark
/// sin exponer datos personales ni rutas reales.
class ExportManifest {
  /// ID de sesión (opcional, para agrupar exports)
  final String? sessionId;
  
  /// Timestamp de exportación
  final DateTime exportedAt;
  
  /// Lista de operaciones aplicadas (sin PII)
  final List<String> operationsApplied;
  
  /// Hash SHA256 del archivo final exportado
  final String exportHashFinal;
  
  /// Hash SHA256 del token embebido (no el token en claro)
  final String tokenHash;
  
  /// Nonce usado para embedding (o su hash si se prefiere)
  final List<int> nonce;
  
  /// Longitud del token embebido
  final int tokenLength;

  ExportManifest({
    this.sessionId,
    required this.exportedAt,
    required this.operationsApplied,
    required this.exportHashFinal,
    required this.tokenHash,
    required this.nonce,
    required this.tokenLength,
  });

  /// Crea un manifest desde un mapa JSON
  factory ExportManifest.fromJson(Map<String, dynamic> json) {
    return ExportManifest(
      sessionId: json['session_id'] as String?,
      exportedAt: DateTime.parse(json['exported_at'] as String),
      operationsApplied: List<String>.from(json['operations_applied'] as List),
      exportHashFinal: json['export_hash_final'] as String,
      tokenHash: json['token_hash'] as String,
      nonce: List<int>.from(json['nonce'] as List),
      tokenLength: json['token_length'] as int,
    );
  }

  /// Convierte el manifest a JSON
  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'exported_at': exportedAt.toIso8601String(),
      'operations_applied': operationsApplied,
      'export_hash_final': exportHashFinal,
      'token_hash': tokenHash,
      'nonce': nonce,
      'token_length': tokenLength,
    };
  }

  /// Guarda el manifest como archivo JSON
  Future<String> saveToFile(String filePath) async {
    final json = jsonEncode(toJson());
    final file = File(filePath);
    await file.writeAsString(json);
    return file.path;
  }

  /// Carga un manifest desde un archivo JSON
  static Future<ExportManifest> loadFromFile(String filePath) async {
    final file = File(filePath);
    final jsonStr = await file.readAsString();
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    return ExportManifest.fromJson(json);
  }

  /// Calcula el hash SHA256 de un archivo
  static Future<String> calculateFileHash(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  /// Convierte lista de operaciones a strings sin PII
  static List<String> operationsToSafeStrings(List<Operation> operations) {
    return operations.map((op) {
      // Solo incluir tipo de operación, no parámetros que puedan contener PII
      return op.type.toString();
    }).toList();
  }
}
