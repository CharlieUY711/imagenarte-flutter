// Export condicional: web por defecto, IO si dart.library.io está disponible
export 'export_media_web.dart' if (dart.library.io) 'export_media_io.dart';
