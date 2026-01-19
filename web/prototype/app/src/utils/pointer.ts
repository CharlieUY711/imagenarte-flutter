/**
 * Utilidades para manejo de coordenadas de puntero
 * 
 * Convierte coordenadas del viewport (clientX/clientY) a coordenadas locales
 * del contenedor, considerando transformaciones de escala (zoom/fit).
 */

/**
 * Obtiene las coordenadas locales de un evento de puntero
 * relativas a un elemento contenedor.
 * 
 * @param e - Evento de puntero (PointerEvent o React.PointerEvent)
 * @param containerElement - Elemento contenedor (HTMLElement)
 * @returns Coordenadas { x, y } en el espacio local del contenedor
 */
export function getLocalPoint(
  e: { clientX: number; clientY: number },
  containerElement: HTMLElement
): { x: number; y: number } {
  const rect = containerElement.getBoundingClientRect();
  return {
    x: e.clientX - rect.left,
    y: e.clientY - rect.top,
  };
}

/**
 * Obtiene el factor de escala de un elemento.
 * 
 * Busca:
 * 1. Transform matrix en el estilo computado
 * 2. Dataset attribute "zoom" o "scale"
 * 3. Transform CSS con scale()
 * 
 * @param element - Elemento a analizar
 * @returns Factor de escala (1.0 si no se encuentra)
 */
export function getScaleFactor(element: HTMLElement | null): number {
  if (!element) return 1.0;

  // 1. Buscar en dataset
  const zoomAttr = element.dataset.zoom || element.dataset.scale;
  if (zoomAttr) {
    const parsed = parseFloat(zoomAttr);
    if (!isNaN(parsed) && parsed > 0) {
      return parsed;
    }
  }

  // 2. Buscar en el estilo computado (transform matrix)
  const style = window.getComputedStyle(element);
  const transform = style.transform;
  
  if (transform && transform !== 'none') {
    // Extraer scale de matrix(a, b, c, d, tx, ty)
    // matrix(scaleX, skewY, skewX, scaleY, translateX, translateY)
    const matrixMatch = transform.match(/matrix\(([^)]+)\)/);
    if (matrixMatch) {
      const values = matrixMatch[1].split(',').map(v => parseFloat(v.trim()));
      if (values.length >= 4) {
        // scaleX y scaleY deberían ser iguales en la mayoría de casos
        const scaleX = Math.abs(values[0]);
        const scaleY = Math.abs(values[3]);
        // Usar el promedio o el máximo según el caso
        return Math.max(scaleX, scaleY);
      }
    }
    
    // Buscar scale() directamente
    const scaleMatch = transform.match(/scale\(([^)]+)\)/);
    if (scaleMatch) {
      const parsed = parseFloat(scaleMatch[1]);
      if (!isNaN(parsed) && parsed > 0) {
        return parsed;
      }
    }
  }

  // 3. Buscar en elementos padre (hasta 3 niveles)
  let parent = element.parentElement;
  let depth = 0;
  while (parent && depth < 3) {
    const parentZoom = parent.dataset.zoom || parent.dataset.scale;
    if (parentZoom) {
      const parsed = parseFloat(parentZoom);
      if (!isNaN(parsed) && parsed > 0) {
        return parsed;
      }
    }
    parent = parent.parentElement;
    depth++;
  }

  return 1.0;
}

/**
 * Calcula el delta local entre dos puntos, dividiendo por el factor de escala.
 * 
 * @param prev - Punto anterior { x, y }
 * @param next - Punto siguiente { x, y }
 * @param scale - Factor de escala (default: 1.0)
 * @returns Delta { dx, dy } en coordenadas locales escaladas
 */
export function getLocalDelta(
  prev: { x: number; y: number },
  next: { x: number; y: number },
  scale: number = 1.0
): { dx: number; dy: number } {
  return {
    dx: (next.x - prev.x) / scale,
    dy: (next.y - prev.y) / scale,
  };
}

/**
 * Obtiene el punto local y el delta en una sola llamada (optimización).
 * 
 * @param e - Evento de puntero actual
 * @param containerElement - Elemento contenedor
 * @param startPoint - Punto inicial (en coordenadas del contenedor)
 * @returns { point, delta, scale }
 */
export function getLocalPointAndDelta(
  e: { clientX: number; clientY: number },
  containerElement: HTMLElement,
  startPoint: { x: number; y: number }
): { point: { x: number; y: number }; delta: { dx: number; dy: number }; scale: number } {
  const scale = getScaleFactor(containerElement);
  const point = getLocalPoint(e, containerElement);
  const delta = getLocalDelta(startPoint, point, scale);
  
  return { point, delta, scale };
}
