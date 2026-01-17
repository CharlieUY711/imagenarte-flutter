/**
 * Engine principal que expone la API pública del core
 */

import type {
  TransformState,
  TransformEvent,
  TransformConfig,
  Shape,
} from './types';
import { transformReducer } from './reducer';
import { quadCenter } from './geometry';

/**
 * Crea el estado inicial
 */
export function createInitialState(
  shape: Shape,
  config: TransformConfig
): TransformState {
  return {
    shape,
    hoverZone: 'NONE',
    isDragging: false,
    dragMode: 'MOVE',
    startPointer: null,
    startShape: null,
    startCenter: null,
    startAngle0: null,
  };
}

/**
 * Procesa un evento y devuelve el nuevo estado
 */
export function dispatch(
  state: TransformState,
  event: TransformEvent,
  config: TransformConfig
): TransformState {
  return transformReducer(state, event, config);
}

/**
 * Deriva información de UI desde el estado
 */
export function deriveUI(state: TransformState): {
  center: { x: number; y: number };
  showIcon: boolean;
  iconMode: 'MOVE' | 'ROTATE';
  hoverZone: 'MOVE' | 'ROTATE' | 'NONE';
} {
  const center =
    state.shape.kind === 'quad'
      ? quadCenter(state.shape.points)
      : state.shape.center;

  const showIcon = state.hoverZone !== 'NONE' && !state.isDragging;
  const iconMode: 'MOVE' | 'ROTATE' =
    state.hoverZone === 'ROTATE' ? 'ROTATE' : 'MOVE';

  return {
    center,
    showIcon,
    iconMode,
    hoverZone: state.hoverZone,
  };
}
