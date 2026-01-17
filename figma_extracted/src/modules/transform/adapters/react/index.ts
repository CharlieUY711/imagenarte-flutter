/**
 * Adapter React para el módulo Transform
 * 
 * Exporta componentes y hooks que conectan el core headless con React
 */

export { useTransformController } from './useTransformController';
export type {
  UseTransformControllerOptions,
  UseTransformControllerReturn,
} from './useTransformController';

export { TransformOverlay } from './TransformOverlay';
export type { TransformOverlayProps } from './TransformOverlay';

export { TransformCenterIcon } from './TransformCenterIcon';
export type { TransformCenterIconProps } from './TransformCenterIcon';
