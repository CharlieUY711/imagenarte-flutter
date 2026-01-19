/**
 * Módulo Transform-Circle - API Pública para Círculos con MOVE + RESIZE
 * 
 * Usa el sistema unificado de transformación.
 * Soporta MOVE (traslación) y RESIZE (cambio de radio/dimensión).
 */

// Re-export tipos del sistema unificado
export type { CircleInput } from '../../app/transform/useUnifiedTransform';
export type { TransformConstraints } from '../../app/transform/unifiedTransform';

// Re-export hook principal
export { useUnifiedTransform as useCircleTransformController } from '../../app/transform/useUnifiedTransform';

// Export componente overlay
export { CircleTransformOverlay } from './CircleTransformOverlay';
export type { CircleTransformOverlayProps } from './CircleTransformOverlay';

// Tipo para el retorno del controller
export interface UseCircleTransformControllerReturn {
  bind: {
    onPointerDown: (e: React.PointerEvent, element?: HTMLElement) => void;
  };
  activeMode: 'move' | 'resize-proportional' | 'resize-axis' | null;
  isTransforming: boolean;
  calculateHoverMode: (localX: number, localY: number) => 'move' | 'resize-proportional' | 'resize-axis' | null;
}
