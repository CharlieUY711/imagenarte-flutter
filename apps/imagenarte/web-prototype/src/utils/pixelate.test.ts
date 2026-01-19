/**
 * Tests unitarios para las funciones de pixelado
 * 
 * Ejecutar con: npm test
 */

import { applyPixelate, createROIMask } from './pixelate';

describe('applyPixelate', () => {
  it('debería aplicar pixelado a toda la imagen sin máscara', () => {
    const width = 10;
    const height = 10;
    const imageData = new Uint8ClampedArray(width * height * 4);
    
    // Llenar con color rojo
    for (let i = 0; i < imageData.length; i += 4) {
      imageData[i] = 255;     // R
      imageData[i + 1] = 0;   // G
      imageData[i + 2] = 0;   // B
      imageData[i + 3] = 255; // A
    }

    const result = applyPixelate(imageData, width, height, 5);

    // Verificar que el resultado tiene el mismo tamaño
    expect(result.length).toBe(imageData.length);
  });

  it('debería aplicar pixelado solo dentro de la máscara', () => {
    const width = 10;
    const height = 10;
    const imageData = new Uint8ClampedArray(width * height * 4);
    const mask = new Uint8Array(width * height);

    // Crear máscara: solo mitad izquierda
    for (let y = 0; y < height; y++) {
      for (let x = 0; x < width; x++) {
        if (x < width / 2) {
          mask[y * width + x] = 1;
        }
      }
    }

    // Llenar imagen con colores diferentes
    for (let i = 0; i < imageData.length; i += 4) {
      imageData[i] = 255;
      imageData[i + 1] = 0;
      imageData[i + 2] = 0;
      imageData[i + 3] = 255;
    }

    const result = applyPixelate(imageData, width, height, 5, mask);

    // Verificar que el resultado tiene el mismo tamaño
    expect(result.length).toBe(imageData.length);
  });
});

describe('createROIMask', () => {
  it('debería crear máscara para rectángulo', () => {
    const width = 100;
    const height = 100;
    const mask = createROIMask(width, height, {
      type: 'rect',
      x: 10,
      y: 10,
      width: 50,
      height: 50,
    });

    expect(mask.length).toBe(width * height);
    // Verificar que hay píxeles activos en el área del rectángulo
    expect(mask[10 * width + 10]).toBe(1);
    expect(mask[59 * width + 59]).toBe(1);
    // Verificar que hay píxeles inactivos fuera del rectángulo
    expect(mask[5 * width + 5]).toBe(0);
  });

  it('debería crear máscara para círculo', () => {
    const width = 100;
    const height = 100;
    const mask = createROIMask(width, height, {
      type: 'circle',
      centerX: 50,
      centerY: 50,
      radius: 25,
    });

    expect(mask.length).toBe(width * height);
    // Verificar que el centro está activo
    expect(mask[50 * width + 50]).toBe(1);
    // Verificar que las esquinas están inactivas
    expect(mask[0 * width + 0]).toBe(0);
  });
});
