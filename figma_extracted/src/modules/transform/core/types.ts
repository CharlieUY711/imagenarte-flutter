/**
 * Tipos puros del módulo Transform (sin dependencias de React/DOM)
 */

export type Point = { x: number; y: number };

export type Shape =
  | { kind: 'quad'; points: [Point, Point, Point, Point] }
  | { kind: 'circle'; center: Point; radius: number };

export type TransformZone = 'MOVE' | 'ROTATE' | 'NONE';

export type TransformMode = 'MOVE' | 'ROTATE';

export type TransformState = {
  shape: Shape;
  hoverZone: TransformZone;
  isDragging: boolean;
  dragMode: TransformMode;
  startPointer: Point | null;

  // Snapshot para drag:
  startShape: Shape | null;
  startCenter: Point | null;
  startAngle0: number | null;
};

export type TransformConfig = {
  quadInnerInsetRatio: number; // 0.10 = 10% hacia el centro
};

export type TransformEvent =
  | { type: 'POINTER_MOVE'; p: Point }
  | { type: 'POINTER_DOWN'; p: Point }
  | { type: 'POINTER_UP' }
  | { type: 'SET_SHAPE'; shape: Shape };
