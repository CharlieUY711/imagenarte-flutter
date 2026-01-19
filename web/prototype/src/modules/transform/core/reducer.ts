/**
 * Reducer puro estilo state machine (sin side-effects)
 * Maneja eventos de transformación de forma determinista
 */

import type {
  TransformState,
  TransformEvent,
  TransformConfig,
  TransformMode,
} from './types';
import { getZone } from './zones';
import { quadCenter, rotateQuad, translateQuad } from './geometry';

/**
 * Reducer principal que procesa eventos y devuelve nuevo estado
 */
export function transformReducer(
  state: TransformState,
  event: TransformEvent,
  config: TransformConfig
): TransformState {
  switch (event.type) {
    case 'POINTER_MOVE': {
      const p = event.p;

      // Si no está arrastrando, solo actualizar hoverZone
      if (!state.isDragging) {
        return {
          ...state,
          hoverZone: getZone(p, state.shape, config),
        };
      }

      // Si está arrastrando, aplicar transformación
      if (state.dragMode === 'MOVE') {
        // MOVE: aplicar traslación usando delta desde startPointer
        if (!state.startPointer || !state.startShape) return state;

        const dx = p.x - state.startPointer.x;
        const dy = p.y - state.startPointer.y;

        if (state.startShape.kind === 'circle') {
          return {
            ...state,
            shape: {
              kind: 'circle',
              center: {
                x: state.startShape.center.x + dx,
                y: state.startShape.center.y + dy,
              },
              radius: state.startShape.radius,
            },
          };
        } else {
          // Quad: trasladar todos los puntos desde startShape
          return {
            ...state,
            shape: {
              kind: 'quad',
              points: translateQuad(state.startShape.points, dx, dy),
            },
          };
        }
      } else if (state.dragMode === 'ROTATE') {
        // ROTATE: solo para quads
        if (state.shape.kind !== 'quad') return state;
        if (!state.startCenter || state.startAngle0 === null || !state.startShape || state.startShape.kind !== 'quad') return state;

        // Calcular ángulo actual desde el centro hasta el puntero
        const dx = p.x - state.startCenter.x;
        const dy = p.y - state.startCenter.y;
        const currentAngle = Math.atan2(dy, dx);

        // Delta de ángulo desde el inicio
        const deltaAngle = currentAngle - state.startAngle0;

        // Aplicar rotación al shape inicial
        return {
          ...state,
          shape: {
            kind: 'quad',
            points: rotateQuad(state.startShape.points, state.startCenter, deltaAngle),
          },
        };
      }

      return state;
    }

    case 'POINTER_DOWN': {
      const p = event.p;
      const zone = getZone(p, state.shape, config);

      // Si la zona es NONE, no iniciar drag
      if (zone === 'NONE') {
        return state;
      }

      // Determinar dragMode según la forma y zona
      let dragMode: TransformMode = 'MOVE';

      if (state.shape.kind === 'circle') {
        // Círculos siempre MOVE
        dragMode = 'MOVE';
      } else if (state.shape.kind === 'quad') {
        // Quads: ROTATE si zona es ROTATE, MOVE si zona es MOVE
        dragMode = zone === 'ROTATE' ? 'ROTATE' : 'MOVE';
      }

      // Calcular snapshot para drag
      const startCenter =
        state.shape.kind === 'quad'
          ? quadCenter(state.shape.points)
          : state.shape.center;

      let startAngle0: number | null = null;
      if (dragMode === 'ROTATE' && state.shape.kind === 'quad') {
        const dx = p.x - startCenter.x;
        const dy = p.y - startCenter.y;
        startAngle0 = Math.atan2(dy, dx);
      }

      return {
        ...state,
        isDragging: true,
        dragMode,
        hoverZone: zone,
        startPointer: p,
        startShape: JSON.parse(JSON.stringify(state.shape)), // Deep clone
        startCenter,
        startAngle0,
      };
    }

    case 'POINTER_UP': {
      // Finalizar drag
      return {
        ...state,
        isDragging: false,
        hoverZone: 'NONE',
        startPointer: null,
        startShape: null,
        startCenter: null,
        startAngle0: null,
      };
    }

    case 'SET_SHAPE': {
      // Actualizar la forma (útil para reset o cambios externos)
      return {
        ...state,
        shape: event.shape,
        // Si está arrastrando, mantener el estado de drag
        // Si no, resetear hoverZone
        hoverZone: state.isDragging ? state.hoverZone : 'NONE',
      };
    }

    default:
      return state;
  }
}
