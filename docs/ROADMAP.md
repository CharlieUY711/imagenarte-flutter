# Roadmap: Imagen@rte

## Fase 1: MVP Imagen (Actual)

### ✅ Completado
- [x] Arquitectura base independiente
- [x] Navegación básica (Home → Wizard → Export)
- [x] Pipeline de procesamiento definido
- [x] Operaciones básicas:
  - [x] Pixelado de rostro (simulado)
  - [x] Blur selectivo (general)
  - [x] Crop inteligente (presets)
- [x] Sanitización EXIF
- [x] Watermark visible básico
- [x] Limpieza de temporales
- [x] Documentación completa

### 🚧 En Progreso / Pendiente MVP
- [ ] Testing básico
- [ ] Mejora de manejo de errores
- [ ] Optimización de UI/UX

---

## Fase 2: Post-MVP Imagen

### Detección Facial Real
- [ ] Integrar MediaPipe Face Detection o MLKit
- [ ] Detección automática de rostros
- [ ] Pixelado selectivo solo en rostros detectados
- [ ] Opción de pixelar múltiples rostros
- [ ] Ajuste fino de región a pixelar

### Blur Selectivo Avanzado
- [ ] Interfaz para marcar regiones manualmente
- [ ] Múltiples regiones de blur
- [ ] Diferentes intensidades por región
- [ ] Blur inteligente (detección de objetos)

### Quitar Fondo
- [ ] Integrar MediaPipe Selfie Segmentation o MLKit
- [ ] Segmentación automática de persona/objeto
- [ ] Fondo transparente o color sólido
- [ ] Ajuste fino de bordes
- [ ] Preview en tiempo real

### Crop Inteligente Mejorado
- [ ] Detección de composición (regla de tercios)
- [ ] Sugerencias automáticas de crop
- [ ] Crop libre (no solo presets)
- [ ] Rotación y ajuste fino

### Watermark Invisible Avanzado
- [ ] Esteganografía básica (LSB)
- [ ] Hash único por imagen
- [ ] Verificación de watermark
- [ ] Opciones de robustez

### Optimizaciones
- [ ] Procesamiento en background
- [ ] Preview de baja resolución
- [ ] Procesamiento por chunks (imágenes grandes)
- [ ] Cache de resultados intermedios
- [ ] Reducción de consumo de memoria

### UX/UI Mejoras
- [ ] Animaciones suaves
- [ ] Feedback visual mejorado
- [ ] Tutorial/onboarding
- [ ] Modo oscuro
- [ ] Internacionalización (i18n)

### Privacidad Avanzada
- [ ] Encriptación opcional de temporales
- [ ] Borrado seguro de archivos
- [ ] Configuración de privacidad por defecto
- [ ] Auditoría de permisos

---

## Fase 3: Video

### V0: Pipeline y Tracking (Actual - Esqueleto)
- [x] Arquitectura del pipeline de video
- [x] VideoSession y TrackingRegion (dominio)
- [x] Interfaces de operaciones de video:
  - [x] PixelateFaceVideoOp (auto-detección con fallback manual)
  - [x] BlurRegionVideoOp (manual)
  - [x] DynamicWatermarkVideoOp (por sesión)
- [x] Engines de abstracción:
  - [x] FrameExtractorEngine (iteración de frames)
  - [x] FaceDetectionEngine (stub)
  - [x] TrackerEngine (IOU + smoothing simple)
  - [x] RendererEngine (stub)
- [x] VideoPipeline con flujo base
- [x] Generación de plan de procesamiento (metadata JSON)
- [x] Tests básicos para TrackerEngine (IOU association)
- [ ] UI mínima (placeholder, flag debug)

### V1: Render Offline (Próxima Iteración)
- [ ] Implementación real de FrameExtractorEngine
  - [ ] Extracción de frames usando plugin local o FFmpeg
  - [ ] Información de video (fps, duración, resolución)
- [ ] Integración de detección facial real
  - [ ] MediaPipe Face Detection o MLKit
  - [ ] Detección frame a frame
- [ ] Render real de video
  - [ ] FFmpeg local o APIs nativas
  - [ ] Aplicación de operaciones a frames
  - [ ] Composición de video final
- [ ] Funcionalidad Básica
  - [ ] Selección de video (galería/cámara)
  - [ ] Preview de video
  - [ ] Export de video procesado

### V2: Optimización y Calidad
- [ ] Optimizaciones de Video
  - [ ] Procesamiento eficiente (no frame por frame completo)
  - [ ] Detección de cambios (solo procesar frames con cambios)
  - [ ] Compresión inteligente
  - [ ] Preview en tiempo real
- [ ] Optimización de memoria para videos largos
- [ ] Tracking mejorado
  - [ ] Kalman filter para suavizado
  - [ ] Manejo de oclusiones
  - [ ] Tracking multi-objeto robusto
- [ ] Operaciones adicionales
  - [ ] Quitar fondo en video
  - [ ] Crop/recorte de video

---

## Fase 4: Features Avanzadas (Lejano Futuro)

### Colaboración Local
- [ ] Compartir perfiles de exportación (archivo local)
- [ ] Presets personalizables
- [ ] Plantillas de tratamiento

### Automatización
- [ ] Batch processing (múltiples imágenes)
- [ ] Presets automáticos por tipo de contenido
- [ ] Procesamiento programado

### Análisis
- [ ] Detección de objetos (opcional, local)
- [ ] Análisis de composición
- [ ] Sugerencias de mejora

### Extensibilidad
- [ ] Plugin system (local)
- [ ] Operaciones personalizadas
- [ ] Integración con otras apps (export)

---

## Priorización

### Alta Prioridad (Próximos 3 meses)
1. Detección facial real
2. Blur selectivo con marcado manual
3. Quitar fondo funcional
4. Optimizaciones de rendimiento

### Media Prioridad (3-6 meses)
1. Watermark invisible avanzado
2. Crop inteligente mejorado
3. UX/UI mejoras
4. Testing exhaustivo

### Baja Prioridad (6+ meses)
1. Funcionalidad de video
2. Features avanzadas
3. Extensibilidad

---

## Criterios de Éxito

### MVP
- ✅ App compila y funciona
- ✅ Navegación básica implementada
- ✅ Pipeline definido
- ✅ Documentación completa
- ⚠️ Al menos una operación funcional (pixelado/blur)

### Post-MVP
- [ ] Detección facial real funcional
- [ ] Quitar fondo funcional
- [ ] Rendimiento aceptable en dispositivos de gama media
- [ ] UX pulida y clara

### Video
- [ ] Procesamiento de video funcional
- [ ] Rendimiento aceptable para videos cortos (< 1 min)
- [ ] Export de calidad aceptable

---

## Notas

- **Offline-First**: Todas las features deben funcionar sin conexión
- **Privacidad**: Todas las features deben respetar D0 estricto
- **Simplicidad**: No agregar complejidad innecesaria
- **Extensibilidad**: Arquitectura debe permitir agregar features fácilmente

## Actualización

Este roadmap se actualizará según feedback de usuarios y necesidades del proyecto.
