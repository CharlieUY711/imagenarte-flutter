import { useState, useEffect, useRef } from 'react';
import { Button } from '@/app/components/Button';
import { Toggle } from '@/app/components/Toggle';
import { Slider } from '@/app/components/Slider';
import { Dropdown } from '@/app/components/Dropdown';
import { CollapsibleSection } from '@/app/components/CollapsibleSection';
import { Input } from '@/app/components/ui/input';
import { ArrowLeft } from 'lucide-react';
import { ActionsState } from './WizardStep2';

type EditorMode = 'edit' | 'export';

interface ImageEditorProps {
  imageFile: File;
  onBack: () => void;
}

export function ImageEditor({ imageFile, onBack }: ImageEditorProps) {
  const [mode, setMode] = useState<EditorMode>('edit');
  const [previewUrl, setPreviewUrl] = useState<string>('');
  const [isProcessing, setIsProcessing] = useState(false);
  
  // Estados de acciones (Step 2)
  const [actions, setActions] = useState<ActionsState>({
    blurFaces: false,
    adjustBrightness: false,
    brightnessValue: 0,
    adjustContrast: false,
    contrastValue: 0,
    removeMetadata: false,
  });

  // Estados de opciones de exportación (Step 3)
  const [exportFormat, setExportFormat] = useState('jpeg');
  const [quality, setQuality] = useState(80);
  const [addWatermark, setAddWatermark] = useState(false);
  const [watermarkText, setWatermarkText] = useState('');
  const [watermarkPosition, setWatermarkPosition] = useState('bottom-right');

  const canvasRef = useRef<HTMLCanvasElement>(null);
  const originalImageRef = useRef<HTMLImageElement | null>(null);

  // Cargar imagen original
  useEffect(() => {
    const img = new Image();
    img.onload = () => {
      originalImageRef.current = img;
      applyActionsToImage(img);
    };
    img.src = URL.createObjectURL(imageFile);
    
    return () => {
      URL.revokeObjectURL(img.src);
    };
  }, [imageFile]);

  // Aplicar acciones cuando cambian
  useEffect(() => {
    if (originalImageRef.current) {
      applyActionsToImage(originalImageRef.current);
    }
  }, [actions, addWatermark, watermarkText, watermarkPosition]);

  const applyActionsToImage = (img: HTMLImageElement) => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    canvas.width = img.width;
    canvas.height = img.height;

    ctx.drawImage(img, 0, 0);

    // Aplicar brillo
    if (actions.adjustBrightness && actions.brightnessValue !== 0) {
      const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height);
      const data = imageData.data;
      const brightness = actions.brightnessValue;

      for (let i = 0; i < data.length; i += 4) {
        data[i] += brightness;
        data[i + 1] += brightness;
        data[i + 2] += brightness;
      }

      ctx.putImageData(imageData, 0, 0);
    }

    // Aplicar contraste
    if (actions.adjustContrast && actions.contrastValue !== 0) {
      const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height);
      const data = imageData.data;
      const factor = (259 * (actions.contrastValue + 255)) / (255 * (259 - actions.contrastValue));

      for (let i = 0; i < data.length; i += 4) {
        data[i] = factor * (data[i] - 128) + 128;
        data[i + 1] = factor * (data[i + 1] - 128) + 128;
        data[i + 2] = factor * (data[i + 2] - 128) + 128;
      }

      ctx.putImageData(imageData, 0, 0);
    }

    // Simular desenfoque de rostros (placeholder)
    if (actions.blurFaces) {
      ctx.fillStyle = 'rgba(200, 200, 200, 0.6)';
      const faceWidth = canvas.width * 0.2;
      const faceHeight = canvas.height * 0.25;
      const faceX = canvas.width * 0.4;
      const faceY = canvas.height * 0.2;
      ctx.fillRect(faceX, faceY, faceWidth, faceHeight);
      
      ctx.font = '14px sans-serif';
      ctx.fillStyle = '#666';
      ctx.fillText('Rostro desenfocado', faceX + 10, faceY + faceHeight / 2);
    }

    // Aplicar watermark
    if (addWatermark && watermarkText.trim()) {
      ctx.font = 'bold 24px sans-serif';
      ctx.fillStyle = 'rgba(255, 255, 255, 0.6)';
      ctx.strokeStyle = 'rgba(0, 0, 0, 0.6)';
      ctx.lineWidth = 2;

      const padding = 20;
      const textMetrics = ctx.measureText(watermarkText);
      const textWidth = textMetrics.width;
      const textHeight = 24;

      let x = padding;
      let y = canvas.height - padding;

      if (watermarkPosition === 'top-left') {
        x = padding;
        y = padding + textHeight;
      } else if (watermarkPosition === 'top-right') {
        x = canvas.width - textWidth - padding;
        y = padding + textHeight;
      } else if (watermarkPosition === 'bottom-left') {
        x = padding;
        y = canvas.height - padding;
      } else if (watermarkPosition === 'bottom-right') {
        x = canvas.width - textWidth - padding;
        y = canvas.height - padding;
      }

      ctx.strokeText(watermarkText, x, y);
      ctx.fillText(watermarkText, x, y);
    }

    // Actualizar preview
    const dataUrl = canvas.toDataURL('image/jpeg', quality / 100);
    setPreviewUrl(dataUrl);
  };

  const handleGrabar = () => {
    setMode('export');
  };

  const handleExportar = async () => {
    setIsProcessing(true);

    // Simular procesamiento
    await new Promise(resolve => setTimeout(resolve, 800));

    const canvas = canvasRef.current;
    if (!canvas) return;

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
        onBack();
      }, 500);
    }, mimeType, qualityValue);
  };

  const handleBackClick = () => {
    if (mode === 'export') {
      setMode('edit');
    } else {
      onBack();
    }
  };

  return (
    <div className="min-h-screen flex flex-col bg-background">
      {/* Header con botón volver */}
      <div className="flex items-center gap-3 p-4 border-b border-border">
        <button
          onClick={handleBackClick}
          className="p-2 -ml-2 rounded-lg active:bg-muted transition-colors"
        >
          <ArrowLeft className="w-5 h-5" />
        </button>
        <h1 className="text-lg font-medium">
          {mode === 'edit' ? 'Editar imagen' : 'Opciones de exportación'}
        </h1>
      </div>

      {/* Preview de imagen (fija, 50-55% de la pantalla) */}
      <div className="relative bg-muted" style={{ height: '50vh', minHeight: '300px' }}>
        {previewUrl ? (
          <img 
            src={previewUrl} 
            alt="Preview" 
            className="w-full h-full object-contain"
          />
        ) : (
          <div className="w-full h-full flex items-center justify-center">
            <p className="text-muted-foreground">Cargando imagen...</p>
          </div>
        )}
      </div>

      {/* Canvas oculto para procesamiento */}
      <canvas ref={canvasRef} className="hidden" />

      {/* Parte inferior: Acciones o Opciones (colapsables) */}
      <div className="flex-1 flex flex-col bg-background">
        <div className="flex-1 overflow-y-auto">
          {mode === 'edit' ? (
            // Modo edición: Acciones
            <div>
              <CollapsibleSection title="Desenfocar rostros">
                <Toggle
                  label="Activar desenfoque automático"
                  checked={actions.blurFaces}
                  onChange={(checked) => setActions({ ...actions, blurFaces: checked })}
                />
                <p className="text-sm text-muted-foreground mt-2">
                  Detecta y difumina rostros para proteger identidad.
                </p>
              </CollapsibleSection>

              <CollapsibleSection title="Ajustar brillo">
                <Toggle
                  label="Activar ajuste de brillo"
                  checked={actions.adjustBrightness}
                  onChange={(checked) => setActions({ ...actions, adjustBrightness: checked })}
                />
                {actions.adjustBrightness && (
                  <Slider
                    label={`Brillo: ${actions.brightnessValue > 0 ? '+' : ''}${actions.brightnessValue}`}
                    min={-100}
                    max={100}
                    step={1}
                    value={actions.brightnessValue}
                    onChange={(value) => setActions({ ...actions, brightnessValue: value })}
                  />
                )}
              </CollapsibleSection>

              <CollapsibleSection title="Ajustar contraste">
                <Toggle
                  label="Activar ajuste de contraste"
                  checked={actions.adjustContrast}
                  onChange={(checked) => setActions({ ...actions, adjustContrast: checked })}
                />
                {actions.adjustContrast && (
                  <Slider
                    label={`Contraste: ${actions.contrastValue > 0 ? '+' : ''}${actions.contrastValue}`}
                    min={-100}
                    max={100}
                    step={1}
                    value={actions.contrastValue}
                    onChange={(value) => setActions({ ...actions, contrastValue: value })}
                  />
                )}
              </CollapsibleSection>

              <CollapsibleSection title="Eliminar metadatos">
                <Toggle
                  label="Eliminar información EXIF"
                  checked={actions.removeMetadata}
                  onChange={(checked) => setActions({ ...actions, removeMetadata: checked })}
                />
                <p className="text-sm text-muted-foreground mt-2">
                  Elimina GPS, cámara, fecha y otros datos de la foto.
                </p>
              </CollapsibleSection>
            </div>
          ) : (
            // Modo exportación: Opciones
            <div>
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

              <CollapsibleSection title="Calidad de compresión">
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

              <CollapsibleSection title="Marca de agua">
                <Toggle
                  label="Agregar marca de agua"
                  checked={addWatermark}
                  onChange={setAddWatermark}
                />
                {addWatermark && (
                  <>
                    <Input
                      placeholder="Texto de la marca de agua"
                      value={watermarkText}
                      onChange={(e) => setWatermarkText(e.target.value)}
                    />
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
                  </>
                )}
              </CollapsibleSection>
            </div>
          )}
        </div>

        {/* Botón de acción (fijo en la parte inferior) */}
        <div className="p-4 border-t border-border bg-background">
          {mode === 'edit' ? (
            <Button
              variant="primary"
              onClick={handleGrabar}
              className="w-full"
            >
              Grabar
            </Button>
          ) : (
            <Button
              variant="primary"
              onClick={handleExportar}
              isLoading={isProcessing}
              className="w-full"
            >
              {isProcessing ? 'Exportando...' : 'Exportar'}
            </Button>
          )}
        </div>
      </div>
    </div>
  );
}
