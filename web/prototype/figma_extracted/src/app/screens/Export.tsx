import { useState, useEffect } from 'react';
import { Button } from '@/app/components/Button';
import { Toggle } from '@/app/components/Toggle';
import { Dropdown } from '@/app/components/Dropdown';
import { Slider } from '@/app/components/Slider';
import { ImagePreview } from '@/app/components/ImagePreview';
import { SectionCard } from '@/app/components/SectionCard';
import { Input } from '@/app/components/ui/input';
import { RadialMotif } from '@/app/components/RadialMotif';
import { ArrowLeft } from 'lucide-react';
import { ActionsState } from './WizardStep2';

interface ExportProps {
  selectedImage: string | null;
  actions: ActionsState;
  onBack: () => void;
  onReset: () => void;
}

type ExportFormat = 'jpg' | 'png' | 'webp';

const FORMAT_OPTIONS = [
  { value: 'jpg', label: 'JPG' },
  { value: 'png', label: 'PNG' },
  { value: 'webp', label: 'WebP' },
];

export function Export({ selectedImage, actions, onBack, onReset }: ExportProps) {
  const [previewState, setPreviewState] = useState<'loading' | 'loaded'>('loading');
  const [exportFormat, setExportFormat] = useState<ExportFormat>('jpg');
  const [quality, setQuality] = useState(85);
  const [cleanMetadata, setCleanMetadata] = useState(true);
  const [visibleWatermark, setVisibleWatermark] = useState(false);
  const [watermarkText, setWatermarkText] = useState('');
  const [invisibleWatermark, setInvisibleWatermark] = useState(false);
  const [exportManifest, setExportManifest] = useState(false);
  const [isExporting, setIsExporting] = useState(false);
  const [exportSuccess, setExportSuccess] = useState(false);

  useEffect(() => {
    // Simular procesamiento de vista previa
    const timer = setTimeout(() => {
      setPreviewState('loaded');
    }, 1500);
    return () => clearTimeout(timer);
  }, []);

  const handleExport = async () => {
    setIsExporting(true);
    
    // Simular proceso de exportación
    await new Promise(resolve => setTimeout(resolve, 2000));
    
    // Crear un canvas para procesar la imagen
    if (selectedImage) {
      try {
        const img = new Image();
        img.src = selectedImage;
        
        await new Promise((resolve, reject) => {
          img.onload = resolve;
          img.onerror = reject;
        });
        
        const canvas = document.createElement('canvas');
        canvas.width = img.width;
        canvas.height = img.height;
        const ctx = canvas.getContext('2d');
        
        if (ctx) {
          ctx.drawImage(img, 0, 0);
          
          // Aplicar efectos simulados
          if (actions.pixelate.enabled) {
            const intensity = actions.pixelate.intensity;
            const pixelSize = Math.max(1, intensity * 2);
            ctx.filter = `blur(${pixelSize}px)`;
          }
          
          if (actions.blur.enabled) {
            const intensity = actions.blur.intensity;
            ctx.filter = `blur(${intensity}px)`;
          }
          
          // Agregar watermark visible si está activado
          if (visibleWatermark && watermarkText) {
            ctx.font = '24px sans-serif';
            ctx.fillStyle = 'rgba(255, 255, 255, 0.7)';
            ctx.fillText(watermarkText, 20, canvas.height - 20);
          }
          
          // Exportar según formato
          let mimeType = 'image/jpeg';
          let qualityValue = quality / 100;
          
          if (exportFormat === 'png') {
            mimeType = 'image/png';
            qualityValue = 1;
          } else if (exportFormat === 'webp') {
            mimeType = 'image/webp';
          }
          
          canvas.toBlob((blob) => {
            if (blob) {
              const url = URL.createObjectURL(blob);
              const link = document.createElement('a');
              link.href = url;
              link.download = `imagen-arte-${Date.now()}.${exportFormat}`;
              link.click();
              URL.revokeObjectURL(url);
              
              setExportSuccess(true);
              setIsExporting(false);
              
              // Exportar manifest si está activado
              if (invisibleWatermark && exportManifest) {
                const manifest = {
                  timestamp: new Date().toISOString(),
                  format: exportFormat,
                  quality: exportFormat !== 'png' ? quality : 100,
                  watermark: invisibleWatermark,
                  token: crypto.randomUUID(),
                };
                
                const manifestBlob = new Blob([JSON.stringify(manifest, null, 2)], { type: 'application/json' });
                const manifestUrl = URL.createObjectURL(manifestBlob);
                const manifestLink = document.createElement('a');
                manifestLink.href = manifestUrl;
                manifestLink.download = `manifest-${Date.now()}.json`;
                manifestLink.click();
                URL.revokeObjectURL(manifestUrl);
              }
            }
          }, mimeType, qualityValue);
        }
      } catch (error) {
        console.error('Error al exportar:', error);
        setIsExporting(false);
      }
    }
  };

  if (exportSuccess) {
    return (
      <div className="min-h-screen flex flex-col items-center justify-center px-6 bg-background">
        <div className="w-full max-w-md space-y-6 text-center">
          <div className="w-16 h-16 bg-muted rounded-full flex items-center justify-center mx-auto">
            <svg className="w-8 h-8 text-foreground" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
            </svg>
          </div>
          
          <div className="space-y-2">
            <h2 className="text-xl font-medium">Exportación lista</h2>
            <p className="text-muted-foreground">La imagen se guardó correctamente.</p>
          </div>
          
          <Button
            variant="primary"
            onClick={onReset}
            className="w-full"
          >
            Tratar otra imagen
          </Button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen flex flex-col bg-background">
      {/* Header */}
      <div className="border-b border-border">
        <div className="flex items-center px-4 py-3">
          <button
            onClick={onBack}
            className="p-2 -ml-2 hover:bg-accent rounded-lg transition-colors"
          >
            <ArrowLeft className="w-5 h-5" />
          </button>
          <h2 className="flex-1 text-center font-medium">Exportar</h2>
          <div className="w-9" /> {/* Spacer for centering */}
        </div>
      </div>

      {/* Content */}
      <div className="flex-1 px-6 py-6 space-y-6 overflow-y-auto">
        <ImagePreview
          src={selectedImage}
          state={previewState}
          className="max-w-md mx-auto"
        />

        <SectionCard title="Formato y calidad">
          <Dropdown
            label="Formato"
            value={exportFormat}
            onValueChange={(value) => setExportFormat(value as ExportFormat)}
            options={FORMAT_OPTIONS}
          />
          
          {(exportFormat === 'jpg' || exportFormat === 'webp') && (
            <>
              <Slider
                label="Calidad"
                value={quality}
                onValueChange={setQuality}
                min={50}
                max={100}
              />
              <p className="text-xs text-muted-foreground">
                {exportFormat === 'jpg' ? 'Mayor calidad = mayor tamaño de archivo.' : 'WebP ofrece mejor compresión que JPG.'}
              </p>
            </>
          )}
          
          {exportFormat === 'png' && (
            <p className="text-xs text-muted-foreground">
              PNG exporta sin pérdida.
            </p>
          )}
        </SectionCard>

        <SectionCard title="Privacidad">
          <Toggle
            label="Limpiar metadatos (EXIF)"
            subtitle="Recomendado: elimina información que puede revelar detalles del dispositivo."
            checked={cleanMetadata}
            onCheckedChange={setCleanMetadata}
            id="toggle-metadata"
          />
        </SectionCard>

        <SectionCard title="Watermarks">
          <Toggle
            label="Watermark visible"
            checked={visibleWatermark}
            onCheckedChange={setVisibleWatermark}
            id="toggle-visible-watermark"
          />
          
          {visibleWatermark && (
            <Input
              placeholder="Ej: @mi_usuario"
              value={watermarkText}
              onChange={(e) => setWatermarkText(e.target.value)}
            />
          )}
          
          <Toggle
            label="Watermark invisible (básico)"
            subtitle="Agrega un token de verificación a la imagen."
            checked={invisibleWatermark}
            onCheckedChange={setInvisibleWatermark}
            id="toggle-invisible-watermark"
          />
          
          {invisibleWatermark && (
            <Toggle
              label="Exportar comprobante"
              subtitle="Guarda un manifest.json para verificación local."
              checked={exportManifest}
              onCheckedChange={setExportManifest}
              id="toggle-manifest"
            />
          )}
        </SectionCard>
      </div>

      {/* Footer */}
      <div className="border-t border-border px-6 py-4">
        <Button
          variant="primary"
          onClick={handleExport}
          isLoading={isExporting}
          className="w-full"
        >
          {isExporting ? 'Exportando...' : 'Exportar'}
        </Button>
      </div>
    </div>
  );
}