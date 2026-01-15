// Export condicional: web por defecto, IO si dart.library.io está disponible
export 'export_encoders_web.dart' if (dart.library.io) 'export_encoders_io.dart';
