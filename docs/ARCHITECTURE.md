# Arquitectura: Imagen@rte

## Visión General

Imagen@rte sigue una arquitectura modular y offline-first, separando claramente las capas de presentación, lógica de negocio y procesamiento.

## Estructura del Proyecto

```
imagenarte/
  apps/
    mobile/              # Aplicación Flutter principal
      lib/
        main.dart
        app.dart
        navigation/      # Enrutamiento
        ui/
          screens/       # Pantallas (Home, Wizard, Export)
          components/    # Componentes reutilizables
        state/           # Gestión de estado (futuro)
      android/
      ios/
  packages/
    core/                # Lógica de negocio y dominio
      domain/            # Entidades (Session, Operation, ExportProfile)
      usecases/          # Casos de uso (ApplyOperation, ExportMedia, etc.)
      privacy/           # Utilidades de privacidad (ExifSanitizer, TempCleanup)
    processing/          # Pipeline de procesamiento
      pipeline/          # ImagePipeline (orquestador)
      ops/               # Operaciones individuales
        pixelate_face/
        blur_region/
        remove_background/
        smart_crop/
      engines/           # Motores de ML (futuro: face_detection, segmentation)
    watermark/           # Sistema de watermarks
      visible/           # Watermark visible
      invisible/         # Watermark invisible (esteganografía básica)
  docs/                  # Documentación
```

## Capas del Sistema

### 1. Capa de Presentación (UI)
- **Responsabilidad**: Interfaz de usuario, navegación, entrada del usuario
- **Tecnología**: Flutter widgets, Material Design
- **Pantallas**:
  - `HomeScreen`: Punto de entrada
  - `WizardScreen`: Flujo de tratamiento (3 pasos)
  - `ExportScreen`: Configuración y exportación

### 2. Capa de Dominio (Core)
- **Responsabilidad**: Entidades de negocio, casos de uso, reglas de negocio
- **Entidades**:
  - `Session`: Representa una sesión de trabajo
  - `Operation`: Tipo y parámetros de una operación
  - `ExportProfile`: Configuración de exportación
- **Casos de Uso**:
  - `ApplyOperation`: Aplica una operación a una imagen
  - `ExportMedia`: Exporta con sanitización y watermarks
  - `SanitizeMetadata`: Limpia metadatos EXIF

### 3. Capa de Procesamiento
- **Responsabilidad**: Transformación de imágenes
- **Componentes**:
  - `ImagePipeline`: Orquestador de operaciones
  - Operaciones individuales (stubs iniciales, algunas funcionales)
- **Futuro**: Integración con MediaPipe/MLKit para detección facial y segmentación

### 4. Capa de Privacidad
- **Responsabilidad**: Protección de datos y limpieza
- **Componentes**:
  - `ExifSanitizer`: Elimina metadatos EXIF
  - `TempCleanup`: Limpia archivos temporales
  - `VisibleWatermark`: Aplica watermark visible
  - `InvisibleWatermark`: Aplica watermark invisible (LSB con token HMAC-SHA256)
  - `SessionSecret`: Gestiona clave secreta local para tokens
  - `WatermarkToken`: Genera tokens HMAC-SHA256 para watermark
  - `ExportManifest`: Comprobante local de exportación (opcional)

## Flujo de Datos

### Flujo de Tratamiento
```
Usuario selecciona imagen
  ↓
WizardScreen captura operaciones
  ↓
ExportScreen inicia procesamiento
  ↓
ImagePipeline aplica operaciones en orden
  ↓
Cada operación genera archivo temporal
  ↓
Resultado final listo para export
```

### Flujo de Exportación
```
Usuario configura export profile
  ↓
ExportMedia.execute()
  ↓
1. Sanitizar EXIF (si está habilitado)
  ↓
2. Aplicar watermark visible (si está habilitado)
  ↓
3. Watermark invisible (si está habilitado):
   - Leer bytes pre-watermark
   - Generar nonce
   - Calcular token HMAC-SHA256(session_secret, fingerprint)
   - Embebir token en LSB de píxeles dispersos
  ↓
4. Copiar a destino final
  ↓
5. Calcular hash final y generar manifest (si exportManifest está habilitado)
  ↓
6. TempCleanup elimina temporales
```

## Separación Core / Processing

- **Core**: No depende de processing. Define interfaces y contratos.
- **Processing**: Depende de core para tipos de dominio (Operation, etc.).
- **UI**: Depende de ambos, pero principalmente de core para casos de uso.

## Offline-First Enforcement

### Reglas Arquitectónicas
1. **Sin dependencias de red**: No hay imports de paquetes HTTP/WebSocket en core
2. **Procesamiento local**: Todas las operaciones usan librerías on-device
3. **Almacenamiento local**: Solo usa `path_provider` para directorios del sistema
4. **Sin servicios externos**: No hay llamadas a APIs, Firebase, etc.

### Validación
- Revisar `pubspec.yaml` para asegurar que no hay dependencias cloud
- Revisar imports en código para detectar dependencias de red
- Tests deben poder ejecutarse sin conexión

## Extensibilidad

### Agregar Nueva Operación
1. Crear clase en `packages/processing/ops/nueva_op/`
2. Implementar método `apply(String imagePath, OperationParams params)`
3. Agregar `OperationType` en `packages/core/domain/operation.dart`
4. Registrar en `ImagePipeline.applyOperation()`
5. Agregar UI en `WizardScreen`

### Agregar Nuevo Watermark
1. Crear clase en `packages/watermark/tipo/`
2. Implementar método `apply(...)`
3. Integrar en `ExportMedia.execute()`
4. Agregar toggle en `ExportScreen`

## Estado Actual (MVP)

- ✅ Arquitectura base definida
- ✅ Navegación implementada
- ✅ Pipeline definido
- ✅ Operaciones básicas (pixelado, blur, crop) funcionales
- ⚠️ Operaciones avanzadas (quitar fondo, detección facial real) son stubs
- ✅ Sanitización EXIF básica
- ✅ Watermark visible básico
- ✅ Watermark invisible básico (LSB con token HMAC-SHA256)

## Próximos Pasos Arquitectónicos

1. Integrar MediaPipe/MLKit para detección facial real
2. Implementar segmentación para quitar fondo
3. Mejorar watermark invisible con esteganografía
4. Agregar gestión de estado (Provider/Riverpod) si es necesario
5. Optimizar pipeline para procesar múltiples operaciones eficientemente
