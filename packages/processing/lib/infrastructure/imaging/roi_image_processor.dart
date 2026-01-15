// Export condicional: web por defecto, IO si dart.library.io está disponible
export 'roi_image_processor_web.dart' if (dart.library.io) 'roi_image_processor_io.dart';
