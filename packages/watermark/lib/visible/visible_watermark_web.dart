/// Watermark visible sobre la imagen (stub para web)
/// 
/// En web, retorna la imagen sin modificar (NO-OP)
class VisibleWatermark {
  /// Aplica un watermark visible de texto (NO-OP en web)
  Future<String> apply({
    required String imagePath,
    required String text,
  }) async {
    // En web, simplemente retornar la ruta original sin modificar
    return imagePath;
  }
}
