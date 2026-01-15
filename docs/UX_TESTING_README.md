# UX Testing Kit — Guía Rápida

## Resumen

Se ha implementado un sistema completo de UX Testing para Imagen@rte que cumple con los principios D0 estricto y offline-first.

## Componentes Implementados

### 📄 Documentación

1. **`UX_TESTING_PLAYBOOK.md`**: Guía completa para moderadores
   - Objetivos de investigación
   - Perfil de testers
   - Setup de sesión
   - Guión moderado con preguntas
   - 7 tareas detalladas
   - Criterios de éxito y señales de fricción

2. **`UX_TESTING_TASKS.md`**: Lista imprimible para sesiones
   - Checklist por tarea
   - Espacios para observaciones
   - Preguntas de cierre
   - Resumen de sesión

3. **`UX_TESTING_METRICS.md`**: Especificación técnica
   - Métricas locales mínimas
   - Estructura de datos JSON/CSV
   - Restricciones de datos (no PII)
   - Formato de exportación

### 💻 Código

#### Módulo de Instrumentación (`apps/mobile/lib/state/ux_testing/`)

1. **`ux_event.dart`**: Estructura de eventos
   - Tipos de eventos (taskStart, taskEnd, taskError, crash, rating)
   - IDs de tareas (importImage, pixelateFace, blurRegion, etc.)
   - Factory methods para crear eventos fácilmente

2. **`ux_logger.dart`**: Logger local
   - Almacenamiento en memoria
   - Persistencia opcional en archivo temporal
   - Estadísticas en tiempo real
   - Limpieza automática al desactivar

3. **`ux_report.dart`**: Generador de reportes
   - Agregación de métricas por tarea
   - Exportación a JSON (formateado)
   - Exportación a CSV
   - Cálculo automático de duraciones e intentos

#### Pantalla Debug (`apps/mobile/lib/ui/screens/debug/`)

1. **`ux_testing_screen.dart`**: Interfaz de usuario
   - Toggle "Modo Testing" (OFF por defecto)
   - Estadísticas en tiempo real
   - Lista de eventos recientes
   - Exportación manual (JSON, CSV, copiar al portapapeles)
   - Banner de advertencia sobre privacidad

#### Integración

- **Router**: Ruta `/debug/ux-testing` agregada
- **HomeScreen**: Botón de acceso en AppBar (ícono de bug)
- **Dependencias**: `share_plus` agregado para exportar archivos

## Uso

### Para Moderadores

1. **Preparación**:
   - Leer `UX_TESTING_PLAYBOOK.md`
   - Imprimir `UX_TESTING_TASKS.md`
   - Preparar dispositivo con build de testing

2. **Durante la sesión**:
   - Activar "Modo Testing" desde la pantalla Debug
   - Seguir el guión del playbook
   - Observar y tomar notas manuales
   - Las métricas se registran automáticamente (si se integra en el código)

3. **Post-sesión**:
   - Exportar reporte JSON/CSV desde la pantalla Debug
   - Combinar con observaciones manuales
   - Analizar fuera de la app

### Para Desarrolladores

#### Activar Modo Testing

```dart
import 'package:imagenarte/state/ux_testing/ux_testing.dart';

final logger = UXLogger();
await logger.enable(); // Activa el logging
```

#### Registrar Eventos

```dart
// Inicio de tarea
logger.log(UXEvent.taskStart(taskId: UXTaskId.pixelateFace));

// Fin de tarea
logger.log(UXEvent.taskEnd(
  taskId: UXTaskId.pixelateFace,
  success: true,
  durationSeconds: 12.5,
  attempts: 1,
));

// Error
logger.log(UXEvent.taskError(
  taskId: UXTaskId.blurRegion,
  errorType: UXErrorType.userConfusion,
  errorMessage: 'Usuario no encontró el control',
));

// Rating
logger.log(UXEvent.rating(
  taskId: UXTaskId.exportExif,
  clarityRating: 4,
));
```

#### Exportar Reporte

```dart
final report = UXReport(logger);
final jsonString = report.toJsonString();
final csvString = report.toCsvString();
```

#### Desactivar

```dart
await logger.disable(); // Limpia datos y archivos temporales
```

## Integración en el Código

Para que las métricas se registren automáticamente durante las sesiones, necesitas integrar el logger en las pantallas principales:

### Ejemplo: WizardScreen

```dart
import 'package:imagenarte/state/ux_testing/ux_testing.dart';

class _WizardScreenState extends State<WizardScreen> {
  final _logger = UXLogger();
  DateTime? _taskStartTime;
  
  void _onImageSelected() {
    if (_logger.isEnabled) {
      _taskStartTime = DateTime.now();
      _logger.log(UXEvent.taskStart(taskId: UXTaskId.importImage));
    }
    // ... lógica de selección
  }
  
  void _onImageLoaded() {
    if (_logger.isEnabled && _taskStartTime != null) {
      final duration = DateTime.now().difference(_taskStartTime!).inSeconds.toDouble();
      _logger.log(UXEvent.taskEnd(
        taskId: UXTaskId.importImage,
        success: true,
        durationSeconds: duration,
        attempts: 1,
      ));
    }
  }
}
```

## Características de Privacidad

✅ **No se captura PII**:
- No nombres de archivos
- No rutas completas
- No hashes de contenido
- No información del dispositivo
- No datos personales

✅ **Solo métricas locales**:
- Tiempos (números)
- Contadores (intentos, crashes)
- Ratings (1-5)
- Códigos de error genéricos

✅ **Exportación manual**:
- Usuario debe activar exportación explícitamente
- Datos solo salen del dispositivo cuando el usuario lo decide
- Se puede compartir vía share_plus o copiar al portapapeles

✅ **Limpieza automática**:
- Datos se eliminan al desactivar Modo Testing
- Archivos temporales se limpian al cerrar app

## Próximos Pasos

1. **Integrar logger en pantallas**: Agregar llamadas a `UXLogger` en las pantallas principales (WizardScreen, ExportScreen) para registrar eventos automáticamente.

2. **Testing**: Probar el flujo completo:
   - Activar Modo Testing
   - Realizar tareas
   - Verificar eventos registrados
   - Exportar reporte

3. **Iteración**: Basado en feedback de sesiones reales, ajustar métricas y eventos según necesidad.

## Notas

- El Modo Testing está **DESACTIVADO por defecto**
- Solo se activa manualmente desde la pantalla Debug
- No afecta la funcionalidad normal de la app cuando está desactivado
- Los datos se almacenan localmente y nunca se envían automáticamente

---

**Versión**: 1.0  
**Fecha**: 2024
