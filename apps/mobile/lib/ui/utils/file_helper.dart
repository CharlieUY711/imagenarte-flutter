// Export condicional: web por defecto, IO si dart.library.io está disponible
export 'file_helper_web.dart' if (dart.library.io) 'file_helper_io.dart';
