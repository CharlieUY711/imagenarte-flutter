/**
 * Overlay para mostrar pixelado rojo provisional sobre áreas detectadas
 * Este pixelado es solo indicativo, no definitivo
 */
interface FacePixelatePreviewOverlayProps {
  areas: Array<{ x: number; y: number; width: number; height: number }>;
  containerWidth: number;
  containerHeight: number;
  imageWidth: number;
  imageHeight: number;
}

export function FacePixelatePreviewOverlay({
  areas,
  containerWidth,
  containerHeight,
  imageWidth,
  imageHeight,
}: FacePixelatePreviewOverlayProps) {
  // Calcular escala entre imagen y contenedor
  const scaleX = containerWidth / imageWidth;
  const scaleY = containerHeight / imageHeight;

  return (
    <div className="absolute inset-0 z-20 pointer-events-none">
      {areas.map((area, index) => {
        // Convertir coordenadas de imagen a coordenadas de contenedor
        const x = area.x * scaleX;
        const y = area.y * scaleY;
        const width = area.width * scaleX;
        const height = area.height * scaleY;

        return (
          <div
            key={index}
            className="absolute border-2 border-red-500 bg-red-500/20"
            style={{
              left: `${x}px`,
              top: `${y}px`,
              width: `${width}px`,
              height: `${height}px`,
            }}
          >
            {/* Efecto de pixelado simulado con patrón */}
            <div
              className="w-full h-full opacity-50"
              style={{
                backgroundImage: `
                  repeating-linear-gradient(0deg, transparent, transparent 8px, rgba(255,0,0,0.1) 8px, rgba(255,0,0,0.1) 16px),
                  repeating-linear-gradient(90deg, transparent, transparent 8px, rgba(255,0,0,0.1) 8px, rgba(255,0,0,0.1) 16px)
                `,
              }}
            />
          </div>
        );
      })}
    </div>
  );
}
