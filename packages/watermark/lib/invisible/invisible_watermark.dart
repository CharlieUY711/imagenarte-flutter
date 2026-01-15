// Export condicional: web por defecto, IO si dart.library.io está disponible
export 'invisible_watermark_web.dart' if (dart.library.io) 'invisible_watermark_io.dart';
