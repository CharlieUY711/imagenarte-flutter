/**
 * Hook React que conecta eventos DOM con el core Transform
 * 
 * Responsabilidades:
 * - Mantener state del core
 * - Convertir eventos DOM pointer a TransformEvent
 * - Normalizar coordenadas del puntero a "local space"
 * - Exponer API simple para componentes
 */

import { useReducer, useCallback, useRef, useEffect } from 'react';
import type { Shape, TransformConfig, TransformEvent } from '../../core/types';
import {
  createInitialState,
  dispatch,
  deriveUI,
  type TransformState,
} from '../../core/engine';
import { getLocalPoint } from '../../../../utils/pointer';

export interface UseTransformControllerOptions {
  initialShape: Shape;
  config?: Partial<TransformConfig>;
  containerRef?: React.RefObject<HTMLElement>;
}

export interface UseTransformControllerReturn {
  state: TransformState;
  ui: ReturnType<typeof deriveUI>;
  handlers: {
    onPointerMove: (e: React.PointerEvent) => void;
    onPointerDown: (e: React.PointerEvent) => void;
    onPointerUp: (e: React.PointerEvent) => void;
    onPointerCancel: (e: React.PointerEvent) => void;
  };
  setShape: (shape: Shape) => void;
}

const DEFAULT_CONFIG: TransformConfig = {
  quadInnerInsetRatio: 0.10,
};

/**
 * Hook principal para controlar transformaciones
 */
export function useTransformController({
  initialShape,
  config = {},
  containerRef,
}: UseTransformControllerOptions): UseTransformControllerReturn {
  const fullConfig: TransformConfig = {
    ...DEFAULT_CONFIG,
    ...config,
  };

  const [state, dispatchState] = useReducer(
    (state: TransformState, event: TransformEvent) =>
      dispatch(state, event, fullConfig),
    createInitialState(initialShape, fullConfig)
  );

  // Ref para mantener el elemento contenedor
  const containerElementRef = useRef<HTMLElement | null>(null);

  /**
   * Obtiene el elemento contenedor (prioridad: containerRef > ref interno)
   */
  const getContainer = useCallback((): HTMLElement | null => {
    if (containerRef?.current) {
      return containerRef.current;
    }
    if (containerElementRef.current) {
      return containerElementRef.current;
    }
    return null;
  }, [containerRef]);

  /**
   * Normaliza coordenadas del puntero a "local space" del contenedor
   */
  const getLocalPointFromEvent = useCallback(
    (e: React.PointerEvent): { x: number; y: number } | null => {
      const container = getContainer();
      if (!container) {
        // Fallback: usar coordenadas del viewport si no hay contenedor
        return { x: e.clientX, y: e.clientY };
      }
      return getLocalPoint(e, container);
    },
    [getContainer]
  );

  /**
   * Handler de pointer move
   */
  const handlePointerMove = useCallback(
    (e: React.PointerEvent) => {
      const localPoint = getLocalPointFromEvent(e);
      if (!localPoint) return;

      dispatchState({ type: 'POINTER_MOVE', p: localPoint });
    },
    [getLocalPointFromEvent]
  );

  /**
   * Handler de pointer down
   */
  const handlePointerDown = useCallback(
    (e: React.PointerEvent) => {
      const localPoint = getLocalPointFromEvent(e);
      if (!localPoint) return;

      dispatchState({ type: 'POINTER_DOWN', p: localPoint });

      // Pointer capture para seguir el movimiento fuera del elemento
      try {
        e.currentTarget.setPointerCapture(e.pointerId);
      } catch (err) {
        // Ignorar errores de pointer capture
      }
    },
    [getLocalPointFromEvent]
  );

  /**
   * Handler de pointer up
   */
  const handlePointerUp = useCallback((e: React.PointerEvent) => {
    dispatchState({ type: 'POINTER_UP' });

    // Release pointer capture
    try {
      e.currentTarget.releasePointerCapture(e.pointerId);
    } catch (err) {
      // Ignorar errores
    }
  }, []);

  /**
   * Handler de pointer cancel
   */
  const handlePointerCancel = useCallback((e: React.PointerEvent) => {
    dispatchState({ type: 'POINTER_UP' });

    try {
      e.currentTarget.releasePointerCapture(e.pointerId);
    } catch (err) {
      // Ignorar errores
    }
  }, []);

  /**
   * Actualizar la forma (útil para reset o cambios externos)
   */
  const setShape = useCallback(
    (shape: Shape) => {
      dispatchState({ type: 'SET_SHAPE', shape });
    },
    []
  );

  // Manejar eventos globales cuando se está arrastrando
  useEffect(() => {
    if (!state.isDragging) return;

    const handleGlobalMove = (e: PointerEvent) => {
      const container = getContainer();
      if (!container) {
        dispatchState({ type: 'POINTER_MOVE', p: { x: e.clientX, y: e.clientY } });
        return;
      }
      const localPoint = getLocalPoint(e, container);
      dispatchState({ type: 'POINTER_MOVE', p: localPoint });
    };

    const handleGlobalUp = (e: PointerEvent) => {
      dispatchState({ type: 'POINTER_UP' });
    };

    const handleGlobalCancel = (e: PointerEvent) => {
      dispatchState({ type: 'POINTER_UP' });
    };

    window.addEventListener('pointermove', handleGlobalMove);
    window.addEventListener('pointerup', handleGlobalUp);
    window.addEventListener('pointercancel', handleGlobalCancel);

    return () => {
      window.removeEventListener('pointermove', handleGlobalMove);
      window.removeEventListener('pointerup', handleGlobalUp);
      window.removeEventListener('pointercancel', handleGlobalCancel);
    };
  }, [state.isDragging, getContainer]);

  // Derivar UI desde el estado
  const ui = deriveUI(state);

  return {
    state,
    ui,
    handlers: {
      onPointerMove: handlePointerMove,
      onPointerDown: handlePointerDown,
      onPointerUp: handlePointerUp,
      onPointerCancel: handlePointerCancel,
    },
    setShape,
  };
}
