// Export condicional: web por defecto, IO si dart.library.io está disponible
export 'visible_watermark_web.dart' if (dart.library.io) 'visible_watermark_io.dart';
