# FASE 2: Validación Flujo End-to-End

## Objetivo
Validar y cerrar el flujo End-to-End en Android físico:
**Importar imagen → Preview → Crear selección (ROI) → Aplicar herramienta → Undo (>=10) → Export final válido**

## Fixes Aplicados

### 1. Conexión de Botones de Herramientas
**Archivo**: `apps/mobile/lib/presentation/screens/editor_screen.dart`

**Problema**: Los botones "Pixelar rostro" y "Blur selectivo" estaban como TODOs y no estaban conectados.

**Solución**: 
- Conectados con `_viewModel.setEffectMode()` y `_viewModel.setEffectIntensity()`
- Validación: muestra mensaje si no hay ROIs antes de aplicar herramienta
- Actualiza preview inmediatamente después de aplicar

**Código**:
```dart
onPixelateFace: () {
  if (_viewModel.rois.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(...);
    return;
  }
  _viewModel.setEffectMode(EffectMode.pixelate);
  _viewModel.setEffectIntensity(5);
  _updateProcessedImage(immediate: true);
}
```

### 2. Export: Aplicar Solo a ROI Activa
**Archivo**: `apps/mobile/lib/presentation/adapters/editor_view_model.dart` (método `export`)

**Problema**: El export procesaba TODAS las ROIs, no solo la ROI activa cuando había una seleccionada.

**Solución**: 
- Si hay ROI activa, procesar SOLO esa ROI
- Si no hay ROI activa, procesar todas las ROIs (comportamiento anterior)

**Código**:
```dart
// REGLA: Si hay ROI activa, aplicar SOLO a esa ROI; si no, aplicar a todas las ROIs
final activeRoi = _controller.getActiveRoi();
final roisToProcess = activeRoi != null ? [activeRoi] : _controller.rois;
```

### 3. Optimización del Historial (Undo)
**Archivo**: `apps/mobile/lib/presentation/adapters/editor_view_model.dart` (método `setSelectedRoiId`)

**Problema**: Cambiar solo la selección de ROI hacía commit al historial, llenando el stack con operaciones innecesarias.

**Solución**: 
- Removido `_commitToHistory()` de `setSelectedRoiId()`
- El historial solo se actualiza cuando hay cambios reales (aplicar herramienta, ajustes, agregar/eliminar ROI)

**Nota**: Cambiar selección no es una operación que deba deshacerse, solo cambia qué ROI está activa.

### 4. Métodos Faltantes en ViewModel
**Archivo**: `apps/mobile/lib/presentation/adapters/editor_view_model.dart`

**Problema**: Faltaban métodos para establecer `effectMode` y `effectIntensity` desde la UI.

**Solución**: Agregados métodos `setEffectMode()` y `setEffectIntensity()` que:
- Hacen commit al historial antes de cambiar
- Actualizan el controller
- Notifican a los listeners

## Checks de Validación

### Caso 1: Selfie (1 rostro) → Auto-detect → Aplicar herramienta → Undo → Export
- [ ] **Import**: Imagen se carga correctamente
- [ ] **Preview**: Imagen se muestra en preview
- [ ] **Auto-detect**: Se detecta 1 ROI automáticamente
- [ ] **Herramienta**: Pixelar/blur se aplica correctamente
- [ ] **Undo**: Se puede deshacer la operación (>=10 niveles)
- [ ] **Export**: Imagen exportada es válida y tiene el efecto aplicado

### Caso 2: Foto con 2 personas → Auto-detect (2 ROIs) → Seleccionar 1 ROI → Aplicar → Undo → Export
- [ ] **Import**: Imagen se carga correctamente
- [ ] **Preview**: Imagen se muestra en preview
- [ ] **Auto-detect**: Se detectan 2 ROIs automáticamente
- [ ] **Selección**: Se puede seleccionar 1 ROI específica
- [ ] **Herramienta**: Pixelar/blur se aplica SOLO a la ROI seleccionada
- [ ] **Undo**: Se puede deshacer la operación
- [ ] **Export**: Imagen exportada tiene efecto solo en la ROI seleccionada

### Caso 3: Sin auto-detect → Crear ROI manual → Aplicar → Undo → Export
- [ ] **Import**: Imagen se carga correctamente
- [ ] **Preview**: Imagen se muestra en preview
- [ ] **Auto-detect**: Desactivado (no detecta rostros)
- [ ] **ROI manual**: Se puede crear ROI manualmente
- [ ] **Herramienta**: Pixelar/blur se aplica a la ROI manual
- [ ] **Undo**: Se puede deshacer la operación (>=10 niveles)
- [ ] **Export**: Imagen exportada es válida y tiene el efecto aplicado

### Validaciones Generales
- [ ] **Undo siempre visible**: El botón de undo está siempre visible (deshabilitado si no hay historial)
- [ ] **Undo >=10 niveles**: Se puede deshacer al menos 10 operaciones
- [ ] **ROI activa**: Si hay selección activa, herramientas aplican SOLO sobre la selección
- [ ] **Export válido**: El archivo exportado es una imagen válida en el formato correcto

## Estado Actual

**Fecha**: [Pendiente de ejecución en dispositivo físico]

**Build**: `flutter run --release` ejecutándose en background

**Fixes aplicados**: ✅ 4 fixes completados
- Conexión de herramientas
- Export solo a ROI activa
- Optimización historial
- Métodos ViewModel

**Pendiente**: Validación manual en dispositivo Android físico

## Notas

1. **Preview de efectos**: Los efectos (pixelate/blur) NO se muestran en el preview en tiempo real por rendimiento. Solo se aplican en el export.

2. **Intensidad por defecto**: Las herramientas usan intensidad 5 por defecto. En el futuro se puede agregar un slider para ajustar.

3. **Undo**: El sistema soporta mínimo 10 niveles de undo según requerimiento del PRD.

4. **ROI activa**: La regla "si hay selección activa, aplicar solo a esa selección" está implementada tanto en ajustes como en herramientas.
