import React, { useState, useRef, useEffect } from 'react';
import { OverlayOptionsRow, OverlayOption } from './OverlayOptionsRow';
import { OverlayTextInputInline } from './OverlayTextInputInline';
import { OverlayBox } from './OverlayBox';

type WatermarkWizardStep = 
  | 'WM_MODE'           // Selección: Automática | Personalizada
  | 'WM_CUSTOM_PICK'    // Personalizada: Ingresar texto | Seleccionar archivo
  | 'WM_TEXT_INPUT'     // Modo ingreso de texto
  | 'WM_VISIBLE'        // Visible: Sí | No
  | 'WM_POSITIONING'    // Modo posicionamiento (drag + rotate)
  | 'WM_DONE';          // Finalizado

interface WatermarkOverlayProps {
  onComplete: (config: {
    mode: 'AUTO' | 'CUSTOM_TEXT' | 'CUSTOM_IMAGE';
    visible: boolean;
    text?: string;
    imageFile?: File | null;
    transform?: { x: number; y: number; rotation: number; scale: number };
  }) => void;
  onClose: () => void;
}

export function WatermarkOverlay({ onComplete, onClose }: WatermarkOverlayProps) {
  // Asegurar que siempre iniciamos en WM_MODE
  const [wizardStep, setWizardStep] = useState<WatermarkWizardStep>('WM_MODE');
  const [selectedMode, setSelectedMode] = useState<'AUTO' | 'CUSTOM' | null>(null);
  const [customType, setCustomType] = useState<'TEXT' | 'IMAGE' | null>(null);
  const [watermarkText, setWatermarkText] = useState('');
  const [watermarkImageFile, setWatermarkImageFile] = useState<File | null>(null);
  const [watermarkVisible, setWatermarkVisible] = useState(true);
  const [watermarkTransform, setWatermarkTransform] = useState<{ x: number; y: number; rotation: number; scale: number }>({
    x: 50,
    y: 50,
    rotation: 0,
    scale: 1,
  });
  const fileInputRef = useRef<HTMLInputElement>(null);

  // Resetear wizard al montar el componente
  useEffect(() => {
    setWizardStep('WM_MODE');
    setSelectedMode(null);
    setCustomType(null);
  }, []);

  // A1) Selección modo: Automática | Personalizada
  const handleModeSelect = (mode: 'AUTO' | 'CUSTOM') => {
    setSelectedMode(mode);
    if (mode === 'AUTO') {
      setWizardStep('WM_VISIBLE'); // Ir directamente a Visible Sí/No
    } else {
      setWizardStep('WM_CUSTOM_PICK'); // Ir a elegir tipo personalizado
    }
  };

  // B2) Elegir tipo personalizado: Ingresar texto | Seleccionar archivo
  const handleCustomTypeSelect = (type: 'TEXT' | 'IMAGE') => {
    setCustomType(type);
    if (type === 'TEXT') {
      setWizardStep('WM_TEXT_INPUT');
    } else {
      // Abrir file picker
      fileInputRef.current?.click();
    }
  };

  // Manejar selección de archivo
  const handleFileSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      setWatermarkImageFile(file);
      setWizardStep('WM_VISIBLE'); // Ir a Visible Sí/No
    }
  };

  // Confirmar texto ingresado
  const handleTextConfirm = (text: string) => {
    setWatermarkText(text);
    setWizardStep('WM_VISIBLE'); // Ir a Visible Sí/No
  };

  // A2 / B2) Visible Sí/No
  const handleVisibleSelect = (visible: boolean) => {
    setWatermarkVisible(visible);
    
    if (!visible) {
      // Visible: No → Aplicar
      const mode = selectedMode === 'AUTO' 
        ? 'AUTO' 
        : customType === 'TEXT' 
          ? 'CUSTOM_TEXT' 
          : 'CUSTOM_IMAGE';
      
      onComplete({
        mode,
        visible: false,
        text: customType === 'TEXT' ? watermarkText : undefined,
        imageFile: customType === 'IMAGE' ? watermarkImageFile : null,
      });
      
      // Si es personalizada, volver a B2 para permitir elegir la otra opción (sin salir del wizard)
      if (selectedMode === 'CUSTOM') {
        setWizardStep('WM_CUSTOM_PICK');
        setCustomType(null);
      } else {
        // Si es automática, cerrar wizard
        onClose();
      }
    } else {
      // Visible: Sí → Entrar a modo posicionamiento
      setWizardStep('WM_POSITIONING');
    }
  };

  // Confirmar posicionamiento
  const handlePositioningConfirm = () => {
    const mode = selectedMode === 'AUTO' 
      ? 'AUTO' 
      : customType === 'TEXT' 
        ? 'CUSTOM_TEXT' 
        : 'CUSTOM_IMAGE';
    
    onComplete({
      mode,
      visible: true,
      text: customType === 'TEXT' ? watermarkText : undefined,
      imageFile: customType === 'IMAGE' ? watermarkImageFile : null,
      transform: watermarkTransform,
    });
    
    // Si es personalizada, volver a B2 para permitir elegir la otra opción (sin salir del wizard)
    if (selectedMode === 'CUSTOM') {
      setWizardStep('WM_CUSTOM_PICK');
      setCustomType(null);
      // Mantener los datos ya ingresados pero permitir agregar más
    } else {
      // Si es automática, cerrar wizard
      onClose();
    }
  };

  // Cancelar posicionamiento (volver a Visible)
  const handlePositioningCancel = () => {
    setWizardStep('WM_VISIBLE');
  };

  // Cancelar input de texto (volver a CUSTOM_PICK)
  const handleTextCancel = () => {
    setWizardStep('WM_CUSTOM_PICK');
  };

  // Renderizar según el paso del wizard
  if (wizardStep === 'WM_MODE') {
    const modeOptions: OverlayOption[] = [
      { id: 'AUTO', label: 'Automática' },
      { id: 'CUSTOM', label: 'Personalizada' },
    ];

    return (
      <>
        {/* Overlay para cerrar al hacer click fuera */}
        <div 
          className="absolute inset-0 z-10"
          onClick={onClose}
        />
        
        {/* Contenedor estándar posicionado arriba de la barra blanca */}
        <div
          className="absolute z-20"
          style={{
            bottom: '33px',
            left: '50%',
            transform: 'translateX(-50%)',
            width: 'calc(100% - 32px)', // Ancho igual al DialButton (con padding del contenedor padre)
          }}
        >
          <OverlayBox>
            <OverlayOptionsRow
              title="Tipo de selección"
              mode="text"
              options={modeOptions}
              onSelect={(id) => handleModeSelect(id as 'AUTO' | 'CUSTOM')}
              color="white"
            />
          </OverlayBox>
        </div>
      </>
    );
  }

  if (wizardStep === 'WM_CUSTOM_PICK') {
    const customTypeOptions: OverlayOption[] = [
      { id: 'TEXT', label: 'Ingresar texto' },
      { id: 'IMAGE', label: 'Seleccionar archivo' },
    ];

    return (
      <>
        <input
          ref={fileInputRef}
          type="file"
          accept="image/*"
          onChange={handleFileSelect}
          className="hidden"
        />
        {/* Overlay para cerrar al hacer click fuera */}
        <div 
          className="absolute inset-0 z-10"
          onClick={() => {
            setWizardStep('WM_MODE');
            setSelectedMode(null);
          }}
        />
        
        {/* Contenedor estándar posicionado arriba de la barra blanca */}
        <div
          className="absolute z-20"
          style={{
            bottom: '33px',
            left: '50%',
            transform: 'translateX(-50%)',
            width: 'calc(100% - 32px)', // Ancho igual al DialButton (con padding del contenedor padre)
          }}
        >
          <OverlayBox>
            <OverlayOptionsRow
              title="Selección personalizada"
              mode="text"
              options={customTypeOptions}
              onSelect={(id) => handleCustomTypeSelect(id as 'TEXT' | 'IMAGE')}
              color="white"
            />
          </OverlayBox>
        </div>
      </>
    );
  }

  if (wizardStep === 'WM_TEXT_INPUT') {
    return (
      <>
        {/* Overlay para cerrar al hacer click fuera */}
        <div 
          className="absolute inset-0 z-10"
          onClick={handleTextCancel}
        />
        
        {/* Contenedor estándar posicionado arriba de la barra blanca */}
        <div
          className="absolute z-20"
          style={{
            bottom: '33px',
            left: '50%',
            transform: 'translateX(-50%)',
            width: 'calc(100% - 32px)', // Ancho igual al DialButton (con padding del contenedor padre)
          }}
        >
          <OverlayBox>
            <OverlayTextInputInline
              initialText={watermarkText}
              onConfirm={handleTextConfirm}
              onCancel={handleTextCancel}
              placeholder="Ingrese texto…"
            />
          </OverlayBox>
        </div>
      </>
    );
  }

  if (wizardStep === 'WM_VISIBLE') {
    const visibleOptions: OverlayOption[] = [
      { id: 'YES', label: 'Sí' },
      { id: 'NO', label: 'No' },
    ];

    const handleClose = () => {
      // Volver al paso anterior según el modo
      if (selectedMode === 'AUTO') {
        setWizardStep('WM_MODE');
        setSelectedMode(null);
      } else {
        setWizardStep('WM_CUSTOM_PICK');
        setCustomType(null);
      }
    };

    return (
      <>
        {/* Overlay para cerrar al hacer click fuera */}
        <div 
          className="absolute inset-0 z-10"
          onClick={handleClose}
        />
        
        {/* Contenedor estándar posicionado arriba de la barra blanca */}
        <div
          className="absolute z-20"
          style={{
            bottom: '33px',
            left: '50%',
            transform: 'translateX(-50%)',
            width: 'calc(100% - 32px)', // Ancho igual al DialButton (con padding del contenedor padre)
          }}
        >
          <OverlayBox>
            <OverlayOptionsRow
              title="Visible"
              mode="text"
              options={visibleOptions}
              onSelect={(id) => handleVisibleSelect(id === 'YES')}
              color="white"
            />
          </OverlayBox>
        </div>
      </>
    );
  }

  if (wizardStep === 'WM_POSITIONING') {
    return (
      <WatermarkPositioningOverlay
        mode={selectedMode === 'AUTO' ? 'AUTO' : customType === 'TEXT' ? 'CUSTOM_TEXT' : 'CUSTOM_IMAGE'}
        text={customType === 'TEXT' ? watermarkText : undefined}
        imageFile={customType === 'IMAGE' ? watermarkImageFile : null}
        transform={watermarkTransform}
        onTransformChange={setWatermarkTransform}
        onConfirm={handlePositioningConfirm}
        onCancel={handlePositioningCancel}
      />
    );
  }

  return null;
}

// Componente para el modo de posicionamiento
interface WatermarkPositioningOverlayProps {
  mode: 'AUTO' | 'CUSTOM_TEXT' | 'CUSTOM_IMAGE';
  text?: string;
  imageFile?: File | null;
  transform: { x: number; y: number; rotation: number; scale: number };
  onTransformChange: (transform: { x: number; y: number; rotation: number; scale: number }) => void;
  onConfirm: () => void;
  onCancel: () => void;
}

function WatermarkPositioningOverlay({
  mode,
  text,
  imageFile,
  transform,
  onTransformChange,
  onConfirm,
  onCancel,
}: WatermarkPositioningOverlayProps) {
  const [imagePreviewUrl, setImagePreviewUrl] = useState<string | null>(null);

  // Cargar preview de imagen si es CUSTOM_IMAGE
  useEffect(() => {
    if (mode === 'CUSTOM_IMAGE' && imageFile) {
      const reader = new FileReader();
      reader.onload = (e) => {
        setImagePreviewUrl(e.target?.result as string);
      };
      reader.readAsDataURL(imageFile);
    } else {
      setImagePreviewUrl(null);
    }
  }, [mode, imageFile]);

  return (
    <>
      {/* Overlay para cerrar al hacer click fuera */}
      <div 
        className="absolute inset-0 z-10"
        onClick={onCancel}
      />
      
      {/* Contenedor de watermark (posición fija) */}
      <div
        className="absolute z-20 pointer-events-none"
        style={{
          left: `${transform.x}%`,
          top: `${transform.y}%`,
          transform: 'translate(-50%, -50%)',
        }}
      >
        {/* Contenido de watermark */}
        {mode === 'AUTO' && (
          <div className="text-white text-sm font-medium bg-black/50 px-2 py-1 rounded">
            Marca de agua
          </div>
        )}
        {mode === 'CUSTOM_TEXT' && text && (
          <div className="text-white text-sm font-medium bg-black/50 px-2 py-1 rounded">
            {text}
          </div>
        )}
        {mode === 'CUSTOM_IMAGE' && imagePreviewUrl && (
          <img 
            src={imagePreviewUrl} 
            alt="Watermark" 
            className="max-w-[100px] max-h-[100px] object-contain"
          />
        )}
      </div>
      
      {/* Opciones de confirmación usando OverlayOptionsRow estándar */}
      <div
        className="absolute z-20"
        style={{
          bottom: '30px',
          left: '50%',
          transform: 'translateX(-50%)',
          width: 'calc(100% - 32px)', // Ancho igual al DialButton (con padding del contenedor padre)
        }}
      >
        <OverlayBox>
          <OverlayOptionsRow
            title="Confirmación"
            mode="text"
            options={[
              { id: 'confirm', label: 'Listo' },
              { id: 'cancel', label: 'Cancelar' },
            ]}
            onSelect={(id) => {
              if (id === 'confirm') {
                onConfirm();
              } else {
                onCancel();
              }
            }}
            color="white"
          />
        </OverlayBox>
      </div>
    </>
  );
}
