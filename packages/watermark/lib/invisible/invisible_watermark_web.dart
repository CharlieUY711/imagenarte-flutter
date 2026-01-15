/// Watermark invisible (stub para web)
/// 
/// En web, retorna la imagen sin modificar (NO-OP)
class InvisibleWatermark {
  /// Embebe un token en la imagen (NO-OP en web)
  /// 
  /// Retorna la ruta del archivo sin modificar
  Future<String> embed({
    required String imagePath,
    required List<int> token,
    required List<int> nonce,
  }) async {
    // En web, simplemente retornar la ruta original sin modificar
    return imagePath;
  }

  /// Extrae un token embebido de la imagen (NO-OP en web)
  /// 
  /// Retorna null ya que no hay token embebido en web
  Future<List<int>?> extract({
    required String imagePath,
    required int tokenLength,
    required List<int> nonce,
  }) async {
    // En web, no hay token embebido
    return null;
  }

  /// Método legacy para compatibilidad (deprecated)
  /// 
  /// Usar embed() en su lugar
  @Deprecated('Usar embed() en su lugar')
  Future<String> apply(String imagePath) async {
    // Mantener compatibilidad pero no hacer nada real
    return imagePath;
  }
}
