/// Tokens de diseño inamovibles para el editor
/// Define las medidas fijas que deben usarse en todos los componentes del editor
/// 
/// ÁREA DE VISUALIZACIÓN CANÓNICA:
/// El área de visualización (canvas) está delimitada por:
/// - ARRIBA: Entre las dos barras superiores (barra naranja + barra blanca = 50px total)
/// - ABAJO: La toolbar naranja horizontal (25px)
/// - LATERALES: Los dos bordes laterales del celular (padding horizontal)
/// 
/// Todos los overlays, diálogos e interacciones deben respetar esta área.
class EditorTokens {
  EditorTokens._();

  /// Altura de la barra superior naranja
  static const double kTopBarHeight = 25.0;

  /// Altura de la barra de información blanca (si existe)
  static const double kInfoBarHeight = 25.0;

  /// Altura de la toolbar naranja horizontal
  static const double kToolbarHeight = 25.0;

  /// Altura de los botones de acción
  static const double kActionButtonHeight = 33.0;

  /// Padding horizontal del overlay panel
  static const double kOverlayHorizontalPadding = 12.0;

  /// Offset vertical del overlay panel desde la toolbar
  /// Debe ser igual al gap entre toolbar y el primer botón negro (AppSpacing.md = 16.0)
  static const double kOverlayBottomOffset = 16.0;

  /// Gap canónico único entre toolbar y contenido (overlay panel y action list)
  /// Debe ser EXACTAMENTE el mismo en ambos casos
  static const double kToolbarToContentGap = 16.0;

  /// Padding horizontal canónico para TODAS las barras horizontales del editor
  /// El PRIMER carácter/icono debe comenzar EXACTAMENTE después de 16dp desde el borde izquierdo
  /// El ÚLTIMO carácter/icono debe terminar EXACTAMENTE 16dp antes del borde derecho
  static const double kContentHPad = 16.0;

  /// Altura canónica para todas las barras horizontales del editor
  static const double kBarHeight = 25.0;

  /// Ancho fijo del slot izquierdo para alineación perfecta entre barras
  /// Contiene: back arrow (top orange) == "Selección:" text start (white) == home icon (toolbar)
  static const double kLeftIconSlotW = 40.0;

  /// Ancho fijo del slot derecho para alineación perfecta entre barras
  /// Contiene: "MB" (top) == "~MB" (white) == save disk icon (toolbar)
  static const double kRightIconSlotW = 40.0;

  /// Tamaño de los iconos en las barras
  static const double kIconSize = 18.0;

  /// Gap fijo entre icono y texto
  static const double kIconGap = 8.0;

  /// ÁREA DE VISUALIZACIÓN CANÓNICA
  /// 
  /// Define los límites del área donde se muestra el contenido (imagen, overlays, etc.)
  /// 
  /// Límites:
  /// - Top: Después de las dos barras superiores (kBarHeight * 2 = 50px)
  /// - Bottom: Antes de la toolbar naranja (kToolbarHeight = 25px)
  /// - Left/Right: Bordes laterales del celular (kOverlayHorizontalPadding = 12px)
  /// 
  /// Todos los overlays y diálogos deben posicionarse dentro de esta área.
  static const double kVisualAreaTopOffset = kBarHeight * 2; // 50px (dos barras superiores)
  static const double kVisualAreaBottomOffset = kToolbarHeight; // 25px (toolbar naranja)
  static const double kVisualAreaHorizontalPadding = kOverlayHorizontalPadding; // 12px (bordes laterales)
}
