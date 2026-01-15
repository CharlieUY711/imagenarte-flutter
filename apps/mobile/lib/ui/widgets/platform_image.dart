// Export condicional: web por defecto, IO si dart.library.io está disponible
export 'platform_image_web.dart' if (dart.library.io) 'platform_image_io.dart';
