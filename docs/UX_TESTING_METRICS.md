# UX Testing Metrics — Especificación Técnica

## Advertencia Importante

⚠️ **No se recolecta PII (Personally Identifiable Information)**.  
⚠️ **Exportación manual**: Los datos solo se exportan cuando el usuario lo solicita explícitamente.  
⚠️ **Sin envío automático**: Ningún dato sale del dispositivo automáticamente.

---

## Métricas Locales Mínimas

### Por Tarea

#### 1. Tiempo por Tarea
- **Tipo**: `number` (segundos)
- **Descripción**: Tiempo transcurrido desde el inicio de la tarea hasta su completitud
- **Ejemplo**: `{"task": "import_image", "duration_seconds": 12.5}`

#### 2. Cantidad de Intentos
- **Tipo**: `number` (entero)
- **Descripción**: Número de veces que el usuario intentó completar la tarea antes de lograrlo
- **Ejemplo**: `{"task": "pixelate_face", "attempts": 2}`

#### 3. Export Exitoso
- **Tipo**: `boolean`
- **Descripción**: Indica si la tarea se completó exitosamente (sí/no)
- **Ejemplo**: `{"task": "export_with_exif", "success": true}`

#### 4. Crash
- **Tipo**: `boolean`
- **Descripción**: Indica si la app crasheó durante la tarea
- **Ejemplo**: `{"task": "blur_region", "crashed": false}`

#### 5. Rating de Claridad
- **Tipo**: `number` (1-5)
- **Descripción**: Calificación subjetiva del usuario sobre qué tan clara fue la tarea
- **Ejemplo**: `{"task": "remove_background", "clarity_rating": 4}`

### Métricas Globales de Sesión

#### 6. Tiempo Total de Sesión
- **Tipo**: `number` (segundos)
- **Descripción**: Tiempo total desde el inicio hasta el final de la sesión de testing

#### 7. Tareas Completadas
- **Tipo**: `number` (entero)
- **Descripción**: Número total de tareas completadas exitosamente

#### 8. Tareas Fallidas
- **Tipo**: `number` (entero)
- **Descripción**: Número total de tareas que no se completaron

#### 9. Total de Crashes
- **Tipo**: `number` (entero)
- **Descripción**: Número total de crashes durante la sesión

---

## Estructura de Datos JSON

### Evento Individual
```json
{
  "type": "task_start" | "task_end" | "task_error" | "crash" | "rating",
  "timestamp": 1234567890.123,
  "task_id": "import_image" | "pixelate_face" | "blur_region" | "remove_background" | "export_exif" | "export_watermark" | "export_receipt",
  "payload": {
    // Contenido específico según el tipo
  }
}
```

### Ejemplo: Inicio de Tarea
```json
{
  "type": "task_start",
  "timestamp": 1704123456.789,
  "task_id": "pixelate_face",
  "payload": {}
}
```

### Ejemplo: Fin de Tarea Exitoso
```json
{
  "type": "task_end",
  "timestamp": 1704123478.123,
  "task_id": "pixelate_face",
  "payload": {
    "success": true,
    "duration_seconds": 21.334,
    "attempts": 1
  }
}
```

### Ejemplo: Error en Tarea
```json
{
  "type": "task_error",
  "timestamp": 1704123500.456,
  "task_id": "blur_region",
  "payload": {
    "error_type": "user_confusion" | "technical_error",
    "error_message": "Usuario no encontró el control" // Solo descriptivo, sin PII
  }
}
```

### Ejemplo: Crash
```json
{
  "type": "crash",
  "timestamp": 1704123520.789,
  "task_id": "remove_background",
  "payload": {
    "error_code": "crash_001", // Código genérico, no stack trace completo
    "recovered": true
  }
}
```

### Ejemplo: Rating de Claridad
```json
{
  "type": "rating",
  "timestamp": 1704123540.012,
  "task_id": "export_exif",
  "payload": {
    "clarity_rating": 4,
    "scale": "1-5"
  }
}
```

### Reporte Completo Exportado
```json
{
  "session_id": "session_20240101_123456", // ID generado localmente, no relacionado con usuario
  "session_start": 1704123456.789,
  "session_end": 1704124000.000,
  "total_duration_seconds": 543.211,
  "tasks_completed": 6,
  "tasks_failed": 1,
  "total_crashes": 0,
  "tasks": [
    {
      "task_id": "import_image",
      "start_time": 1704123456.789,
      "end_time": 1704123469.123,
      "duration_seconds": 12.334,
      "attempts": 1,
      "success": true,
      "crashed": false,
      "clarity_rating": 5
    },
    {
      "task_id": "pixelate_face",
      "start_time": 1704123470.000,
      "end_time": 1704123491.334,
      "duration_seconds": 21.334,
      "attempts": 1,
      "success": true,
      "crashed": false,
      "clarity_rating": 4
    }
    // ... más tareas
  ],
  "export_timestamp": 1704124010.000,
  "export_format_version": "1.0"
}
```

---

## Restricciones de Datos

### ❌ NO se captura:
- Nombres de archivos de imágenes
- Rutas completas de archivos
- Hashes de contenido de imágenes
- Información del dispositivo (modelo, IMEI, etc.)
- Información de red (IP, MAC, etc.)
- Ubicación GPS
- Información de cuenta o usuario
- Stack traces completos (solo códigos genéricos)
- Capturas de pantalla automáticas
- Audio o video

### ✅ SÍ se captura:
- Timestamps relativos a la sesión
- Duración de tareas (números)
- Contadores (intentos, crashes)
- Ratings numéricos (1-5)
- Códigos de error genéricos (no descriptivos de datos personales)
- IDs de sesión generados localmente (no relacionados con usuario)

---

## Formato de Exportación

### JSON (Recomendado)
- **Extensión**: `.json`
- **Encoding**: UTF-8
- **Pretty print**: Sí (legible)
- **Ubicación**: Elegida por el usuario (share, guardar, etc.)

### CSV (Opcional)
- **Extensión**: `.csv`
- **Encoding**: UTF-8
- **Columnas**: `task_id`, `start_time`, `end_time`, `duration_seconds`, `attempts`, `success`, `crashed`, `clarity_rating`

---

## Activación del Modo Testing

### Requisitos
- **Por defecto**: DESACTIVADO
- **Activación**: Solo desde pantalla Debug/Config
- **Indicador visual**: Banner o badge visible cuando está activo
- **Persistencia**: No persiste entre sesiones (se resetea al cerrar app)

### Flujo de Uso
1. Usuario activa "Modo Testing" en Debug
2. Banner visible: "Modo Testing activo - Métricas locales habilitadas"
3. Usuario realiza tareas normalmente
4. Métricas se registran en memoria (o archivo temporal)
5. Usuario puede exportar reporte manualmente desde Debug
6. Al desactivar o cerrar app, datos se limpian (opcional: mantener hasta exportar)

---

## Implementación Técnica

### Módulos Requeridos
- `ux_event.dart`: Define estructura de eventos
- `ux_logger.dart`: Almacena eventos en memoria/temporal
- `ux_report.dart`: Genera reporte agregado y exportable

### Integración
- **No invasiva**: Solo se activa si "Modo Testing" está ON
- **Sin overhead**: Si está OFF, no hay procesamiento
- **Aislado**: No afecta funcionalidad normal de la app

---

## Ejemplo de Uso

### Durante Sesión
1. Moderador activa "Modo Testing" en dispositivo
2. Tester realiza tareas
3. Sistema registra eventos automáticamente (si está implementado)
4. Moderador puede ver métricas en tiempo real (opcional)

### Post-Sesión
1. Moderador exporta reporte JSON desde Debug
2. Reporte se comparte manualmente (email, drive, etc.)
3. Datos se analizan fuera de la app
4. Datos se eliminan del dispositivo (opcional: limpieza automática)

---

**Versión**: 1.0  
**Última actualización**: 2024
