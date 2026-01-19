import { useState, useEffect, useRef } from 'react';
import { ArrowLeft } from 'lucide-react';
import { Button } from '@/app/components/Button';
import { Toggle } from '@/app/components/Toggle';
import { Slider } from '@/app/components/Slider';
import { Dropdown } from '@/app/components/Dropdown';
import { CollapsibleSection } from '@/app/components/CollapsibleSection';
import { Input } from '@/app/components/ui/input';
import { ActionsStateMVP } from '@/app/types/actions';

interface ExportScreenProps {
  imageFile: File;
  imageUrl: string;
  actions: ActionsStateMVP;
  onBack: () => void;
  onComplete: () => void;
}

export function ExportScreen({
  imageFile,
  imageUrl,
  actions,
  onBack,
  onComplete,
}: ExportScreenProps) {
  const [isProcessing, setIsProcessing] = useState(false);
  const [processedUrl, setProcessedUrl] = useState<string>('');
  
  // Opciones de exportación
  const [exportFormat, setExportFormat] = useState('jpeg');
  const [quality, setQuality] = useState(80);
  const [addWatermark, setAddWatermark] = useState(false);
  const [watermarkText, setWatermarkText] = useState('');
  const [watermarkPosition, setWatermarkPosition] = useState('bottom-right');

  const canvasRef = useRef<HTMLCanvasElement>(null);
  const imageRef = useRef<HTMLImageElement | null>(null);

  // Procesar imagen cuando carga o cuando cambian opciones de watermark
  useEffect(() => {
    const img = new Image();
    img.onload = () => {
      imageRef.current = img;
      processImage(img);
    };
    img.src = imageUrl;
    
    return () => {
      if (processedUrl) {
        URL.revokeObjectURL(processedUrl);
      }
    };
  }, [imageUrl, addWatermark, watermarkText, watermarkPosition]);

  const processImage = (img: HTMLImageElement) => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    // Configurar canvas
    let width = img.width;
    let height = img.height;

    // Aplicar crop si está habilitado
    if (actions.crop.enabled) {
      const ratios: Record<string, number> = {
        '1:1': 1,
        '16:9': 16 / 9,
        '4:3': 4 / 3,
        '9:16': 9 / 16,
      };
      const targetRatio = ratios[actions.crop.ratio];
      const currentRatio = width / height;

      if (currentRatio > targetRatio) {
        // Recortar ancho
        width = height * targetRatio;
      } else {
        // Recortar alto
        height = width / targetRatio;
      }
    }

    canvas.width = width;
    canvas.height = height;

    // Dibujar imagen
    const sourceX = (img.width - width) / 2;
    const sourceY = (img.height - height) / 2;
    ctx.drawImage(img, sourceX, sourceY, width, height, 0, 0, width, height);

    // Aplicar pixelado de rostro (simulado)
    if (actions.pixelate.enabled) {
      const pixelSize = actions.pixelate.intensity * 5;
      const faceWidth = width * 0.25;
      const faceHeight = height * 0.3;
      const faceX = width * 0.38;
      const faceY = height * 0.15;

      // Pixelar área del rostro
      const imageData = ctx.getImageData(faceX, faceY, faceWidth, faceHeight);
      
      for (let y = 0; y < faceHeight; y += pixelSize) {
        for (let x = 0; x < faceWidth; x += pixelSize) {
          const pixelIndex = (y * faceWidth + x) * 4;
          const r = imageData.data[pixelIndex];
          const g = imageData.data[pixelIndex + 1];
          const b = imageData.data[pixelIndex + 2];
          
          ctx.fillStyle = `rgb(${r}, ${g}, ${b})`;
          ctx.fillRect(faceX + x, faceY + y, pixelSize, pixelSize);
        }
      }
    }

    // Aplicar blur (simulado con desenfoque de canvas)
    if (actions.blur.enabled) {
      const blurAmount = actions.blur.intensity * 0.5;
      ctx.filter = `blur(${blurAmount}px)`;
      
      // Re-dibujar con blur en área selectiva
      const tempCanvas = document.createElement('canvas');
      tempCanvas.width = width;
      tempCanvas.height = height;
      const tempCtx = tempCanvas.getContext('2d');
      if (tempCtx) {
        tempCtx.drawImage(canvas, 0, 0);
        ctx.filter = 'none';
        ctx.drawImage(tempCanvas, 0, 0);
      }
    }

    // Aplicar watermark si está habilitado
    if (addWatermark && watermarkText.trim()) {
      ctx.filter = 'none';
      ctx.font = 'bold 24px sans-serif';
      ctx.fillStyle = 'rgba(255, 255, 255, 0.7)';
      ctx.strokeStyle = 'rgba(0, 0, 0, 0.7)';
      ctx.lineWidth = 2;

      const padding = 20;
      const textMetrics = ctx.measureText(watermarkText);
      const textWidth = textMetrics.width;
      const textHeight = 24;

      let x = padding;
      let y = height - padding;

      if (watermarkPosition === 'top-left') {
        x = padding;
        y = padding + textHeight;
      } else if (watermarkPosition === 'top-right') {
        x = width - textWidth - padding;
        y = padding + textHeight;
      } else if (watermarkPosition === 'bottom-left') {
        x = padding;
        y = height - padding;
      } else if (watermarkPosition === 'bottom-right') {
        x = width - textWidth - padding;
        y = height - padding;
      }

      ctx.strokeText(watermarkText, x, y);
      ctx.fillText(watermarkText, x, y);
    }

    // Actualizar preview
    const dataUrl = canvas.toDataURL('image/jpeg', quality / 100);
    setProcessedUrl(dataUrl);
  };

  const handleExport = async () => {
    setIsProcessing(true);

    // Simular procesamiento
    await new Promise(resolve => setTimeout(resolve, 800));

    const canvas = canvasRef.current;
    if (!canvas) {
      setIsProcessing(false);
      return;
    }

    const mimeType = exportFormat === 'png' ? 'image/png' : 'image/jpeg';
    const qualityValue = exportFormat === 'png' ? 1 : quality / 100;

    canvas.toBlob((blob) => {
      if (!blob) {
        setIsProcessing(false);
        return;
      }

      const url = URL.createObjectURL(blob);
      const link = document.createElement('a');
      const timestamp = new Date().getTime();
      link.download = `imagenarte_${timestamp}.${exportFormat}`;
      link.href = url;
      link.click();

      URL.revokeObjectURL(url);
      setIsProcessing(false);

      // Volver a Home después de exportar
      setTimeout(() => {
        onComplete();
      }, 500);
    }, mimeType, qualityValue);
  };

  return (
    <div className="min-h-screen flex flex-col bg-background">
      {/* Header */}
      <div className="flex items-center gap-3 p-4 border-b border-border">
        <button
          onClick={onBack}
          className="p-2 -ml-2 rounded-lg active:bg-muted transition-colors"
          aria-label="Volver"
        >
          <ArrowLeft className="w-5 h-5" />
        </button>
        <h1 className="text-lg font-medium">Exportar imagen</h1>
      </div>

      {/* Preview procesado (con efectos aplicados) */}
      <div 
        className="relative bg-muted border-b border-border" 
        style={{ height: '45vh', minHeight: '280px' }}
      >
        {processedUrl ? (
          <img 
            src={processedUrl} 
            alt="Imagen procesada" 
            className="w-full h-full object-contain"
          />
        ) : (
          <div className="w-full h-full flex items-center justify-center">
            <p className="text-muted-foreground">Procesando imagen...</p>
          </div>
        )}
      </div>

      {/* Canvas oculto para procesamiento */}
      <canvas ref={canvasRef} className="hidden" />

      {/* Opciones de exportación */}
      <div className="flex-1 flex flex-col bg-background">
        <div className="flex-1 overflow-y-auto">
          
          <CollapsibleSection title="Formato de salida">
            <Dropdown
              label="Formato"
              value={exportFormat}
              onChange={setExportFormat}
              options={[
                { value: 'jpeg', label: 'JPEG (menor tamaño)' },
                { value: 'png', label: 'PNG (mayor calidad)' },
              ]}
            />
          </CollapsibleSection>

          <CollapsibleSection title="Calidad">
            <Slider
              label={`Calidad: ${quality}%`}
              min={10}
              max={100}
              step={5}
              value={quality}
              onChange={setQuality}
              disabled={exportFormat === 'png'}
            />
            {exportFormat === 'png' && (
              <p className="text-sm text-muted-foreground mt-2">
                PNG no usa compresión con pérdida.
              </p>
            )}
          </CollapsibleSection>

          <CollapsibleSection title="Marca de agua (opcional)">
            <Toggle
              label="Agregar marca de agua"
              checked={addWatermark}
              onChange={setAddWatermark}
            />
            {addWatermark && (
              <>
                <div className="mt-3">
                  <Input
                    placeholder="Texto de la marca de agua"
                    value={watermarkText}
                    onChange={(e) => setWatermarkText(e.target.value)}
                  />
                </div>
                <div className="mt-3">
                  <Dropdown
                    label="Posición"
                    value={watermarkPosition}
                    onChange={setWatermarkPosition}
                    options={[
                      { value: 'top-left', label: 'Superior izquierda' },
                      { value: 'top-right', label: 'Superior derecha' },
                      { value: 'bottom-left', label: 'Inferior izquierda' },
                      { value: 'bottom-right', label: 'Inferior derecha' },
                    ]}
                  />
                </div>
              </>
            )}
          </CollapsibleSection>
        </div>

        {/* Botón Exportar */}
        <div className="p-4 border-t border-border bg-background">
          <Button
            variant="primary"
            onClick={handleExport}
            isLoading={isProcessing}
            className="w-full"
          >
            {isProcessing ? 'Exportando...' : 'Exportar'}
          </Button>
        </div>
      </div>
    </div>
  );
}
