# Guía de Integración - Herramienta PIXELADO

## Integración en Proyecto Existente

Si ya tienes un proyecto React/Vite con la estructura del editor, sigue estos pasos:

### 1. Copiar archivos

```bash
# Componentes
cp src/components/PixelateOverlayPanel.tsx [tu-proyecto]/src/components/
cp src/components/EditorOverlayPanel.tsx [tu-proyecto]/src/components/
cp src/components/OverlayDialRow.tsx [tu-proyecto]/src/components/
cp src/components/EditorCanvas.tsx [tu-proyecto]/src/components/

# Utilidades
cp src/utils/pixelate.ts [tu-proyecto]/src/utils/

# Hooks (si no existe)
cp src/hooks/useEditorState.ts [tu-proyecto]/src/hooks/
cp src/context/EditorContext.tsx [tu-proyecto]/src/context/
```

### 2. Integrar en el router de overlays

Si tienes un componente similar a `EditorOverlayRouter`, agrega:

```tsx
import { PixelateOverlayPanel } from './components/PixelateOverlayPanel';

// En tu switch de contextos
case 'action_pixelate':
  return <PixelateOverlayPanel />;
```

### 3. Integrar en el canvas principal

Asegúrate de que tu canvas principal use el hook `useEditor` y aplique el pixelado:

```tsx
import { useEditor } from './context/EditorContext';
import { applyPixelate, createROIMask } from './utils/pixelate';

// En tu componente de canvas
const { activeContext, selectionGeometry, pixelateIntensity, hasValidSelection } = useEditor();

// En la función de renderizado
if (activeContext === 'action_pixelate' && hasValidSelection && selectionGeometry) {
  // Aplicar pixelado (ver EditorCanvas.tsx para ejemplo completo)
}
```

### 4. Agregar botón de herramienta

En tu toolbar o action list, agrega el botón para activar pixelado:

```tsx
<button onClick={() => setActiveTool('pixelate')}>
  Pixelado
</button>
```

### 5. Verificar estado global

Asegúrate de que tu estado global incluya:
- `pixelateIntensity` (0-100)
- `setPixelateIntensity`
- `activeContext` con valor `'action_pixelate'`
- `selectionGeometry` (ROI activo)
- `hasValidSelection` (boolean)

## Validación

1. ✅ Pixelado visible solo dentro del ROI
2. ✅ Intensidad responde en tiempo real
3. ✅ Undo consistente (mínimo 10 niveles)
4. ✅ Cambio de herramienta limpia estado
5. ✅ Sin ROI activo → herramienta deshabilitada

## Notas

- El pixelado se aplica en tiempo real en el preview
- La imagen base no se modifica hasta exportar
- Al reentrar a la herramienta, la intensidad se resetea a 50.0
