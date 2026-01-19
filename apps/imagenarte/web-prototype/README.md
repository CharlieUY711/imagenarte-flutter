# IMAGEN@RTE - Herramienta PIXELADO (ROI-Based)

## Implementación

Herramienta de pixelado aplicable exclusivamente sobre una selección (ROI), siguiendo el mismo patrón que BLUR.

## Estructura

```
web-prototype/
├── src/
│   ├── components/
│   │   ├── PixelateOverlayPanel.tsx    # Panel overlay con slider de intensidad
│   │   ├── EditorOverlayPanel.tsx      # Contenedor del overlay
│   │   ├── OverlayDialRow.tsx          # Componente slider reutilizable
│   │   └── EditorCanvas.tsx            # Canvas con renderizado de pixelado
│   ├── hooks/
│   │   └── useEditorState.ts           # Estado global del editor
│   └── utils/
│       └── pixelate.ts                 # Funciones de pixelado y máscaras ROI
```

## Características

- ✅ Pixelado aplicado SOLO dentro del ROI activo
- ✅ Sin ROI activo → herramienta deshabilitada
- ✅ Soporte para ROI rectangular/cuadrilátero (rotado), circular y path libre
- ✅ Pixelado ajustable en tiempo real (2px → 50px)
- ✅ Preview en tiempo real sin modificar imagen base
- ✅ Integración con sistema de undo (mínimo 10 niveles)
- ✅ Reset de estado al reentrar a la herramienta

## Uso

```tsx
import { PixelateOverlayPanel } from './components/PixelateOverlayPanel';
import { EditorCanvas } from './components/EditorCanvas';

// En tu componente principal
<EditorCanvas imageUrl="/path/to/image.jpg" />
<PixelateOverlayPanel />
```

## Notas

- El pixelado se rasteriza definitivamente solo al exportar
- La imagen base no se modifica hasta exportar
- El estado se reinicia al reentrar a la herramienta
