# Modelo de Privacidad: Imagen@rte

## Principio D0 Estricto

Imagen@rte implementa un modelo de privacidad **D0 estricto**, donde:
- **D0**: Datos en el dispositivo (Device Zero)
- **Estricto**: Ninguna imagen original se persiste fuera del dispositivo

## Manejo de Imágenes

### Flujo de Datos
1. **Selección**: Usuario selecciona imagen desde galería o cámara
2. **Importación temporal**: Imagen se copia a directorio temporal de la app
3. **Procesamiento**: Todas las operaciones se realizan localmente
4. **Exportación**: Usuario decide dónde guardar el resultado final
5. **Limpieza**: Archivos temporales se eliminan automáticamente

### Almacenamiento
- **Temporales**: Directorio temporal de la app (`getTemporaryDirectory()`)
- **Exportados**: Directorio de documentos del usuario (`getApplicationDocumentsDirectory()`)
- **Nunca**: Servidores remotos, cloud storage, bases de datos externas

### Persistencia
- ❌ **NO se persisten imágenes originales** fuera del dispositivo
- ❌ **NO se envían imágenes crudas** a servidores
- ✅ **Solo se guardan** imágenes procesadas si el usuario explícitamente exporta
- ✅ **Temporales se eliminan** al finalizar la sesión

## Metadatos EXIF

### Información que se elimina (por defecto)
- **Ubicación**: GPS coordinates (latitud, longitud, altitud)
- **Fecha y hora**: Timestamp de captura
- **Dispositivo**: Modelo de cámara, fabricante
- **Configuración**: ISO, apertura, velocidad de obturación
- **Software**: Aplicación que editó la imagen
- **Orientación**: Información de rotación
- **Thumbnails**: Miniaturas embebidas

### Implementación
- **Por defecto ON**: `sanitizeMetadata = true` en `ExportProfile`
- **Método**: Decodificar imagen, eliminar todos los metadatos, re-codificar
- **Resultado**: Imagen limpia sin información personal

## Permisos del Sistema

### Android
- `READ_EXTERNAL_STORAGE`: Para acceder a imágenes de la galería
- `WRITE_EXTERNAL_STORAGE`: Para guardar imágenes exportadas (Android < 10)
- `CAMERA`: Para capturar imágenes desde la cámara

### iOS
- `NSPhotoLibraryUsageDescription`: Para acceder a la galería
- `NSCameraUsageDescription`: Para usar la cámara
- `NSPhotoLibraryAddUsageDescription`: Para guardar imágenes exportadas

### Principio de Mínimo Privilegio
- Solo se solicitan permisos cuando el usuario los necesita
- No se solicitan permisos innecesarios (ubicación, contactos, etc.)
- Permisos se pueden revocar en cualquier momento

## Watermarks

### Watermark Visible
- **Propósito**: Protección de autoría, disuasión de uso no autorizado
- **Implementación**: Texto superpuesto en la imagen
- **Control**: Usuario decide si aplicarlo y qué texto usar
- **Privacidad**: No se almacena información sobre watermarks aplicados

### Watermark Invisible
- **Propósito**: Identificación de autoría sin afectar la estética
- **Implementación**: Esteganografía básica usando LSB (Least Significant Bit)
- **Método**: 
  - Token HMAC-SHA256 derivado de clave local (session_secret)
  - Token embebido en bits menos significativos de píxeles seleccionados
  - Grilla pseudoaleatoria basada en nonce para dispersión
- **Límites**: 
  - Básico/no forense: vulnerable a recodificación, rescale, filtros, screenshot, re-encode
  - Adecuado para MVP y verificación local básica
  - Para mayor robustez, se requeriría DCT/frecuencia (futuro)
- **Privacidad**: 
  - Clave secreta (session_secret) se genera y almacena localmente
  - Token se calcula localmente, no se transmite
  - Comprobante (manifest) opcional, solo se guarda si el usuario lo solicita

## Archivos Temporales

### Ciclo de Vida
1. **Creación**: Al importar imagen o aplicar operación
2. **Uso**: Durante el procesamiento
3. **Eliminación**: Al exportar o cancelar sesión

### Limpieza Automática
- `TempCleanup.deleteFile()`: Elimina archivo individual
- `TempCleanup.deleteFiles()`: Elimina múltiples archivos
- **Momento**: Al finalizar exportación exitosa
- **Fallback**: Al cerrar la app (si es posible detectar)

### Nombres de Archivos
- **Formato**: `{original_path}_{operation}_{timestamp}.jpg`
- **Ejemplo**: `/tmp/image_pixelated_1234567890.jpg`
- **Propósito**: Evitar colisiones, facilitar debugging

## No Recolección de Datos

### Lo que NO se recolecta
- ❌ Información personal (nombre, email, teléfono)
- ❌ Ubicación GPS
- ❌ Historial de uso
- ❌ Imágenes procesadas (excepto si el usuario exporta)
- ❌ Metadatos de imágenes
- ❌ Identificadores de dispositivo
- ❌ Información de red

### Lo que SÍ se almacena localmente
- ✅ Preferencias de usuario (formato, calidad por defecto) - solo localmente
- ✅ Archivos temporales durante la sesión - se eliminan después
- ✅ Clave secreta de sesión (session_secret) - almacenada cifrada localmente
- ✅ Comprobantes de exportación (manifest.json) - solo si el usuario lo solicita explícitamente

## Sin Tracking

- ❌ No hay analytics
- ❌ No hay crash reporting remoto
- ❌ No hay telemetría
- ❌ No hay identificadores de sesión remotos
- ✅ Todo es local y efímero

## Transparencia

### Para el Usuario
- **Control total**: Usuario decide qué operaciones aplicar
- **Visibilidad**: Preview antes/después
- **Exportación explícita**: Usuario debe presionar "Exportar"
- **Configuración clara**: Toggles y sliders obvios

### Para el Desarrollador
- **Código abierto**: Arquitectura clara y documentada
- **Sin código ofuscado**: Procesamiento visible y auditable
- **Logs locales**: Solo para debugging, no se envían

## Mitigación de Riesgos

### Riesgo: Fuga de metadatos
- **Mitigación**: Sanitización EXIF por defecto

### Riesgo: Archivos temporales persistentes
- **Mitigación**: Limpieza automática al exportar

### Riesgo: Acceso no autorizado a imágenes
- **Mitigación**: Permisos del sistema, sandbox de la app

### Riesgo: Procesamiento en servidor
- **Mitigación**: Arquitectura offline-first, sin dependencias de red

## Cumplimiento

### GDPR
- No se procesan datos personales fuera del dispositivo
- No hay transferencias internacionales
- Usuario tiene control total sobre sus datos

### CCPA
- No se venden datos (no hay datos que vender)
- Usuario puede eliminar todos los datos (solo archivos locales)

### COPPA
- No se recolectan datos de menores
- No hay servicios que requieran edad mínima

## Conclusión

Imagen@rte está diseñado desde el principio para maximizar la privacidad del usuario, implementando D0 estricto y dando control total al usuario sobre sus imágenes y datos.
