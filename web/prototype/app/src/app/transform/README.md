# Análisis: `src/app/transform/`

## Resumen

Este directorio contiene código que **DUPLICA** funcionalidad del módulo oficial Transform (`src/modules/transform/`), pero con una implementación diferente y un modelo de datos distinto.

## Archivos Existentes

1. **`transformEngine.ts`** (557 líneas)
   - Motor de transformaciones puro (sin React, sin DOM)
   - Modelo de datos: `RectLike` (cx, cy, w, h, rotation) y `CircleLike` (cx, cy, r)
   - Funciones: `applyTransform`, `applyTransformToRect`, `applyTransformToCircle`
   - Helpers: `clamp`, `normalizeAngle`, `applyRotationSnap`, `applyBounds`, conversiones
   - Soporta handles: `move`, `rotate`, `n/s/e/w`, `ne/nw/se/sw`, `radius`
   - Incluye restricciones: `bounds`, `minSize`, `maxSize`, `lockAspect`, `snapRotation`

2. **`useTransformGestures.ts`** (502 líneas)
   - Hook React para gestos de transformación
   - Usa `transformEngine.ts` internamente
   - Modelo de entrada: `RectInput` (x, y, width, height, rotation) y `CircleInput` (x, y, width, height)
   - Convierte entre formatos de entrada y formato interno (`RectLike`/`CircleLike`)
   - Maneja detección de handles, pointer events, constraints dinámicas

## Quién los Importa

**`src/app/screens/TransformPlayground.tsx`** (1008 líneas):
- Importa `useTransformGestures` y `transformEngine` desde `../transform/`
- Usa estos hooks y funciones para implementar un playground de transformaciones
- Implementa lógica de UI compleja (hover zones, iconos, ejes cartesianos, etc.)

## ¿Duplica Lógica? SÍ

### Diferencias con el Módulo Oficial

| Aspecto | `src/app/transform/` | `src/modules/transform/` |
|---------|---------------------|--------------------------|
| **Modelo de datos** | `RectLike` (cx, cy, w, h, rotation)<br>`CircleLike` (cx, cy, r) | `Shape` (quad: points[]<br>circle: center + radius) |
| **Formato de entrada** | `RectInput` (x, y, width, height, rotation)<br>`CircleInput` (x, y, width, height) | `Shape` directo |
| **Handles soportados** | `move`, `rotate`, `n/s/e/w`, `ne/nw/se/sw`, `radius` | Solo `MOVE` y `ROTATE` (zoning) |
| **Resize** | ✅ Soporta resize completo (bordes y esquinas) | ❌ No soporta resize |
| **Rotación** | ✅ Soporta rotación con snap | ✅ Soporta rotación |
| **Constraints** | ✅ Bounds, minSize, maxSize, lockAspect, snapRotation | ⚠️ Solo configuración básica (quadInnerInsetRatio) |
| **Arquitectura** | Motor puro + Hook React | Core headless (reducer) + Adapter React |

### Funcionalidad Duplicada

1. **Motor de transformaciones**: Ambos implementan lógica para mover y rotar formas
2. **Gestión de eventos pointer**: Ambos manejan pointer events (move, down, up)
3. **Normalización de coordenadas**: Ambos convierten coordenadas del viewport a espacio local
4. **Cálculos geométricos**: Ambos calculan centros, deltas, ángulos, etc.

### Funcionalidad Única de `app/transform/`

- **Resize completo**: Soporta redimensionamiento por bordes y esquinas (no disponible en el módulo oficial)
- **Constraints avanzadas**: Bounds, minSize, maxSize, lockAspect, snapRotation
- **Handles múltiples**: 9 handles para rectángulos (4 esquinas + 4 bordes + centro), 2 para círculos (centro + borde)

## Recomendación

### Opción A: Mantener (si se necesita resize)
- **Mantener** `src/app/transform/` si la funcionalidad de resize es requerida
- **Migrar** gradualmente el módulo oficial para soportar resize
- **Documentar** claramente que hay dos sistemas: uno para MOVE/ROTATE (módulo oficial) y otro para MOVE/ROTATE/RESIZE (app/transform)

### Opción B: Deprecar (recomendado si no se necesita resize)
- **Deprecar** `src/app/transform/` marcándolo como legacy
- **Migrar** `TransformPlayground.tsx` para usar el módulo oficial
- **Eliminar** después de confirmar que no se necesita la funcionalidad de resize

### Opción C: Unificar (largo plazo)
- **Extender** el módulo oficial para soportar resize y constraints avanzadas
- **Migrar** toda la funcionalidad de `app/transform/` al módulo oficial
- **Eliminar** `app/transform/` una vez completada la migración

## Estado Actual

- ✅ **Funcional**: El código en `app/transform/` funciona correctamente
- ⚠️ **Duplicado**: Hay dos sistemas de transformación en el codebase
- ⚠️ **Inconsistente**: Diferentes modelos de datos y APIs
- ⚠️ **Mantenimiento**: Dos lugares donde actualizar lógica de transformación

## Notas Adicionales

- El módulo oficial (`src/modules/transform/`) es más nuevo y sigue mejores prácticas arquitectónicas (headless core + adapter)
- El código en `app/transform/` es más completo funcionalmente (soporta resize)
- Existe un playground oficial en `src/playground/TransformPlayground/` que usa el módulo oficial
- Existe otro playground en `src/app/screens/TransformPlayground.tsx` que usa `app/transform/`

## Acción Requerida

**DECISIÓN PENDIENTE**: Determinar si se necesita la funcionalidad de resize. Si no, deprecar `app/transform/`. Si sí, documentar claramente la diferencia y considerar extender el módulo oficial.

