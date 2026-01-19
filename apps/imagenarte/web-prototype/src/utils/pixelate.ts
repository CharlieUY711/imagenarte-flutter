/**
 * Aplica efecto de pixelado a una región de imagen usando máscara ROI
 * 
 * @param imageData - Datos de imagen RGBA (Uint8ClampedArray)
 * @param width - Ancho de la imagen
 * @param height - Alto de la imagen
 * @param blockSize - Tamaño del bloque de pixelado (2-50px)
 * @param mask - Máscara binaria (Uint8Array) donde 1 = aplicar pixelado, 0 = mantener original
 * 
 * @returns Nuevos datos de imagen con pixelado aplicado solo dentro de la máscara
 */
export function applyPixelate(
  imageData: Uint8ClampedArray,
  width: number,
  height: number,
  blockSize: number,
  mask?: Uint8Array
): Uint8ClampedArray {
  const result = new Uint8ClampedArray(imageData);
  const hasMask = mask !== undefined;
  const blockSizeInt = Math.max(2, Math.round(blockSize));

  // Procesar la imagen en bloques
  for (let blockY = 0; blockY < height; blockY += blockSizeInt) {
    for (let blockX = 0; blockX < width; blockX += blockSizeInt) {
      // Calcular tamaño real del bloque (puede ser menor en los bordes)
      const actualBlockWidth = Math.min(blockSizeInt, width - blockX);
      const actualBlockHeight = Math.min(blockSizeInt, height - blockY);

      // Acumuladores para el color promedio del bloque
      let rSum = 0;
      let gSum = 0;
      let bSum = 0;
      let aSum = 0;
      let pixelCount = 0;
      const pixelsInBlock: Array<{ x: number; y: number; index: number }> = [];

      // Recopilar todos los píxeles del bloque que están dentro de la máscara
      for (let y = blockY; y < blockY + actualBlockHeight; y++) {
        for (let x = blockX; x < blockX + actualBlockWidth; x++) {
          const index = (y * width + x) * 4;
          const maskIndex = y * width + x;

          // Verificar máscara si existe
          if (hasMask && mask![maskIndex] === 0) {
            // Pixel fuera de la máscara, saltar
            continue;
          }

          pixelsInBlock.push({ x, y, index });
          rSum += imageData[index];
          gSum += imageData[index + 1];
          bSum += imageData[index + 2];
          aSum += imageData[index + 3];
          pixelCount++;
        }
      }

      // Si no hay píxeles en el bloque (todos fuera de la máscara), continuar
      if (pixelCount === 0) {
        continue;
      }

      // Calcular color promedio del bloque
      const avgR = Math.round(rSum / pixelCount);
      const avgG = Math.round(gSum / pixelCount);
      const avgB = Math.round(bSum / pixelCount);
      const avgA = Math.round(aSum / pixelCount);

      // Aplicar el color promedio a todos los píxeles del bloque
      for (const pixel of pixelsInBlock) {
        result[pixel.index] = avgR;
        result[pixel.index + 1] = avgG;
        result[pixel.index + 2] = avgB;
        result[pixel.index + 3] = avgA;
      }
    }
  }

  return result;
}

/**
 * Crea una máscara binaria desde una geometría ROI
 * 
 * @param width - Ancho de la imagen
 * @param height - Alto de la imagen
 * @param roiGeometry - Geometría del ROI (rectángulo, círculo, o path libre)
 * 
 * @returns Máscara binaria (Uint8Array) donde 1 = dentro del ROI, 0 = fuera
 */
export function createROIMask(
  width: number,
  height: number,
  roiGeometry: {
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
): Uint8Array {
  const mask = new Uint8Array(width * height);

  if (roiGeometry.type === 'rect') {
    const { x = 0, y = 0, width: w = width, height: h = height, rotation = 0 } = roiGeometry;
    
    // Para rectángulos rotados, usar path de polígono
    if (rotation !== 0) {
      const cx = x + w / 2;
      const cy = y + h / 2;
      const cos = Math.cos(rotation);
      const sin = Math.sin(rotation);
      
      const corners = [
        { x: -w / 2, y: -h / 2 },
        { x: w / 2, y: -h / 2 },
        { x: w / 2, y: h / 2 },
        { x: -w / 2, y: h / 2 },
      ].map(corner => ({
        x: cx + corner.x * cos - corner.y * sin,
        y: cy + corner.x * sin + corner.y * cos,
      }));

      // Rellenar polígono usando ray casting
      for (let py = 0; py < height; py++) {
        for (let px = 0; px < width; px++) {
          if (isPointInPolygon(px, py, corners)) {
            mask[py * width + px] = 1;
          }
        }
      }
    } else {
      // Rectángulo sin rotación: simple bounding box
      const x1 = Math.max(0, Math.floor(x));
      const y1 = Math.max(0, Math.floor(y));
      const x2 = Math.min(width, Math.ceil(x + w));
      const y2 = Math.min(height, Math.ceil(y + h));

      for (let py = y1; py < y2; py++) {
        for (let px = x1; px < x2; px++) {
          mask[py * width + px] = 1;
        }
      }
    }
  } else if (roiGeometry.type === 'circle') {
    const { centerX = width / 2, centerY = height / 2, radius = Math.min(width, height) / 2 } = roiGeometry;
    
    for (let py = 0; py < height; py++) {
      for (let px = 0; px < width; px++) {
        const dx = px - centerX;
        const dy = py - centerY;
        const distance = Math.sqrt(dx * dx + dy * dy);
        if (distance <= radius) {
          mask[py * width + px] = 1;
        }
      }
    }
  } else if (roiGeometry.type === 'path' && roiGeometry.path) {
    // Path libre: usar ray casting
    for (let py = 0; py < height; py++) {
      for (let px = 0; px < width; px++) {
        if (isPointInPolygon(px, py, roiGeometry.path)) {
          mask[py * width + px] = 1;
        }
      }
    }
  }

  return mask;
}

/**
 * Verifica si un punto está dentro de un polígono usando ray casting
 */
function isPointInPolygon(
  px: number,
  py: number,
  polygon: Array<{ x: number; y: number }>
): boolean {
  let inside = false;
  for (let i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
    const xi = polygon[i].x;
    const yi = polygon[i].y;
    const xj = polygon[j].x;
    const yj = polygon[j].y;

    const intersect =
      yi > py !== yj > py && px < ((xj - xi) * (py - yi)) / (yj - yi) + xi;
    if (intersect) inside = !inside;
  }
  return inside;
}
