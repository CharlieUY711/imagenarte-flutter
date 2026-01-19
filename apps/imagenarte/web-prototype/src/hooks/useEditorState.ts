import { useState, useCallback, useRef } from 'react';

export type EditorContext =
  | 'none'
  | 'selectionRatios'
  | 'freeSelection'
  | 'scissors'
  | 'collage'
  | 'colorPresets'
  | 'classicAdjustments'
  | 'action_blur'
  | 'action_pixelate'
  | 'action_watermark'
  | 'action_metadata'
  | 'zoom';

export type EditorTool =
  | 'none'
  | 'home'
  | 'geometricSelection'
  | 'freeSelection'
  | 'scissors'
  | 'collage'
  | 'color'
  | 'classicAdjustments'
  | 'undo'
  | 'save'
  | 'blur'
  | 'pixelate'
  | 'watermark'
  | 'metadata';

export interface ROIGeometry {
  type: 'rect' | 'circle' | 'path';
  x?: number;
  y?: number;
  width?: number;
  height?: number;
  centerX?: number;
  centerY?: number;
  radius?: number;
  rotation?: number;
  path?: Array<{ x: number; y: number }>;
}

interface EditorSnapshot {
  activeTool: EditorTool;
  activeContext: EditorContext;
  selectionGeometry: ROIGeometry | null;
  blurIntensity: number;
  pixelateIntensity: number;
}

const MAX_UNDO_LEVELS = 10;

/**
 * Hook de estado global del editor
 * 
 * Gestiona:
 * - Contexto activo (qué overlay mostrar)
 * - Herramienta activa
 * - ROI/Selección
 * - Intensidades de efectos (blur, pixelate)
 * - Stack de undo (mínimo 10 niveles)
 */
export function useEditorState() {
  const [activeContext, setActiveContext] = useState<EditorContext>('none');
  const [activeTool, setActiveTool] = useState<EditorTool>('none');
  const [selectionGeometry, setSelectionGeometry] = useState<ROIGeometry | null>(null);
  const [blurIntensity, setBlurIntensity] = useState(50.0);
  const [pixelateIntensity, setPixelateIntensity] = useState(50.0);
  
  const undoStackRef = useRef<EditorSnapshot[]>([]);

  const hasValidSelection = selectionGeometry !== null;

  /**
   * Crea un snapshot del estado actual para undo
   */
  const createSnapshot = useCallback((): EditorSnapshot => {
    return {
      activeTool,
      activeContext,
      selectionGeometry: selectionGeometry ? { ...selectionGeometry } : null,
      blurIntensity,
      pixelateIntensity,
    };
  }, [activeTool, activeContext, selectionGeometry, blurIntensity, pixelateIntensity]);

  /**
   * Guarda el estado actual en el stack de undo
   */
  const pushUndo = useCallback(() => {
    const snapshot = createSnapshot();
    undoStackRef.current.push(snapshot);
    
    // Limitar a 10 niveles
    if (undoStackRef.current.length > MAX_UNDO_LEVELS) {
      undoStackRef.current.shift();
    }
  }, [createSnapshot]);

  /**
   * Restaura el último estado del stack de undo
   */
  const undo = useCallback(() => {
    if (undoStackRef.current.length === 0) return;

    const snapshot = undoStackRef.current.pop()!;
    setActiveTool(snapshot.activeTool);
    setActiveContext(snapshot.activeContext);
    setSelectionGeometry(snapshot.selectionGeometry);
    setBlurIntensity(snapshot.blurIntensity);
    setPixelateIntensity(snapshot.pixelateIntensity);
  }, []);

  /**
   * Establece la herramienta activa y su contexto
   */
  const setActiveToolWithContext = useCallback((tool: EditorTool) => {
    // Si se reentra a pixelate, resetear intensidad
    if (tool === 'pixelate' && activeTool === 'pixelate') {
      setPixelateIntensity(50.0);
    }
    
    setActiveTool(tool);
    
    // Mapear tool a contexto
    switch (tool) {
      case 'blur':
        setActiveContext('action_blur');
        break;
      case 'pixelate':
        setActiveContext('action_pixelate');
        // Resetear intensidad al reentrar (si no estaba activo antes)
        if (activeTool !== 'pixelate') {
          setPixelateIntensity(50.0);
        }
        break;
      case 'watermark':
        setActiveContext('action_watermark');
        break;
      case 'metadata':
        setActiveContext('action_metadata');
        break;
      case 'home':
        setActiveContext('none');
        break;
      default:
        // Otros tools...
        break;
    }
  }, [activeTool]);

  const canUndo = undoStackRef.current.length > 0;

  return {
    activeContext,
    activeTool,
    selectionGeometry,
    setSelectionGeometry,
    blurIntensity,
    setBlurIntensity,
    pixelateIntensity,
    setPixelateIntensity,
    hasValidSelection,
    pushUndo,
    undo,
    canUndo,
    setActiveTool: setActiveToolWithContext,
  };
}
