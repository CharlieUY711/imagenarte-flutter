# Transform-Quad Module

Módulo especializado para transformación de formas cuadriláteras.

## Características

- **Solo cuadriláteros**: Este módulo está diseñado exclusivamente para `Shape` con `kind: 'quad'`
- **MOVE y ROTATE**: Los cuadriláteros soportan traslación (MOVE) y rotación (ROTATE)
- **Detección de zonas**: El sistema detecta automáticamente si el puntero está en la zona de rotación (centro) o de traslación (anillo exterior)

## Uso

```typescript
import { useTransformController, TransformOverlay } from '@/modules/transform-quad';
import type { QuadShape } from '@/modules/transform-quad';

const shape: QuadShape = {
  kind: 'quad',
  points: [
    { x: 0, y: 0 },
    { x: 100, y: 0 },
    { x: 100, y: 100 },
    { x: 0, y: 100 },
  ],
};

const controller = useTransformController({
  initialShape: shape,
});
```

## Zonas de Transformación

- **ROTATE**: Zona interior (10% hacia el centro del quad) - permite rotar
- **MOVE**: Zona exterior (anillo entre el borde y la zona interior) - permite trasladar
- **NONE**: Fuera del cuadrilátero

## API

La API es idéntica al módulo `transform` original, pero con la garantía de que solo se usará con cuadriláteros. El core compartido maneja automáticamente la detección de zonas y los modos MOVE/ROTATE.
