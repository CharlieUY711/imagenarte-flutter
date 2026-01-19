# Módulo Transform

Módulo profesional para transformaciones de formas (MOVE/ROTATE) con arquitectura headless y adapter React.

## Contrato Público (API Estable)

Este módulo expone una API pública estable que debe ser respetada. Los cambios en esta API requieren revisión.

### Exports Principales

**Core (headless):**
- `@/modules/transform/core` → `createInitialState`, `dispatch`, `deriveUI`, tipos `Shape`, `TransformState`, `TransformConfig`, `TransformEvent`

**Adapter React:**
- `@/modules/transform/adapters/react` → `useTransformController`, `TransformOverlay`, `TransformCenterIcon`, tipos relacionados

**Re-export centralizado (recomendado):**
- `@/modules/transform` → Re-exporta todo lo anterior de forma organizada

## Estructura

```
src/modules/transform/
  core/                    # Core headless (sin React, sin DOM)
    types.ts              # Tipos puros
    geometry.ts           # Utilidades geométricas
    zones.ts              # Detección de zonas (MOVE/ROTATE/NONE)
    reducer.ts            # Reducer puro estilo state machine
    engine.ts             # API pública del core
    index.ts              # Exportaciones
  adapters/
    react/                # Adapter React
      useTransformController.ts  # Hook principal
      TransformOverlay.tsx        # Componente de overlay
      TransformCenterIcon.tsx    # Icono central
      index.ts                   # Exportaciones
  README.md
```

## Core Headless

El core es completamente independiente de React y DOM. Puede usarse en cualquier entorno gráfico (Canvas, Pixi.js, Konva, etc.).

### API Principal

```typescript
import { createInitialState, dispatch, deriveUI, type Shape, type TransformConfig } from '@/modules/transform/core';

// Crear estado inicial
const config: TransformConfig = { quadInnerInsetRatio: 0.10 };
const shape: Shape = { 
  kind: 'quad', 
  points: [
    { x: 100, y: 100 },
    { x: 300, y: 100 },
    { x: 300, y: 200 },
    { x: 100, y: 200 }
  ]
};
let state = createInitialState(shape, config);

// Procesar eventos
state = dispatch(state, { type: 'POINTER_MOVE', p: { x: 150, y: 150 } }, config);
state = dispatch(state, { type: 'POINTER_DOWN', p: { x: 150, y: 150 } }, config);
state = dispatch(state, { type: 'POINTER_UP' }, config);

// Derivar información de UI
const ui = deriveUI(state);
// ui = { center, showIcon, iconMode, hoverZone }
```

### Tipos

- **Shape**: `{ kind: 'quad', points: [Point, Point, Point, Point] }` | `{ kind: 'circle', center: Point, radius: number }`
- **TransformZone**: `'MOVE' | 'ROTATE' | 'NONE'`
- **TransformMode**: `'MOVE' | 'ROTATE'`
- **TransformEvent**: `POINTER_MOVE | POINTER_DOWN | POINTER_UP | SET_SHAPE`

### Reglas de Comportamiento

1. **HOVER**: Si `!isDragging` => `hoverZone = getZone(p, shape)`
2. **DOWN**: 
   - Si `zone === 'NONE'` => no iniciar drag
   - Si `shape.kind === 'circle'` => `dragMode = 'MOVE'`
   - Si `shape.kind === 'quad' && zone === 'ROTATE'` => `dragMode = 'ROTATE'`
   - Else => `dragMode = 'MOVE'`
   - Lock-in: `isDragging = true`
   - Snapshot: `startPointer`, `startShape`, `startCenter`, `startAngle0`
3. **MOVE while dragging**:
   - Si `dragMode === 'MOVE'` => aplicar traslación usando delta
   - Si `dragMode === 'ROTATE'` => aplicar rotación usando deltaAngle
4. **UP**: Resetear estado de drag

## Adapter React

El adapter React conecta eventos DOM con el core.

### Hook: useTransformController

```typescript
import { useTransformController } from '@/modules/transform/adapters/react';

const transform = useTransformController({
  initialShape: shape,
  config: { quadInnerInsetRatio: 0.10 },
  containerRef: containerRef,
});

// API expuesta:
// - transform.state: TransformState
// - transform.ui: { center, showIcon, iconMode, hoverZone }
// - transform.handlers: { onPointerMove, onPointerDown, onPointerUp, onPointerCancel }
// - transform.setShape(shape): actualizar forma
```

### Componente: TransformOverlay

```typescript
import { TransformOverlay } from '@/modules/transform/adapters/react';

<TransformOverlay
  shape={transform.state.shape}
  showIcon={transform.ui.showIcon}
  iconMode={transform.ui.iconMode}
  iconCenter={transform.ui.center}
  showDebug={false}
/>
```

## Integración en Otro Entorno (ej: Canvas)

El core puede usarse sin React. Ejemplo mínimo:

```typescript
import { createInitialState, dispatch, deriveUI, type Shape, type TransformConfig } from '@/modules/transform/core';

// Setup
const config: TransformConfig = { quadInnerInsetRatio: 0.10 };
let state = createInitialState(initialShape, config);

// Eventos del canvas
canvas.addEventListener('pointermove', (e) => {
  const rect = canvas.getBoundingClientRect();
  const p = { x: e.clientX - rect.left, y: e.clientY - rect.top };
  state = dispatch(state, { type: 'POINTER_MOVE', p }, config);
  render(); // Tu función de renderizado
});

canvas.addEventListener('pointerdown', (e) => {
  const rect = canvas.getBoundingClientRect();
  const p = { x: e.clientX - rect.left, y: e.clientY - rect.top };
  state = dispatch(state, { type: 'POINTER_DOWN', p }, config);
  render();
});

canvas.addEventListener('pointerup', () => {
  state = dispatch(state, { type: 'POINTER_UP' }, config);
  render();
});

// Renderizado
function render() {
  const ctx = canvas.getContext('2d');
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  
  // Dibujar forma
  if (state.shape.kind === 'quad') {
    ctx.beginPath();
    ctx.moveTo(state.shape.points[0].x, state.shape.points[0].y);
    state.shape.points.slice(1).forEach(p => ctx.lineTo(p.x, p.y));
    ctx.closePath();
    ctx.stroke();
  } else {
    ctx.beginPath();
    ctx.arc(state.shape.center.x, state.shape.center.y, state.shape.radius, 0, Math.PI * 2);
    ctx.stroke();
  }
  
  // Dibujar icono si es necesario
  const ui = deriveUI(state);
  if (ui.showIcon) {
    // Dibujar icono en ui.center
  }
}
```

## Playground

El Playground (`src/playground/TransformPlayground/`) es un ejemplo de uso del módulo:

- Toggle entre QUAD y CIRCLE
- Reset de formas
- Debug mode (muestra inner quad para quads)
- Badge de debug con información del estado

## Características

- ✅ Core headless (sin dependencias de React/DOM)
- ✅ Adapter React con hook y componentes
- ✅ Zoning MOVE/ROTATE para quads (inner 10% = ROTATE, anillo = MOVE)
- ✅ Círculos siempre MOVE
- ✅ Drag lock-in (una vez iniciado, sigue hasta UP)
- ✅ Icono central que muestra MOVE/ROTATE según hoverZone
- ✅ Pointer-events: none en overlays visuales
- ✅ Compatible con cualquier entorno gráfico

## Reglas de Arquitectura

### Core Headless
- **NO** debe importar React, DOM, CSS, ni ninguna dependencia de UI
- **SÍ** debe ser puro, determinista y testeable
- **SÍ** debe exponer tipos y funciones que puedan usarse en cualquier entorno (Canvas, WebGL, etc.)

### Adapter React
- **SÍ** puede importar React y dependencias de UI
- **NO** debe contener lógica geométrica pesada (solo "glue" entre DOM y core)
- **SÍ** debe delegar toda la lógica de transformación al core

### Host (Playground/App)
- **SÍ** puede usar el adapter React directamente
- **NO** debe duplicar lógica del core o adapter
- **SÍ** debe usar los exports públicos del módulo (no imports internos)

## Notas

- El core NO importa React ni depende de DOM
- El adapter React NO contiene lógica geométrica pesada (solo glue)
- Las transformaciones son deterministas y testeables
- El reducer es puro (sin side-effects)
- **IMPORTANTE**: Solo hay UNA vía oficial de consumo desde la app: usar los exports de `@/modules/transform` o sus sub-módulos públicos

