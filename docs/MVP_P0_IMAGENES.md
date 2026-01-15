# MVP P0 - Imagen@rte (IMÁGENES)

## Objetivo
Implementar el núcleo del MVP de Imagen@rte SOLO para IMÁGENES:
- ✅ Detección automática de rostro (on-device)
- ✅ Selección manual por el usuario (ROIs)
- ✅ Aplicar pixelado/blur SOLO en ROIs
- ✅ Export respeta formato elegido (JPG/PNG)
- ✅ Offline-first, sin backend, sin cloud, sin tracking
- ✅ Separación estricta: lógica funcional independiente de estética/UI

## Arquitectura Implementada

### Capas

#### `domain/` (packages/core/lib/domain/)
- **roi.dart**: Modelo canónico de ROI normalizado (0..1)
  - `type`: `face_auto` | `manual`
  - `shape`: `rect` | `ellipse`
  - `x,y,w,h`: double 0..1
  - `locked`: bool
  - `confidence`: double? (solo auto)

- **roi_rules.dart**: Reglas de negocio para ROIs
  - Manual nunca se borra por auto
  - Auto se recalcula solo con acción explícita
  - Si ROI auto colisiona con ROI manual => ignorar auto
  - Si usuario ajusta ROI auto => convertir a manual

#### `application/` (packages/core/lib/application/)
- **ports/face_detector.dart**: Interfaz para detección facial (NO depende de UI)
- **usecases/detect_faces.dart**: Caso de uso para detectar rostros
- **editor_controller.dart**: Controller único para el editor
  - Estado: imagen, autoFaceEnabled, rois, effectMode, effectIntensity
  - Acciones: toggleAutoFace, redetectFaces, addManualRoi, updateRoi, deleteRoi, export

#### `infrastructure/` (packages/processing/lib/infrastructure/)
- **face_detection/mlkit_face_detector.dart**: Implementación ML Kit
- **imaging/roi_image_processor.dart**: Procesador que aplica efectos SOLO en ROIs

#### `presentation/` (apps/mobile/lib/ui/)
- **widgets/roi_overlay.dart**: Overlay editable de ROIs
  - Mostrar ROIs en preview
  - Tap para seleccionar
  - Drag para mover
  - Handles para escalar (4 corners)
  - Botón para borrar

## Funcionalidades P0

### 1. Detección Automática de Rostro
- **Implementación**: ML Kit Face Detection (google_mlkit_face_detection)
- **Ubicación**: `packages/processing/lib/infrastructure/face_detection/mlkit_face_detector.dart`
- **Uso**: 
  ```dart
  final detector = MlKitFaceDetector();
  final rois = await detector.detectFaces(imageBytes, width, height);
  ```
- **UI**: Toggle "Auto detectar rostro" (default ON) + Botón "Re-detectar"

### 2. Selección Manual de ROIs
- **Modelo**: ROI normalizado en `domain/roi.dart`
- **UI**: `RoiOverlay` widget permite:
  - Agregar ROI manual (botón "Agregar zona")
  - Ajustar ROI (drag, resize)
  - Eliminar ROI seleccionada

### 3. Aplicar Efectos SOLO en ROIs
- **Procesador**: `RoiImageProcessor` en `infrastructure/imaging/roi_image_processor.dart`
- **Métodos**:
  - `applyPixelateToRois()`: Aplica pixelado solo en regiones especificadas
  - `applyBlurToRois()`: Aplica blur solo en regiones especificadas
- **Regla**: Si no hay ROIs, exporta imagen sin cambios (pero con metadata stripping)

### 4. Export con Formato Correcto
- **Bug corregido**: `ExportMedia` y `ExifSanitizer` ahora respetan el formato elegido (JPG/PNG)
- **Ubicación**: 
  - `packages/core/lib/usecases/export_media.dart`
  - `packages/core/lib/privacy/exif_sanitizer.dart`
- **Formato**: Se codifica correctamente según `ExportProfile.format`

## Reglas de Negocio (ROI)

### Prioridad de ROIs
1. **ROIs manuales**: Siempre se mantienen, nunca se eliminan automáticamente
2. **ROIs automáticas locked**: Se mantienen aunque se re-detecte
3. **ROIs automáticas no-locked**: Se eliminan al re-detectar si no hay colisión con manuales

### Colisiones
- Si ROI auto colisiona con ROI manual (IOU >= 0.3) => ignorar auto
- Si usuario ajusta ROI auto => convertir a manual (o lockear)

### Re-detección
- Solo elimina ROIs automáticas no-locked
- Mantiene ROIs manuales y auto locked
- Aplica reglas de colisión

## Cómo Funciona

### Flujo Completo

1. **Cargar Imagen**
   ```dart
   final controller = EditorController(detectFacesUseCase);
   await controller.loadImage(imagePath);
   ```
   - Si `autoFaceEnabled = true`, detecta rostros automáticamente
   - Crea ROIs con tipo `face_auto`

2. **Gestión de ROIs**
   - Usuario puede agregar ROI manual: `controller.addManualRoi(...)`
   - Usuario puede ajustar ROI: `controller.updateRoi(id, ...)`
   - Si ajusta ROI auto, se convierte a manual
   - Usuario puede eliminar ROI: `controller.deleteRoi(id)`

3. **Re-detectar**
   ```dart
   await controller.redetectFaces();
   ```
   - Elimina solo ROIs auto no-locked
   - Detecta nuevos rostros
   - Aplica reglas de colisión

4. **Exportar**
   ```dart
   await controller.export(
     outputPath: path,
     format: 'png', // o 'jpg'
     quality: 85,
     processor: roiImageProcessor,
   );
   ```
   - Aplica efecto (pixelate/blur) SOLO en ROIs
   - Codifica en formato elegido
   - Guarda archivo

## Cómo Probarlo Manualmente

### Prerequisitos
1. Flutter SDK instalado
2. Android Studio / Xcode configurado
3. Dispositivo o emulador

### Build y Run

```bash
# Desde la raíz del proyecto
cd apps/mobile
flutter pub get
flutter run
```

### Pruebas Manuales

#### Test 1: Auto-detección de rostro
1. Abrir app
2. Seleccionar imagen con rostro
3. **Esperado**: ROI(s) automática(s) aparecen sobre el rostro
4. Toggle "Auto detectar" OFF
5. **Esperado**: ROIs automáticas desaparecen
6. Toggle "Auto detectar" ON
7. **Esperado**: ROIs automáticas reaparecen

#### Test 2: ROI manual
1. Cargar imagen
2. Presionar "Agregar zona"
3. **Esperado**: ROI manual aparece en el centro
4. Ajustar ROI (drag, resize)
5. **Esperado**: ROI se actualiza
6. Re-detectar rostros
7. **Esperado**: ROI manual NO se borra

#### Test 3: Colisión auto-manual
1. Cargar imagen con rostro
2. Auto-detección crea ROI auto
3. Agregar ROI manual que se superpone con auto
4. Re-detectar
5. **Esperado**: ROI auto que colisiona desaparece, manual se mantiene

#### Test 4: Export con formato
1. Cargar imagen
2. Configurar ROIs
3. Exportar como PNG
4. **Esperado**: Archivo exportado es PNG (verificar signature)
5. Exportar como JPG
6. **Esperado**: Archivo exportado es JPG (verificar signature)

#### Test 5: Efecto solo en ROIs
1. Cargar imagen
2. Agregar ROI
3. Aplicar pixelado
4. Exportar
5. **Esperado**: Solo la región de ROI está pixelada, resto sin cambios

## Comandos de Build/Run

```bash
# Instalar dependencias
cd apps/mobile
flutter pub get

# Ejecutar en dispositivo/emulador
flutter run

# Build APK (Android)
flutter build apk --release

# Build iOS (requiere Mac)
flutter build ios --release
```

## Dependencias Agregadas

### packages/processing/pubspec.yaml
```yaml
dependencies:
  google_mlkit_face_detection: ^0.5.0
```

## Estructura de Archivos Creados

```
packages/core/lib/
  domain/
    roi.dart                    # Modelo ROI
    roi_rules.dart              # Reglas de negocio
  application/
    ports/
      face_detector.dart        # Interfaz detección
    usecases/
      detect_faces.dart         # Caso de uso
    editor_controller.dart      # Controller único

packages/processing/lib/
  infrastructure/
    face_detection/
      mlkit_face_detector.dart  # Implementación ML Kit
    imaging/
      roi_image_processor.dart  # Procesador ROI-based

apps/mobile/lib/ui/widgets/
  roi_overlay.dart             # Widget overlay ROIs
```

## Definition of Done ✅

- [x] Cargar imagen -> Auto detecta rostro y crea ROI(s) (si hay rostro)
- [x] Usuario puede agregar ROI manual y ajustarlo
- [x] Re-detectar NO borra ROI manual
- [x] Export aplica pixel/blur SOLO en las ROI(s)
- [x] Export respeta JPG/PNG (bug solucionado)
- [x] No hay red, no hay tracking, no hay cloud

## Notas de Implementación

### Separación de Capas
- `domain` y `application` NO importan `material.dart` ni nada de UI
- `presentation` NO implementa reglas de negocio
- UI interactúa solo con `EditorController` expuesto por `application`

### Offline-First
- ✅ Todo local (ML Kit on-device)
- ✅ Sin requests de red
- ✅ Sin Firebase
- ✅ Sin tracking

### EXIF/Metadata
- Se mantiene el stripping de metadata en export
- `ExifSanitizer` ahora respeta el formato elegido

## Próximos Pasos (P1 - Fuera del MVP)

- [ ] Mejorar UI del editor (pantalla dedicada)
- [ ] Integrar ROI overlay en wizard/export screen
- [ ] Agregar modo "dibujar rect" para ROI manual
- [ ] Preview en tiempo real del efecto
- [ ] Soporte para múltiples efectos simultáneos
- [ ] Tests unitarios para ROI rules
- [ ] Tests de integración para pipeline ROI-based
