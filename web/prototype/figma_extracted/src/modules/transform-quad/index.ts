/**
 * Módulo Transform-Quad - API Pública para Cuadriláteros
 * 
 * Este módulo expone una API restringida exclusivamente para formas cuadriláteras.
 * Soporta modo MOVE (traslación) y ROTATE (rotación) con detección de zonas.
 * 
 * Uso:
 * - Para cuadriláteros: importar desde '@/modules/transform-quad'
 * - Reutiliza el core compartido pero restringe a Shape kind='quad'
 */

// Re-export tipos restringidos
export type { Point } from '../transform/core/types';

// Tipo restringido: solo cuadriláteros
export type QuadShape = {
  kind: 'quad';
  points: [
    { x: number; y: number },
    { x: number; y: number },
    { x: number; y: number },
    { x: number; y: number }
  ];
};

// Re-export engine (funciona con cualquier Shape, pero se usa solo con quad)
export {
  createInitialState,
  dispatch,
  deriveUI,
} from '../transform/core/engine';

export type {
  TransformState,
  TransformEvent,
  TransformConfig,
  TransformMode,
  TransformZone,
} from '../transform/core/types';

// Re-export adapter React
export { useTransformController } from '../transform/adapters/react/useTransformController';
export type {
  UseTransformControllerOptions,
  UseTransformControllerReturn,
} from '../transform/adapters/react/useTransformController';

export { TransformOverlay } from '../transform/adapters/react/TransformOverlay';
export type { TransformOverlayProps } from '../transform/adapters/react/TransformOverlay';

export { TransformCenterIcon } from '../transform/adapters/react/TransformCenterIcon';
export type { TransformCenterIconProps } from '../transform/adapters/react/TransformCenterIcon';
