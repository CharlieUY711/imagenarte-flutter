# Transform-Circle Module

Módulo especializado para transformación de formas circulares.

## Restricciones

- **Solo círculos**: Este módulo está diseñado exclusivamente para `Shape` con `kind: 'circle'`
- **Solo MOVE**: Los círculos solo soportan traslación (MOVE), no rotación
- **Sin zonas ROTATE**: La detección de zonas siempre retorna `MOVE` o `NONE` para círculos

## Uso

```typescript
import { useTransformController, TransformOverlay } from '@/modules/transform-circle';
import type { CircleShape } from '@/modules/transform-circle';

const shape: CircleShape = {
  kind: 'circle',
  center: { x: 100, y: 100 },
  radius: 50,
};

const controller = useTransformController({
  initialShape: shape,
});
```

## API

La API es idéntica al módulo `transform` original, pero con la garantía de que solo se usará con círculos. El core compartido maneja automáticamente la restricción de modo MOVE para círculos.
