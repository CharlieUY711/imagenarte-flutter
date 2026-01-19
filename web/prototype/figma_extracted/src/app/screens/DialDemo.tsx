import React, { useState, useRef, useEffect } from 'react';
import { ArrowLeft, Save, Undo, SquareDashed, Pointer, Image as ImageIcon, Video, Scissors, ChevronLeft, ChevronRight, RectangleVertical, Square, RectangleHorizontal, Circle, ChevronDown, Settings, X } from 'lucide-react';
import { DialButton } from '@/app/components/DialButton';
import { initialClassicAdjustments } from '@/app/components/ClassicAdjustments';
import { CropOverlay } from '@/app/components/CropOverlay';
import { EditorMainMenu } from '@/app/components/EditorMainMenu';
import { ColorPresetsOverlay, type ColorPreset } from '@/app/components/ColorPresetsOverlay';
import { AdjustmentsOverlay, type AdjustmentType } from '@/app/components/AdjustmentsOverlay';
import { OverlayDial } from '@/app/components/OverlayDial';
import { PrivacyButton } from '@/app/components/PrivacyButton';
import { IncludeExcludeOverlay } from '@/app/components/IncludeExcludeOverlay';
import { ToggleButton } from '@/app/components/ToggleButton';
import { WatermarkOverlay } from '@/app/components/WatermarkOverlay';
import { OverlayOptionsRow, OverlayOption } from '@/app/components/OverlayOptionsRow';
import { OverlayBox } from '@/app/components/OverlayBox';
import { FreeSelectionOverlay } from '@/app/components/FreeSelectionOverlay';
import { FacePixelatePreviewOverlay } from '@/app/components/FacePixelatePreviewOverlay';
import { SelectionMaskOverlay } from '@/app/components/SelectionMaskOverlay';
import { ScissorsDecisionOverlay } from '@/app/components/ScissorsDecisionOverlay';

interface DialDemoProps {
  imageUrl?: string;
  onImageSelect: (file: File) => void;
  onVideoSelect: (file: File) => void;
  onBack: () => void;
}

type ToolMode = 'select' | 'pointer' | 'undo' | null;
type ActiveControl = 'pixelate' | 'blur' | 'crop' | 'removeMetadata' | 'watermark' | 'dimension' | 'adjustments' | null;

export function DialDemo({ imageUrl, onImageSelect, onVideoSelect, onBack }: DialDemoProps) {
  // DialButton individual states
  const [pixelateValue, setPixelateValue] = useState(0);
  const [blurValue, setBlurValue] = useState(0);
  const [cropValue, setCropValue] = useState(0);

  // ClassicAdjustments state
  const [classicAdjustments, setClassicAdjustments] = useState(initialClassicAdjustments);

  // DimensionButton state
  const [selectedDimension, setSelectedDimension] = useState<'vertical' | 'square' | 'landscape' | 'circular' | null>(null);
  const [dimensionPixels, setDimensionPixels] = useState(800);
  
  // Estado para controlar si el overlay de crop está visible (independiente de selectedDimension)
  const [showCropOverlay, setShowCropOverlay] = useState(false);
  
  
  // Estado para mostrar opciones de dimensiones flotantes
  const [showDimensionOptions, setShowDimensionOptions] = useState(false);
  
  // Estado para mostrar opciones de formato de archivo
  const [showFormatOptions, setShowFormatOptions] = useState(false);
  
  // Estados para mostrar diales de definición y tamaño
  const [showDefinitionDial, setShowDefinitionDial] = useState(false);
  const [showSizeDial, setShowSizeDial] = useState(false);
  
  // Estado para el formato de archivo seleccionado
  const [selectedFormat, setSelectedFormat] = useState<string>('jpg');
  

  // ColorModeButton state - detectar automáticamente el modo de color
  const [selectedColorMode, setSelectedColorMode] = useState<'color' | 'grayscale' | 'sepia' | 'bw' | null>('color');
  
  // Función helper para obtener el filtro CSS según el modo de color
  const getColorFilterCSS = (mode: 'color' | 'grayscale' | 'sepia' | 'bw' | null): string => {
    switch (mode) {
      case 'grayscale':
        return 'grayscale(1)';
      case 'sepia':
        return 'sepia(1)';
      case 'bw':
        return 'grayscale(1) contrast(1.35)';
      case 'color':
      default:
        return 'none';
    }
  };

  // Función helper para generar el filtro CSS de ajustes
  // Nota: classicAdjustments usa 0..100 donde 50 es neutral
  // Convertimos a -100..+100 donde 0 es neutral para los cálculos CSS
  const getAdjustmentsFilterCSS = (adjustments: typeof classicAdjustments): string => {
    const filters: string[] = [];
    
    // Brillo: dial 0..100 (50 = neutral) -> ajuste -100..+100 (0 = neutral)
    // CSS brightness: 0.0 (negro) a 2.0 (blanco), 1.0 es normal
    const brightnessValue = (adjustments.brightness - 50) * 2; // -100..+100
    const brightness = 1 + (brightnessValue / 100);
    if (brightness !== 1) {
      filters.push(`brightness(${brightness})`);
    }
    
    // Contraste: dial 0..100 (50 = neutral) -> ajuste -100..+100 (0 = neutral)
    // CSS contrast: 0.0 a infinito, 1.0 es normal
    const contrastValue = (adjustments.contrast - 50) * 2; // -100..+100
    const contrast = 1 + (contrastValue / 100);
    if (contrast !== 1) {
      filters.push(`contrast(${contrast})`);
    }
    
    // Saturación: dial 0..100 (50 = neutral) -> ajuste -100..+100 (0 = neutral)
    // CSS saturate: 0.0 (sin color) a infinito, 1.0 es normal
    const saturationValue = (adjustments.saturation - 50) * 2; // -100..+100
    const saturation = 1 + (saturationValue / 100);
    if (saturation !== 1) {
      filters.push(`saturate(${saturation})`);
    }
    
    // Nitidez: dial 0..100 (0 = sin efecto, 100 = máximo efecto)
    // Usar contrast aumentado para simular nitidez
    // Convertir: 0 = 1.0 (sin efecto), 100 = 1.5 (máxima nitidez)
    if (adjustments.sharpness > 0) {
      const sharpness = 1 + (adjustments.sharpness / 200); // 0..100 -> 1.0..1.5
      filters.push(`contrast(${sharpness})`);
    }
    
    return filters.length > 0 ? filters.join(' ') : 'none';
  };

  // Función helper para combinar filtros de color y ajustes
  const getCombinedFilterCSS = (): string => {
    const colorFilter = getColorFilterCSS(selectedColorMode);
    const adjustmentsFilter = getAdjustmentsFilterCSS(classicAdjustments);
    
    const filters: string[] = [];
    if (colorFilter !== 'none') filters.push(colorFilter);
    if (adjustmentsFilter !== 'none') filters.push(adjustmentsFilter);
    
    return filters.length > 0 ? filters.join(' ') : 'none';
  };
  
  // Función helper para aplicar filtro de color al canvas
  const applyColorFilterToCanvas = (
    ctx: CanvasRenderingContext2D,
    width: number,
    height: number,
    mode: 'color' | 'grayscale' | 'sepia' | 'bw' | null
  ): void => {
    if (!mode || mode === 'color') return;
    
    const imageData = ctx.getImageData(0, 0, width, height);
    const data = imageData.data;
    
    for (let i = 0; i < data.length; i += 4) {
      const r = data[i];
      const g = data[i + 1];
      const b = data[i + 2];
      
      let newR = r;
      let newG = g;
      let newB = b;
      
      if (mode === 'grayscale') {
        // Luminancia: 0.299*R + 0.587*G + 0.114*B
        const lum = 0.299 * r + 0.587 * g + 0.114 * b;
        newR = newG = newB = lum;
      } else if (mode === 'sepia') {
        // Sepia: matriz de transformación
        newR = Math.min(255, 0.393 * r + 0.769 * g + 0.189 * b);
        newG = Math.min(255, 0.349 * r + 0.686 * g + 0.168 * b);
        newB = Math.min(255, 0.272 * r + 0.534 * g + 0.131 * b);
      } else if (mode === 'bw') {
        // Blanco y negro (alto contraste): luminancia y threshold
        const lum = 0.299 * r + 0.587 * g + 0.114 * b;
        const threshold = 128;
        const value = lum >= threshold ? 255 : 0;
        newR = newG = newB = value;
      }
      
      data[i] = newR;
      data[i + 1] = newG;
      data[i + 2] = newB;
    }
    
    ctx.putImageData(imageData, 0, 0);
  };
  
  // Estado para almacenar el archivo y su información
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const [fileExtension, setFileExtension] = useState<string>('');
  const [fileName, setFileName] = useState<string>('');
  const [fileSize, setFileSize] = useState<number>(0);
  
  // Estado para las dimensiones reales de la imagen
  const [imageDimensions, setImageDimensions] = useState<{ width: number; height: number } | null>(null);
  
  // Estado para las dimensiones naturales de la imagen (para el crop)
  const [imageNaturalDimensions, setImageNaturalDimensions] = useState<{ width: number; height: number } | null>(null);
  
  // Estado para las dimensiones de la selección (crop)
  const [selectionDimensions, setSelectionDimensions] = useState<{ width: number; height: number } | null>(null);
  
  // Estado para saber si el crop ha sido confirmado
  const [cropConfirmed, setCropConfirmed] = useState(false);

  // Estado para el círculo (solo visual, sin transformación)
  const [circleShape, setCircleShape] = useState<{ x: number; y: number; width: number; height: number } | null>(null);
  
  // Estado para mostrar overlay INCLUDE/EXCLUDE antes del corte
  const [showIncludeExcludeOverlay, setShowIncludeExcludeOverlay] = useState(false);
  
  // Estado para mostrar overlay de tijera
  const [showScissorsOverlay, setShowScissorsOverlay] = useState(false);
  
  // Estado para indicar si la máscara está invertida
  const [maskInverted, setMaskInverted] = useState(false);

  // Estados para selección directa (QUAD + CIRCLE) con MOVE + RESIZE
  const [activeSelectionKind, setActiveSelectionKind] = useState<'quad' | 'circle' | null>(null);
  const [selectionVisible, setSelectionVisible] = useState(false);
  const [quad, setQuad] = useState<{ x: number; y: number; w: number; h: number } | null>(null);
  const [circle, setCircle] = useState<{ cx: number; cy: number; r: number } | null>(null);
  // Ratio actual del crop (para calcular quadTarget)
  const [currentCropRatio, setCurrentCropRatio] = useState<number | null>(null);
  const [drag, setDrag] = useState<{
    mode: 'move' | 'resize-edge' | 'resize-corner' | 'resize-circle';
    pointerId: number;
    startX: number;
    startY: number;
    startQuad: { x: number; y: number; w: number; h: number } | null;
    startCircle: { cx: number; cy: number; r: number } | null;
    edge?: 'l' | 'r' | 't' | 'b';
    corner?: 'tl' | 'tr' | 'bl' | 'br';
  } | null>(null);
  const [hover, setHover] = useState<{
    mode: 'move' | 'resize-edge' | 'resize-corner' | 'resize-circle' | null;
    edge?: 'l' | 'r' | 't' | 'b';
    corner?: 'tl' | 'tr' | 'bl' | 'br';
  }>({ mode: null });
  
  // Estado para almacenar la información de la versión confirmada
  const [confirmedVersionInfo, setConfirmedVersionInfo] = useState<{
    fileName: string;
    dimensions: { width: number; height: number };
    fileSize: number;
    dimensionType: 'vertical' | 'square' | 'landscape' | 'circular' | null;
    preset?: ColorPreset;
    adjustment?: { type: AdjustmentType; value: number };
    removeMetadata?: boolean;
    watermarkMode?: 'NONE' | 'AUTO' | 'CUSTOM_TEXT' | 'CUSTOM_IMAGE';
  } | null>(null);
  
  // Estado para manejar versiones y navegación
  const [currentVersionIndex, setCurrentVersionIndex] = useState<number>(-1); // -1 significa imagen original
  const [versions, setVersions] = useState<Array<{
    fileName: string;
    dimensions: { width: number; height: number };
    fileSize: number;
    dimensionType: 'vertical' | 'square' | 'landscape' | 'circular' | null;
    imageUrl: string; // URL de la imagen recortada
    preset?: ColorPreset;
    adjustment?: { type: AdjustmentType; value: number };
    removeMetadata?: boolean;
    watermarkMode?: 'NONE' | 'AUTO' | 'CUSTOM_TEXT' | 'CUSTOM_IMAGE';
  }>>([]);
  
  // Estados para overlays de Color Presets y Adjustments
  const [showColorPresetsOverlay, setShowColorPresetsOverlay] = useState(false);
  const [showAdjustmentsOverlay, setShowAdjustmentsOverlay] = useState(false);
  
  // Estado para el ajuste activo (cuando se selecciona un ajuste del overlay)
  const [activeAdjustment, setActiveAdjustment] = useState<AdjustmentType | null>(null);
  const [adjustmentValue, setAdjustmentValue] = useState<number>(50); // Valor inicial neutral
  
  // Estado para la URL de la imagen actual (puede ser original o una versión)
  const [currentImageUrl, setCurrentImageUrl] = useState<string | undefined>(imageUrl);

  // Tool mode state
  const [selectedTool, setSelectedTool] = useState<ToolMode>(null);

  // Estados de privacidad
  const [removeMetadata, setRemoveMetadata] = useState<boolean>(false);
  const [watermarkMode, setWatermarkMode] = useState<'NONE' | 'AUTO' | 'CUSTOM_TEXT' | 'CUSTOM_IMAGE'>('NONE');
  const [watermarkEnabled, setWatermarkEnabled] = useState<boolean>(false);
  const [watermarkVisible, setWatermarkVisible] = useState<boolean>(true);
  const [watermarkText, setWatermarkText] = useState<string>('');
  const [watermarkImageFile, setWatermarkImageFile] = useState<File | null>(null);
  const [watermarkTransform, setWatermarkTransform] = useState<{ x: number; y: number; rotation: number; scale: number }>({
    x: 50,
    y: 50,
    rotation: 0,
    scale: 1,
  });
  const [showWatermarkOverlay, setShowWatermarkOverlay] = useState(false);

  // Estados para el flujo de pixelado de rostro (según estándares)
  type PixelWizardStep = 'PICK_TYPE' | 'MANUAL_SELECT_TYPE' | 'MANUAL_SELECT' | 'DIAL' | 'ASK_MORE' | 'IDLE';
  const [pixelWizardStep, setPixelWizardStep] = useState<PixelWizardStep>('IDLE');
  const [pixelSelectionSource, setPixelSelectionSource] = useState<'AUTO' | 'MANUAL' | null>(null);
  const [manualSelectionType, setManualSelectionType] = useState<'select' | 'pointer' | null>(null); // 'select' = formas, 'pointer' = libre
  const [currentPixelRegion, setCurrentPixelRegion] = useState<{ x: number; y: number; width: number; height: number } | null>(null);
  const [pixelIntensity, setPixelIntensity] = useState(50); // 0-100
  const [detectedFaces, setDetectedFaces] = useState<Array<{ x: number; y: number; width: number; height: number }>>([]);
  const [pixelatedAreas, setPixelatedAreas] = useState<Array<{ x: number; y: number; width: number; height: number; intensity: number }>>([]);

  // Estados para el flujo de blur (idéntico a pixelado)
  type BlurWizardStep = 'PICK_TYPE' | 'MANUAL_SELECT_TYPE' | 'MANUAL_SELECT' | 'DIAL' | 'ASK_MORE' | 'IDLE';
  const [blurWizardStep, setBlurWizardStep] = useState<BlurWizardStep>('IDLE');
  const [blurSelectionSource, setBlurSelectionSource] = useState<'AUTO' | 'MANUAL' | null>(null);
  const [manualBlurSelectionType, setManualBlurSelectionType] = useState<'select' | 'pointer' | null>(null);
  const [currentBlurRegion, setCurrentBlurRegion] = useState<{ x: number; y: number; width: number; height: number } | null>(null);
  const [blurIntensity, setBlurIntensity] = useState(50); // 0-100
  const [detectedFacesForBlur, setDetectedFacesForBlur] = useState<Array<{ x: number; y: number; width: number; height: number }>>([]);
  const [blurredAreas, setBlurredAreas] = useState<Array<{ x: number; y: number; width: number; height: number; intensity: number }>>([]);

  // Estado para controlar modales de Ajustes y Ayuda
  const [openSheet, setOpenSheet] = useState<'settings' | 'help' | null>(null);

  // Componentes de modal (definidos aquí para tener acceso al scope)
  const SettingsModal = ({ onClose }: { onClose: () => void }) => {
    useEffect(() => {
      const handleEscape = (e: KeyboardEvent) => {
        if (e.key === 'Escape') {
          onClose();
        }
      };
      window.addEventListener('keydown', handleEscape);
      return () => window.removeEventListener('keydown', handleEscape);
    }, [onClose]);

    return (
      <div
        className="fixed inset-0 z-50 flex items-end justify-center"
        onClick={(e) => {
          if (e.target === e.currentTarget) {
            onClose();
          }
        }}
        style={{ pointerEvents: 'auto' }}
      >
        {/* Backdrop */}
        <div
          className="absolute inset-0 bg-black/50"
          onClick={onClose}
        />
        
        {/* Modal content */}
        <div
          className="relative w-full max-w-md bg-[#0B0B0D] rounded-t-[20px] max-h-[90vh] overflow-y-auto"
          onClick={(e) => e.stopPropagation()}
          style={{ pointerEvents: 'auto' }}
        >
          {/* Handle superior */}
          <div className="flex justify-center pt-3 pb-2">
            <div className="w-10 h-1 bg-white/30 rounded-full" />
          </div>

          {/* Contenido */}
          <div className="px-5 pb-6">
            <div className="flex justify-between items-center mb-6">
              <h2 className="text-2xl font-bold text-white">Ajustes</h2>
              <button
                onClick={onClose}
                className="text-gray-400 hover:text-white transition-colors"
              >
                <X className="w-6 h-6" />
              </button>
            </div>

            {/* Sección: Aplicación */}
            <div className="mb-6">
              <h3 className="text-base font-semibold text-white/90 mb-3">Aplicación</h3>
              <div className="space-y-2">
                <p className="text-sm text-white/75">Versión: MVP</p>
                <p className="text-sm text-white/75">Modo: Offline-first</p>
                <p className="text-sm text-white/75">Backend: No utiliza backend</p>
                <p className="text-sm text-white/75">Procesamiento: 100% local</p>
              </div>
            </div>

            {/* Sección: Exportación */}
            <div className="mb-6">
              <h3 className="text-base font-semibold text-white/90 mb-3">Exportación</h3>
              <div className="space-y-2">
                <p className="text-sm text-white/75">Formato: JPG / PNG</p>
                <p className="text-sm text-white/75">Calidad: (por defecto)</p>
              </div>
            </div>

            {/* Sección: Privacidad */}
            <div className="mb-6">
              <h3 className="text-base font-semibold text-white/90 mb-3">Privacidad</h3>
              <div className="space-y-2">
                <p className="text-sm text-white/75">Las imágenes y videos nunca salen del dispositivo</p>
                <p className="text-sm text-white/75">No se almacenan datos personales</p>
              </div>
            </div>

            {/* Botón cerrar */}
            <div className="flex justify-center">
              <button
                onClick={onClose}
                className="px-4 py-2 text-sm text-gray-400 hover:text-white transition-colors"
              >
                Cerrar
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  };

  const HelpModal = ({ onClose }: { onClose: () => void }) => {
    useEffect(() => {
      const handleEscape = (e: KeyboardEvent) => {
        if (e.key === 'Escape') {
          onClose();
        }
      };
      window.addEventListener('keydown', handleEscape);
      return () => window.removeEventListener('keydown', handleEscape);
    }, [onClose]);

    return (
      <div
        className="fixed inset-0 z-50 flex items-end justify-center"
        onClick={(e) => {
          if (e.target === e.currentTarget) {
            onClose();
          }
        }}
        style={{ pointerEvents: 'auto' }}
      >
        {/* Backdrop */}
        <div
          className="absolute inset-0 bg-black/50"
          onClick={onClose}
        />
        
        {/* Modal content */}
        <div
          className="relative w-full max-w-md bg-[#0B0B0D] rounded-t-[20px] max-h-[90vh] overflow-y-auto"
          onClick={(e) => e.stopPropagation()}
          style={{ pointerEvents: 'auto' }}
        >
          {/* Handle superior */}
          <div className="flex justify-center pt-3 pb-2">
            <div className="w-10 h-1 bg-white/30 rounded-full" />
          </div>

          {/* Contenido */}
          <div className="px-5 pb-6">
            <div className="flex justify-between items-center mb-6">
              <h2 className="text-2xl font-bold text-white">Ayuda</h2>
              <button
                onClick={onClose}
                className="text-gray-400 hover:text-white transition-colors"
              >
                <X className="w-6 h-6" />
              </button>
            </div>

            {/* Sección: ¿Qué hace Imagen@rte? */}
            <div className="mb-6">
              <h3 className="text-base font-semibold text-white/90 mb-3">¿Qué hace Imagen@rte?</h3>
              <p className="text-sm text-white/75 leading-relaxed">
                Herramienta offline para tratamiento, protección y preparación de imágenes y videos antes de publicar.
              </p>
            </div>

            {/* Sección: Flujo básico */}
            <div className="mb-6">
              <h3 className="text-base font-semibold text-white/90 mb-3">Flujo básico</h3>
              <div className="space-y-2">
                <p className="text-sm text-white/75 leading-relaxed">1. Seleccioná una imagen o video</p>
                <p className="text-sm text-white/75 leading-relaxed">2. Protegé zonas sensibles</p>
                <p className="text-sm text-white/75 leading-relaxed">3. Exportá el archivo tratado</p>
              </div>
            </div>

            {/* Sección: Privacidad */}
            <div className="mb-6">
              <h3 className="text-base font-semibold text-white/90 mb-3">Privacidad</h3>
              <p className="text-sm text-white/75 leading-relaxed">
                Todo el procesamiento se realiza localmente en tu dispositivo.
              </p>
            </div>

            {/* Botón cerrar */}
            <div className="flex justify-center">
              <button
                onClick={onClose}
                className="px-4 py-2 text-sm text-gray-400 hover:text-white transition-colors"
              >
                Cerrar
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  };

  // Sistema de historial para deshacer (mínimo 5 niveles)
  type HistoryState = {
    pixelateValue: number;
    blurValue: number;
    cropValue: number;
    classicAdjustments: typeof initialClassicAdjustments;
    selectedDimension: 'vertical' | 'square' | 'landscape' | 'circular' | null;
    dimensionPixels: number;
    showCropOverlay: boolean;
    cropConfirmed: boolean;
    selectionDimensions: { width: number; height: number } | null;
    selectedColorMode: 'color' | 'grayscale' | 'sepia' | 'bw' | null;
    versions: typeof versions;
    currentVersionIndex: number;
    removeMetadata: boolean;
    watermarkMode: 'NONE' | 'AUTO' | 'CUSTOM_TEXT' | 'CUSTOM_IMAGE';
    watermarkEnabled: boolean;
    watermarkVisible: boolean;
    watermarkText: string;
    watermarkTransform: { x: number; y: number; rotation: number; scale: number };
      pixelatedAreas: Array<{ x: number; y: number; width: number; height: number; intensity: number }>;
      pixelWizardStep: PixelWizardStep;
      pixelSelectionSource: 'AUTO' | 'MANUAL' | null;
      manualSelectionType: 'select' | 'pointer' | null;
      currentPixelRegion: { x: number; y: number; width: number; height: number } | null;
      pixelIntensity: number;
      blurredAreas: Array<{ x: number; y: number; width: number; height: number; intensity: number }>;
      blurWizardStep: BlurWizardStep;
      blurSelectionSource: 'AUTO' | 'MANUAL' | null;
      manualBlurSelectionType: 'select' | 'pointer' | null;
      currentBlurRegion: { x: number; y: number; width: number; height: number } | null;
      blurIntensity: number;
      // Estados de selección para la tijera
      activeSelectionKind: 'quad' | 'circle' | null;
      quad: { x: number; y: number; w: number; h: number } | null;
      circle: { cx: number; cy: number; r: number } | null;
      selectionVisible: boolean;
      maskInverted: boolean;
  };

  const [history, setHistory] = useState<HistoryState[]>([]);
  const [historyIndex, setHistoryIndex] = useState(-1);
  const MAX_HISTORY = 5; // Mínimo 5 niveles

  // Función para guardar el estado actual en el historial
  const saveToHistory = () => {
    const currentState: HistoryState = {
      pixelateValue,
      blurValue,
      cropValue,
      classicAdjustments: { ...classicAdjustments },
      selectedDimension,
      dimensionPixels,
      showCropOverlay,
      cropConfirmed,
      selectionDimensions: selectionDimensions ? { ...selectionDimensions } : null,
      selectedColorMode,
      versions: [...versions],
      currentVersionIndex,
      removeMetadata,
      watermarkMode,
      watermarkEnabled,
      watermarkVisible,
      watermarkText,
      watermarkTransform,
      pixelatedAreas: [...pixelatedAreas],
      pixelWizardStep,
      pixelSelectionSource,
      manualSelectionType,
      currentPixelRegion: currentPixelRegion ? { ...currentPixelRegion } : null,
      pixelIntensity,
      blurredAreas: [...blurredAreas],
      blurWizardStep,
      blurSelectionSource,
      manualBlurSelectionType,
      currentBlurRegion: currentBlurRegion ? { ...currentBlurRegion } : null,
      blurIntensity,
      activeSelectionKind,
      quad: quad ? { ...quad } : null,
      circle: circle ? { ...circle } : null,
      selectionVisible,
      maskInverted,
    };

    setHistory(prevHistory => {
      // Eliminar estados futuros si estamos en medio del historial
      const newHistory = prevHistory.slice(0, historyIndex + 1);
      
      // Agregar nuevo estado
      newHistory.push(currentState);
      
      // Limitar a MAX_HISTORY niveles
      if (newHistory.length > MAX_HISTORY) {
        newHistory.shift(); // Eliminar el más antiguo
        setHistoryIndex(MAX_HISTORY - 1);
      } else {
        setHistoryIndex(newHistory.length - 1);
      }
      
      return newHistory;
    });
  };

  // Función para deshacer
  const handleUndo = () => {
    if (historyIndex > 0) {
      const previousState = history[historyIndex - 1];
      setHistoryIndex(historyIndex - 1);
      
      // Restaurar estados
      setPixelateValue(previousState.pixelateValue);
      setBlurValue(previousState.blurValue);
      setCropValue(previousState.cropValue);
      setClassicAdjustments(previousState.classicAdjustments);
      setSelectedDimension(previousState.selectedDimension);
      setDimensionPixels(previousState.dimensionPixels);
      setShowCropOverlay(previousState.showCropOverlay);
      setCropConfirmed(previousState.cropConfirmed);
      setSelectionDimensions(previousState.selectionDimensions);
      setSelectedColorMode(previousState.selectedColorMode);
      setVersions(previousState.versions);
      setCurrentVersionIndex(previousState.currentVersionIndex);
      setRemoveMetadata(previousState.removeMetadata);
      setWatermarkMode(previousState.watermarkMode);
      setWatermarkEnabled(previousState.watermarkEnabled);
      setWatermarkVisible(previousState.watermarkVisible);
      setWatermarkText(previousState.watermarkText);
      setWatermarkTransform(previousState.watermarkTransform);
      setPixelatedAreas(previousState.pixelatedAreas);
      setPixelWizardStep(previousState.pixelWizardStep);
      setPixelSelectionSource(previousState.pixelSelectionSource);
      setManualSelectionType(previousState.manualSelectionType);
      setCurrentPixelRegion(previousState.currentPixelRegion);
      setPixelIntensity(previousState.pixelIntensity);
      setBlurredAreas(previousState.blurredAreas);
      setBlurWizardStep(previousState.blurWizardStep);
      setBlurSelectionSource(previousState.blurSelectionSource);
      setManualBlurSelectionType(previousState.manualBlurSelectionType);
      setCurrentBlurRegion(previousState.currentBlurRegion);
      setBlurIntensity(previousState.blurIntensity);
      setActiveSelectionKind(previousState.activeSelectionKind);
      setQuad(previousState.quad);
      setCircle(previousState.circle);
      setSelectionVisible(previousState.selectionVisible);
      setMaskInverted(previousState.maskInverted);
      
      // Actualizar URL de imagen si cambió la versión
      if (previousState.currentVersionIndex >= 0 && previousState.versions[previousState.currentVersionIndex]) {
        setCurrentImageUrl(previousState.versions[previousState.currentVersionIndex].imageUrl);
      } else {
        setCurrentImageUrl(imageUrl);
      }
    }
  };

  // Control activo - solo uno a la vez
  const [activeControl, setActiveControl] = useState<ActiveControl>(null);
  const closeTimeoutRef = useRef<number | null>(null);
  
  // Función para crear una versión soft de privacidad (sin cambio visual)
  const createPrivacyVersion = (newRemoveMetadata: boolean, newWatermarkMode: 'NONE' | 'AUTO' | 'CUSTOM_TEXT' | 'CUSTOM_IMAGE') => {
    if (!imageUrl || !imageDimensions) return;
    
    // Guardar en historial antes de crear versión
    saveToHistory();
    
    // Crear nombre de archivo con versión
    const versionNumber = versions.length + 1;
    const baseName = fileName ? fileName.replace(/\.[^/.]+$/, '') : 'imagen';
    const extension = fileName ? fileName.split('.').pop() : 'jpg';
    const newFileName = `${baseName}_V${String(versionNumber).padStart(3, '0')}.${extension}`;
    
    // Crear versión soft (misma imagen, solo metadata de privacidad)
    const newVersion = {
      fileName: newFileName,
      dimensions: imageDimensions,
      fileSize: fileSize,
      dimensionType: null,
      imageUrl: currentImageUrl || imageUrl, // Usar imagen actual
      removeMetadata: newRemoveMetadata,
      watermarkMode: newWatermarkMode,
    };
    
    const updatedVersions = [...versions, newVersion];
    setVersions(updatedVersions);
    setCurrentVersionIndex(updatedVersions.length - 1);
    setConfirmedVersionInfo(newVersion);
  };
  
  // Handler para cambiar estado de eliminar metadatos
  const handleRemoveMetadataChange = (checked: boolean) => {
    setRemoveMetadata(checked);
    createPrivacyVersion(checked, watermarkMode);
  };
  
  // Handler para completar el wizard de marca de agua
  const handleWatermarkComplete = (config: {
    mode: 'AUTO' | 'CUSTOM_TEXT' | 'CUSTOM_IMAGE';
    visible: boolean;
    text?: string;
    imageFile?: File | null;
    transform?: { x: number; y: number; rotation: number; scale: number };
  }) => {
    setWatermarkMode(config.mode);
    setWatermarkEnabled(true);
    setWatermarkVisible(config.visible);
    setWatermarkText(config.text || '');
    setWatermarkImageFile(config.imageFile || null);
    if (config.transform) {
      setWatermarkTransform(config.transform);
    }
    
    // Crear versión
    const versionMode = config.mode === 'AUTO' ? 'AUTO' : config.mode === 'CUSTOM_TEXT' ? 'CUSTOM_TEXT' : 'CUSTOM_IMAGE';
    createPrivacyVersion(removeMetadata, versionMode);
    
    // Cerrar overlay
    setShowWatermarkOverlay(false);
    setActiveControl(null);
  };
  
  // Función para crear una nueva versión con preset
  const createVersionWithPreset = (preset: ColorPreset) => {
    if (!imageUrl || !imageDimensions) return;
    
    // Crear nombre de archivo con versión
    const versionNumber = versions.length + 1;
    const baseName = fileName ? fileName.replace(/\.[^/.]+$/, '') : 'imagen';
    const extension = fileName ? fileName.split('.').pop() : 'jpg';
    const newFileName = `${baseName}_V${String(versionNumber).padStart(3, '0')}.${extension}`;
    
    // Por ahora, usar la misma URL (mock - no procesamiento real)
    const newVersion = {
      fileName: newFileName,
      dimensions: imageDimensions,
      fileSize: fileSize, // Mantener tamaño original por ahora
      dimensionType: null,
      imageUrl: imageUrl, // Mock: usar misma imagen
      preset: preset,
    };
    
    const updatedVersions = [...versions, newVersion];
    setVersions(updatedVersions);
    setCurrentVersionIndex(updatedVersions.length - 1);
    setConfirmedVersionInfo(newVersion);
    setCurrentImageUrl(imageUrl); // Mock: usar misma imagen
    setSelectedColorMode(preset);
    
    // Guardar en historial
    saveToHistory();
  };
  
  // Función para crear una nueva versión con ajuste
  const createVersionWithAdjustment = (type: AdjustmentType, value: number) => {
    if (!imageUrl || !imageDimensions) return;
    
    // Crear nombre de archivo con versión
    const versionNumber = versions.length + 1;
    const baseName = fileName ? fileName.replace(/\.[^/.]+$/, '') : 'imagen';
    const extension = fileName ? fileName.split('.').pop() : 'jpg';
    const newFileName = `${baseName}_V${String(versionNumber).padStart(3, '0')}.${extension}`;
    
    // Por ahora, usar la misma URL (mock - no procesamiento real)
    const newVersion = {
      fileName: newFileName,
      dimensions: imageDimensions,
      fileSize: fileSize, // Mantener tamaño original por ahora
      dimensionType: null,
      imageUrl: imageUrl, // Mock: usar misma imagen
      adjustment: { type, value },
    };
    
    const updatedVersions = [...versions, newVersion];
    setVersions(updatedVersions);
    setCurrentVersionIndex(updatedVersions.length - 1);
    setConfirmedVersionInfo(newVersion);
    setCurrentImageUrl(imageUrl); // Mock: usar misma imagen
    
    // Actualizar el valor del ajuste en classicAdjustments
    const adjustmentMap: Record<AdjustmentType, keyof typeof classicAdjustments> = {
      brightness: 'brightness',
      contrast: 'contrast',
      saturation: 'saturation',
      sharpness: 'sharpness',
    };
    setClassicAdjustments({
      ...classicAdjustments,
      [adjustmentMap[type]]: value,
    });
    
    // Guardar en historial
    saveToHistory();
    
    // Cerrar el dial
    setActiveAdjustment(null);
  };
  
  // Handlers para los overlays
  const handleColorPresetsClick = () => {
    // Cambiar de herramienta
    switchTool('adjustments'); // Color presets es parte de adjustments
    
    if (showColorPresetsOverlay) {
      setShowColorPresetsOverlay(false);
      setActiveControl(null); // Si se cierra, desactivar
    } else {
      setShowColorPresetsOverlay(true);
      setShowAdjustmentsOverlay(false); // Cerrar el otro overlay
    }
  };
  
  const handleAdjustmentsClick = () => {
    // Cambiar de herramienta
    switchTool('adjustments');
    
    if (showAdjustmentsOverlay) {
      setShowAdjustmentsOverlay(false);
      setActiveControl(null); // Si se cierra, desactivar
    } else {
      setShowAdjustmentsOverlay(true);
      setShowColorPresetsOverlay(false); // Cerrar el otro overlay
    }
  };
  
  const handlePresetSelect = (preset: ColorPreset) => {
    createVersionWithPreset(preset);
    setShowColorPresetsOverlay(false);
  };
  
  const handleAdjustmentSelect = (adjustment: AdjustmentType) => {
    setActiveAdjustment(adjustment);
    // Inicializar con el valor actual del ajuste si existe
    const adjustmentMap: Record<AdjustmentType, keyof typeof classicAdjustments> = {
      brightness: 'brightness',
      contrast: 'contrast',
      saturation: 'saturation',
      sharpness: 'sharpness',
    };
    setAdjustmentValue(classicAdjustments[adjustmentMap[adjustment]]);
    setShowAdjustmentsOverlay(false);
  };
  
  const handleAdjustmentConfirm = () => {
    if (activeAdjustment) {
      createVersionWithAdjustment(activeAdjustment, adjustmentValue);
    }
  };
  
  const handleAdjustmentCancel = () => {
    setActiveAdjustment(null);
  };

  // ========== FUNCIÓN DE RESET COMPLETO DE HERRAMIENTA ==========
  
  /**
   * Resetea COMPLETAMENTE la herramienta y todos sus estados relacionados.
   * Esta función es MANDATORIA cuando:
   * 1. Se presiona el botón de selección del menú principal
   * 2. Se selecciona una opción del overlay de dimensiones
   * 
   * Resetea TODOS los restos de funcionalidad anterior.
   */
  const resetToolCompletely = () => {
    // Cerrar TODOS los overlays activos
    setShowCropOverlay(false);
    setShowDimensionOptions(false);
    setShowColorPresetsOverlay(false);
    setShowAdjustmentsOverlay(false);
    setShowWatermarkOverlay(false);
    setShowIncludeExcludeOverlay(false);
    
    // Cerrar TODOS los diales
    setShowDefinitionDial(false);
    setShowSizeDial(false);
    setShowFormatOptions(false);
    setActiveAdjustment(null);
    
    // Resetear TODOS los estados de selección
    setSelectedDimension(null);
    setSelectionDimensions(null);
    setCropConfirmed(false);
    
    // Resetear estados de herramientas
    setSelectedTool(null);
    setActiveControl(null);
    
    // Resetear wizard de pixelado completamente
    setPixelWizardStep('IDLE');
    setPixelSelectionSource(null);
    setManualSelectionType(null);
    setCurrentPixelRegion(null);
    setDetectedFaces([]);
    setPixelatedAreas([]);
    setPixelIntensity(50);
    
    // Resetear wizard de blur completamente
    setBlurWizardStep('IDLE');
    setBlurSelectionSource(null);
    setManualBlurSelectionType(null);
    setCurrentBlurRegion(null);
    setDetectedFacesForBlur([]);
    setBlurredAreas([]);
    setBlurIntensity(50);
    
    // Resetear ajustes
    setAdjustmentValue(50);
  };

  // ========== FUNCIÓN DE RESET COMPLETO DE RESIZER ==========
  
  /**
   * Resetea COMPLETAMENTE la herramienta Resizer (pointer tool).
   * REGLA CANÓNICA: Cada vez que el usuario selecciona Resizer desde el menú principal,
   * SIEMPRE se debe reiniciar completamente la herramienta, incluso si ya estaba activa.
   * 
   * Esta función:
   * - Limpia toda la pantalla (overlays, selecciones, máscaras, handles)
   * - Resetea completamente el estado interno de Resizer
   * - Vacía cualquier stack de undo/redo asociado a la herramienta
   * - Elimina transforms activos (resize, scale, rotate, skew)
   * - Re-inicializa la herramienta desde cero con valores default
   * - Vuelve a cargar la imagen base y la UI inicial de Resizer
   * 
   * No debe persistir ningún estado previo entre selecciones consecutivas de la misma herramienta.
   */
  const resetResizerCompletely = () => {
    // Cerrar TODOS los overlays activos
    setShowCropOverlay(false);
    setShowDimensionOptions(false);
    setShowColorPresetsOverlay(false);
    setShowAdjustmentsOverlay(false);
    setShowWatermarkOverlay(false);
    setShowIncludeExcludeOverlay(false);
    setShowScissorsOverlay(false);
    
    // Cerrar TODOS los diales
    setShowDefinitionDial(false);
    setShowSizeDial(false);
    setShowFormatOptions(false);
    setActiveAdjustment(null);
    
    // Resetear TODOS los estados de selección y transformación de Resizer
    setActiveSelectionKind(null);
    setSelectionVisible(false);
    setQuad(null);
    setCircle(null);
    setCurrentCropRatio(null);
    setDrag(null);
    setHover({ mode: null });
    setCircleShape(null);
    
    // Resetear estados de selección relacionados
    setSelectedDimension(null);
    setSelectionDimensions(null);
    setCropConfirmed(false);
    
    // Resetear estados de herramientas (pero mantener pointer activo después del reset)
    // setSelectedTool(null); // NO resetear aquí, se establecerá después
    
    // Resetear wizard de pixelado completamente
    setPixelWizardStep('IDLE');
    setPixelSelectionSource(null);
    setManualSelectionType(null);
    setCurrentPixelRegion(null);
    setDetectedFaces([]);
    setPixelatedAreas([]);
    setPixelIntensity(50);
    
    // Resetear wizard de blur completamente
    setBlurWizardStep('IDLE');
    setBlurSelectionSource(null);
    setManualBlurSelectionType(null);
    setCurrentBlurRegion(null);
    setDetectedFacesForBlur([]);
    setBlurredAreas([]);
    setBlurIntensity(50);
    
    // Resetear ajustes
    setAdjustmentValue(50);
    
    // Resetear máscara invertida
    setMaskInverted(false);
  };

  // ========== FUNCIÓN DE LIMPIEZA DE UI TRANSITORIA ==========
  
  /**
   * Limpia TODO lo transitorio del tool anterior.
   * Invariante crítica: SOLO se llama al cambiar de herramienta (switchTool).
   * NO borra el estado confirmado (top info).
   */
  const cleanupTransientUI = () => {
    // Cerrar todos los overlays activos
    setShowCropOverlay(false);
    setShowDimensionOptions(false);
    setShowColorPresetsOverlay(false);
    setShowAdjustmentsOverlay(false);
    setShowWatermarkOverlay(false);
    setShowIncludeExcludeOverlay(false);
    
    // Cerrar todos los diales
    setShowDefinitionDial(false);
    setShowSizeDial(false);
    setShowFormatOptions(false);
    setActiveAdjustment(null);
    
    // Limpiar selecciones provisionales y highlights temporales
    setSelectedTool(null);
    
    // Limpiar wizard de pixelado (siempre al cambiar de herramienta)
    setPixelWizardStep('IDLE');
    setPixelSelectionSource(null);
    setManualSelectionType(null);
    setCurrentPixelRegion(null);
    setDetectedFaces([]);
    
    // Limpiar wizard de blur (siempre al cambiar de herramienta)
    setBlurWizardStep('IDLE');
    setBlurSelectionSource(null);
    setManualBlurSelectionType(null);
    setCurrentBlurRegion(null);
    setDetectedFacesForBlur([]);
    
    // Limpiar barra blanca (working info) - esto se hace automáticamente al cerrar overlays
  };

  // ========== FUNCIÓN DE CAMBIO DE HERRAMIENTA ==========
  
  /**
   * Cambia de herramienta activa.
   * Esta es la ÚNICA función que puede llamar cleanupTransientUI().
   * Luego establece activeControl y resetea el wizardStep de la herramienta anterior.
   */
  const switchTool = (nextTool: ActiveControl) => {
    // Si ya está activa la misma herramienta, permitir toggle (cerrar si ya está abierta)
    if (activeControl === nextTool && nextTool !== null) {
      // Para pixelado: si está activo y en cualquier paso del wizard, cerrarlo
      if (nextTool === 'pixelate' && pixelWizardStep !== 'IDLE') {
        cleanupTransientUI();
        setActiveControl(null);
        return;
      }
      // Para blur: si está activo y en cualquier paso del wizard, cerrarlo
      if (nextTool === 'blur' && blurWizardStep !== 'IDLE') {
        cleanupTransientUI();
        setActiveControl(null);
        return;
      }
      // Para otras herramientas, mantener abiertas o cerrar según lógica específica
      // (por ahora, mantener abiertas)
      return;
    }
    
    // Ejecutar limpieza general (solo al cambiar de herramienta diferente)
    cleanupTransientUI();
    
    // Establecer nueva herramienta activa
    setActiveControl(nextTool);
  };

  // ========== FUNCIONES PARA PIXELADO DE ROSTRO ==========
  
  // Detección automática de rostros (mock)
  const detectFaces = (): Array<{ x: number; y: number; width: number; height: number }> => {
    if (!imageRef.current || !imageDimensions) return [];
    
    // Mock: detectar 1-2 rostros en posiciones típicas
    const faces: Array<{ x: number; y: number; width: number; height: number }> = [];
    
    // Rostro 1: centro-izquierda (típico en retratos)
    const face1Width = imageDimensions.width * 0.25;
    const face1Height = imageDimensions.height * 0.3;
    const face1X = imageDimensions.width * 0.35;
    const face1Y = imageDimensions.height * 0.15;
    
    faces.push({
      x: Math.round(face1X),
      y: Math.round(face1Y),
      width: Math.round(face1Width),
      height: Math.round(face1Height),
    });
    
    // Rostro 2: opcional, si la imagen es ancha
    if (imageDimensions.width > imageDimensions.height * 1.5) {
      const face2Width = imageDimensions.width * 0.2;
      const face2Height = imageDimensions.height * 0.25;
      const face2X = imageDimensions.width * 0.65;
      const face2Y = imageDimensions.height * 0.2;
      
      faces.push({
        x: Math.round(face2X),
        y: Math.round(face2Y),
        width: Math.round(face2Width),
        height: Math.round(face2Height),
      });
    }
    
    return faces;
  };

  // PASO 0 — Activación: Usuario presiona "Pixelado de rostro"
  const handlePixelateFaceClick = () => {
    // Cambiar de herramienta (esto ejecuta cleanup y establece activeControl)
    switchTool('pixelate');
    
    // Iniciar wizard (paso interno, NO llama cleanup)
    setPixelWizardStep('PICK_TYPE');
    setPixelSelectionSource(null);
    setCurrentPixelRegion(null);
    setDetectedFaces([]);
    setPixelIntensity(50); // Valor inicial
    
    // Ejecutar detección automática de rostros (mock OK)
    const faces = detectFaces();
    if (faces.length > 0) {
      setDetectedFaces(faces);
      // Mostrar selección automática con RECUADRO ROJO (indicativo/visual, no interactivo)
      // El recuadro se renderiza en el overlay FacePixelatePreviewOverlay
    }
    // Si no hay rostros detectados, el overlay PICK_TYPE permitirá selección manual
  };

  // PASO 1 — Decisión: Automática | Manual (OverlayOptionsRow)
  // NOTA: Este es un paso INTERNO del wizard, NO llama cleanup
  const handlePixelTypeSelect = (id: string) => {
    console.log('[PIXEL] choose', id, { 
      pixelWizardStep, 
      detectedFacesCount: detectedFaces.length,
      activeControl 
    });
    
    if (id === 'auto') {
      // Usuario eligió Automática
      // NO cleanup - solo avanzar paso interno
      if (detectedFaces.length > 0) {
        // Usar el primer rostro detectado (o el más grande)
        const selectedFace = detectedFaces.reduce((largest, face) => 
          (face.width * face.height) > (largest.width * largest.height) ? face : largest
        );
        setCurrentPixelRegion(selectedFace);
        setPixelSelectionSource('AUTO');
        setPixelWizardStep('DIAL'); // Avanzar a dial (mantiene recuadro rojo)
        console.log('[PIXEL] set to DIAL', { 
          pixelWizardStep: 'DIAL',
          currentPixelRegion: selectedFace,
          pixelSelectionSource: 'AUTO'
        });
      } else {
        console.warn('[PIXEL] No faces detected, cannot proceed with AUTO');
      }
    } else if (id === 'manual') {
      // Usuario eligió Manual
      // NO cleanup - solo avanzar paso interno
      setPixelSelectionSource('MANUAL');
      setPixelWizardStep('MANUAL_SELECT_TYPE'); // Nuevo paso: elegir tipo de selección
      setManualSelectionType(null);
      setDetectedFaces([]); // Limpiar detección automática (solo esta, no cleanup general)
      console.log('[PIXEL] set to MANUAL_SELECT_TYPE', { 
        pixelWizardStep: 'MANUAL_SELECT_TYPE',
        pixelSelectionSource: 'MANUAL'
      });
    }
  };

  // PASO 1.5 — Elegir tipo de selección manual: Selección (formas) | Libre (dedo)
  // NOTA: Este es un paso INTERNO del wizard, NO llama cleanup
  const handleManualSelectionTypeSelect = (id: string) => {
    console.log('[PIXEL] manual selection type', id);
    
    if (id === 'select') {
      // Usuario eligió Selección (formas/formatos)
      setManualSelectionType('select');
      setPixelWizardStep('MANUAL_SELECT');
      setSelectedTool('select'); // Activar herramienta de selección por formas
      // Mostrar overlay de selección por formas (CropOverlay se activará automáticamente)
      // Necesitamos establecer una dimensión por defecto si no hay una
      if (!selectedDimension && imageAspectRatio) {
        if (imageAspectRatio === 'vertical') {
          setSelectedDimension('vertical');
        } else if (imageAspectRatio === 'square') {
          setSelectedDimension('square');
        } else if (imageAspectRatio === 'landscape') {
          setSelectedDimension('landscape');
        }
      }
      // Si no hay dimensión, mostrar opciones de dimensiones
      if (!selectedDimension) {
        setShowDimensionOptions(true);
      } else {
        setShowCropOverlay(true);
      }
      console.log('[PIXEL] set to MANUAL_SELECT with select tool', { 
        pixelWizardStep: 'MANUAL_SELECT',
        manualSelectionType: 'select'
      });
    } else if (id === 'pointer') {
      // Usuario eligió Libre (dedo índice)
      setManualSelectionType('pointer');
      setPixelWizardStep('MANUAL_SELECT');
      setSelectedTool('pointer'); // Activar herramienta de selección libre
      console.log('[PIXEL] set to MANUAL_SELECT with pointer tool', { 
        pixelWizardStep: 'MANUAL_SELECT',
        manualSelectionType: 'pointer'
      });
    }
  };

  // Completar selección manual (desde FreeSelectionOverlay o CropOverlay)
  // NOTA: Este es un paso INTERNO del wizard, NO llama cleanup
  const handleManualSelectionComplete = (area: { x: number; y: number; width: number; height: number }) => {
    // NO cleanup - solo avanzar paso interno
    setCurrentPixelRegion(area);
    setPixelWizardStep('DIAL'); // Avanzar a dial
    setSelectedTool(null); // Desactivar herramienta (solo esta herramienta, no cleanup general)
    setShowCropOverlay(false); // Cerrar overlay de crop si estaba abierto
    setShowDimensionOptions(false); // Cerrar opciones de dimensiones si estaban abiertas
  };

  // PASO 2 — Aplicar pixelado definitivo (desde confirmación del dial)
  const applyPixelate = async () => {
    if (!currentPixelRegion || !imageDimensions) return;
    
    // Guardar snapshot antes de aplicar (Undo máx. 5)
    saveToHistory();
    
    try {
      // Cargar la imagen actual (puede ser original o una versión con pixelados previos)
      const imageToProcess = new Image();
      imageToProcess.crossOrigin = 'anonymous';
      
      await new Promise((resolve, reject) => {
        imageToProcess.onload = resolve;
        imageToProcess.onerror = reject;
        imageToProcess.src = currentImageUrl || imageUrl || '';
      });
      
      const canvas = document.createElement('canvas');
      const ctx = canvas.getContext('2d');
      if (!ctx) return;
      
      canvas.width = imageDimensions.width;
      canvas.height = imageDimensions.height;
      
      // Dibujar imagen actual (puede tener pixelados previos)
      ctx.drawImage(imageToProcess, 0, 0, canvas.width, canvas.height);
      
      // Aplicar pixelado a la zona seleccionada
      const pixelSize = Math.max(2, Math.round((pixelIntensity / 100) * 20)); // 2-20 píxeles según intensidad
      const area = currentPixelRegion;
      
      // Obtener datos de la zona
      const imageData = ctx.getImageData(area.x, area.y, area.width, area.height);
      const data = imageData.data;
      
      // Pixelar: agrupar píxeles en bloques
      for (let y = 0; y < area.height; y += pixelSize) {
        for (let x = 0; x < area.width; x += pixelSize) {
          // Calcular color promedio del bloque
          let r = 0, g = 0, b = 0, count = 0;
          
          for (let dy = 0; dy < pixelSize && (y + dy) < area.height; dy++) {
            for (let dx = 0; dx < pixelSize && (x + dx) < area.width; dx++) {
              const idx = ((y + dy) * area.width + (x + dx)) * 4;
              r += data[idx];
              g += data[idx + 1];
              b += data[idx + 2];
              count++;
            }
          }
          
          if (count > 0) {
            r = Math.round(r / count);
            g = Math.round(g / count);
            b = Math.round(b / count);
            
            // Rellenar el bloque con el color promedio
            ctx.fillStyle = `rgb(${r}, ${g}, ${b})`;
            ctx.fillRect(area.x + x, area.y + y, pixelSize, pixelSize);
          }
        }
      }
      
      // Convertir a blob y crear URL
      canvas.toBlob((blob) => {
        if (!blob) return;
        
        const url = URL.createObjectURL(blob);
        
        // Agregar área pixelada a la lista
        const newPixelatedArea = {
          ...currentPixelRegion,
          intensity: pixelIntensity,
        };
        setPixelatedAreas([...pixelatedAreas, newPixelatedArea]);
        
        // Crear nueva versión (cada confirmación de dial crea UNA versión)
        const versionNumber = versions.length + 1;
        const baseName = fileName ? fileName.replace(/\.[^/.]+$/, '') : 'imagen';
        const extension = fileName ? fileName.split('.').pop() : 'jpg';
        const newFileName = `${baseName}_V${String(versionNumber).padStart(3, '0')}.${extension}`;
        
        const newVersion = {
          fileName: newFileName,
          dimensions: imageDimensions,
          fileSize: fileSize, // Mantener tamaño similar
          dimensionType: null,
          imageUrl: url,
        };
        
        const updatedVersions = [...versions, newVersion];
        setVersions(updatedVersions);
        setCurrentVersionIndex(updatedVersions.length - 1);
        setCurrentImageUrl(url);
        
        // Pasar a ASK_MORE (¿Desea pixelar otra zona?)
        setPixelWizardStep('ASK_MORE');
      }, 'image/png');
    } catch (error) {
      console.error('Error al aplicar pixelado:', error);
      alert('Error al aplicar pixelado. Por favor, inténtalo de nuevo.');
    }
  };

  // PASO 3 — ASK_MORE: ¿Desea pixelar otra zona? (Sí | No)
  // NOTA: Este es un paso INTERNO del wizard, NO llama cleanup
  const handleAskMoreSelect = (id: string) => {
    if (id === 'yes') {
      // Reiniciar flujo desde PICK_TYPE (paso interno, NO cleanup)
      setPixelWizardStep('PICK_TYPE');
      setCurrentPixelRegion(null);
      setPixelSelectionSource(null);
      setManualSelectionType(null);
      
      // Detectar rostros nuevamente
      const faces = detectFaces();
      if (faces.length > 0) {
        setDetectedFaces(faces);
      } else {
        setDetectedFaces([]);
      }
      // activeControl se mantiene en 'pixelate' (botón sigue marcado)
    } else if (id === 'no') {
      // Finalizar herramienta (cerrar wizard pero mantener activeControl hasta cambiar de tool)
      setPixelWizardStep('IDLE');
      setCurrentPixelRegion(null);
      setPixelSelectionSource(null);
      setManualSelectionType(null);
      setDetectedFaces([]);
      setSelectedTool(null);
      // NO resetear activeControl aquí - se resetea solo al cambiar de herramienta
      // El botón puede quedar marcado hasta que el usuario cambie de tool
    }
  };

  // ========== FUNCIONES PARA BLUR (MIRROR DE PIXELADO) ==========
  
  // PASO 0 — Activación: Usuario presiona "Blur"
  const handleBlurClick = () => {
    // Cambiar de herramienta (esto ejecuta cleanup y establece activeControl)
    switchTool('blur');
    
    // Iniciar wizard (paso interno, NO llama cleanup)
    setBlurWizardStep('PICK_TYPE');
    setBlurSelectionSource(null);
    setCurrentBlurRegion(null);
    setDetectedFacesForBlur([]);
    setBlurIntensity(50); // Valor inicial
    
    // Ejecutar detección automática de rostros (mock OK)
    const faces = detectFaces();
    if (faces.length > 0) {
      setDetectedFacesForBlur(faces);
      // Mostrar selección automática con RECUADRO ROJO (indicativo/visual, no interactivo)
      // El recuadro se renderiza en el overlay FacePixelatePreviewOverlay (reutilizado)
    }
    // Si no hay rostros detectados, el overlay PICK_TYPE permitirá selección manual
  };

  // PASO 1 — Decisión: Automática | Manual (OverlayOptionsRow)
  const handleBlurTypeSelect = (id: string) => {
    console.log('[BLUR] choose', id, { 
      blurWizardStep, 
      detectedFacesCount: detectedFacesForBlur.length,
      activeControl 
    });
    
    if (id === 'auto') {
      // Usuario eligió Automática
      if (detectedFacesForBlur.length > 0) {
        const selectedFace = detectedFacesForBlur.reduce((largest, face) => 
          (face.width * face.height) > (largest.width * largest.height) ? face : largest
        );
        setCurrentBlurRegion(selectedFace);
        setBlurSelectionSource('AUTO');
        setBlurWizardStep('DIAL');
        console.log('[BLUR] set to DIAL', { 
          blurWizardStep: 'DIAL',
          currentBlurRegion: selectedFace,
          blurSelectionSource: 'AUTO'
        });
      } else {
        console.warn('[BLUR] No faces detected, cannot proceed with AUTO');
      }
    } else if (id === 'manual') {
      // Usuario eligió Manual
      setBlurSelectionSource('MANUAL');
      setBlurWizardStep('MANUAL_SELECT_TYPE');
      setManualBlurSelectionType(null);
      setDetectedFacesForBlur([]);
      console.log('[BLUR] set to MANUAL_SELECT_TYPE', { 
        blurWizardStep: 'MANUAL_SELECT_TYPE',
        blurSelectionSource: 'MANUAL'
      });
    }
  };

  // PASO 1.5 — Elegir tipo de selección manual: Selección (formas) | Libre (dedo)
  const handleManualBlurSelectionTypeSelect = (id: string) => {
    console.log('[BLUR] manual selection type', id);
    
    if (id === 'select') {
      setManualBlurSelectionType('select');
      setBlurWizardStep('MANUAL_SELECT');
      setSelectedTool('select');
      if (!selectedDimension && imageAspectRatio) {
        if (imageAspectRatio === 'vertical') {
          setSelectedDimension('vertical');
        } else if (imageAspectRatio === 'square') {
          setSelectedDimension('square');
        } else if (imageAspectRatio === 'landscape') {
          setSelectedDimension('landscape');
        }
      }
      if (!selectedDimension) {
        setShowDimensionOptions(true);
      } else {
        setShowCropOverlay(true);
      }
      console.log('[BLUR] set to MANUAL_SELECT with select tool', { 
        blurWizardStep: 'MANUAL_SELECT',
        manualBlurSelectionType: 'select'
      });
    } else if (id === 'pointer') {
      setManualBlurSelectionType('pointer');
      setBlurWizardStep('MANUAL_SELECT');
      setSelectedTool('pointer');
      console.log('[BLUR] set to MANUAL_SELECT with pointer tool', { 
        blurWizardStep: 'MANUAL_SELECT',
        manualBlurSelectionType: 'pointer'
      });
    }
  };

  // Completar selección manual (desde FreeSelectionOverlay o CropOverlay)
  const handleManualBlurSelectionComplete = (area: { x: number; y: number; width: number; height: number }) => {
    setCurrentBlurRegion(area);
    setBlurWizardStep('DIAL');
    setSelectedTool(null);
    setShowCropOverlay(false);
    setShowDimensionOptions(false);
  };

  // PASO 2 — Aplicar blur definitivo (desde confirmación del dial)
  const applyBlur = async () => {
    if (!currentBlurRegion || !imageDimensions) return;
    
    // Guardar snapshot antes de aplicar (Undo máx. 5)
    saveToHistory();
    
    try {
      // Cargar la imagen actual (puede ser original o una versión con efectos previos)
      const imageToProcess = new Image();
      imageToProcess.crossOrigin = 'anonymous';
      
      await new Promise((resolve, reject) => {
        imageToProcess.onload = resolve;
        imageToProcess.onerror = reject;
        imageToProcess.src = currentImageUrl || imageUrl || '';
      });
      
      const canvas = document.createElement('canvas');
      const ctx = canvas.getContext('2d');
      if (!ctx) return;
      
      canvas.width = imageDimensions.width;
      canvas.height = imageDimensions.height;
      
      // Dibujar imagen actual (puede tener efectos previos)
      ctx.drawImage(imageToProcess, 0, 0, canvas.width, canvas.height);
      
      // Aplicar blur a la zona seleccionada
      const blurRadius = Math.max(1, Math.round((blurIntensity / 100) * 20)); // 1-20 píxeles según intensidad
      const area = currentBlurRegion;
      
      // Crear un canvas temporal para aplicar blur solo en la región
      const tempCanvas = document.createElement('canvas');
      const tempCtx = tempCanvas.getContext('2d');
      if (!tempCtx) return;
      
      tempCanvas.width = area.width;
      tempCanvas.height = area.height;
      
      // Dibujar solo la región seleccionada en el canvas temporal (sin blur)
      tempCtx.drawImage(
        imageToProcess,
        area.x, area.y, area.width, area.height,
        0, 0, area.width, area.height
      );
      
      // Crear otro canvas para aplicar el blur
      const blurCanvas = document.createElement('canvas');
      const blurCtx = blurCanvas.getContext('2d');
      if (!blurCtx) return;
      
      blurCanvas.width = area.width;
      blurCanvas.height = area.height;
      
      // Aplicar blur usando el filtro de canvas
      blurCtx.filter = `blur(${blurRadius}px)`;
      blurCtx.drawImage(tempCanvas, 0, 0);
      blurCtx.filter = 'none';
      
      // Dibujar la región blurreada de vuelta en la posición original del canvas principal
      ctx.drawImage(blurCanvas, area.x, area.y);
      
      // Convertir a blob y crear URL
      canvas.toBlob((blob) => {
        if (!blob) return;
        
        const url = URL.createObjectURL(blob);
        
        // Agregar área blurreada a la lista
        const newBlurredArea = {
          ...currentBlurRegion,
          intensity: blurIntensity,
        };
        setBlurredAreas([...blurredAreas, newBlurredArea]);
        
        // Crear nueva versión (cada confirmación de dial crea UNA versión)
        const versionNumber = versions.length + 1;
        const baseName = fileName ? fileName.replace(/\.[^/.]+$/, '') : 'imagen';
        const extension = fileName ? fileName.split('.').pop() : 'jpg';
        const newFileName = `${baseName}_V${String(versionNumber).padStart(3, '0')}.${extension}`;
        
        const newVersion = {
          fileName: newFileName,
          dimensions: imageDimensions,
          fileSize: fileSize,
          dimensionType: null,
          imageUrl: url,
        };
        
        const updatedVersions = [...versions, newVersion];
        setVersions(updatedVersions);
        setCurrentVersionIndex(updatedVersions.length - 1);
        setCurrentImageUrl(url);
        
        // Pasar a ASK_MORE (¿Desea blurrear otra zona?)
        setBlurWizardStep('ASK_MORE');
      }, 'image/png');
    } catch (error) {
      console.error('Error al aplicar blur:', error);
      alert('Error al aplicar blur. Por favor, inténtalo de nuevo.');
    }
  };

  // PASO 3 — ASK_MORE: ¿Desea blurrear otra zona? (Sí | No)
  const handleBlurAskMoreSelect = (id: string) => {
    if (id === 'yes') {
      // Reiniciar flujo desde PICK_TYPE
      setBlurWizardStep('PICK_TYPE');
      setCurrentBlurRegion(null);
      setBlurSelectionSource(null);
      setManualBlurSelectionType(null);
      
      // Detectar rostros nuevamente
      const faces = detectFaces();
      if (faces.length > 0) {
        setDetectedFacesForBlur(faces);
      } else {
        setDetectedFacesForBlur([]);
      }
    } else if (id === 'no') {
      // Finalizar herramienta
      setBlurWizardStep('IDLE');
      setCurrentBlurRegion(null);
      setBlurSelectionSource(null);
      setManualBlurSelectionType(null);
      setDetectedFacesForBlur([]);
      setSelectedTool(null);
    }
  };

  // ========== FUNCIONES PARA SELECCIÓN DIRECTA (QUAD + CIRCLE) ==========
  
  // DEBUG flag para logs temporales
  const DEBUG = true;
  
  // Funciones helper para blend determinista
  const lerp = (a: number, b: number, t: number): number => {
    return a + (b - a) * t;
  };

  const lerpRect = (
    u: { x: number; y: number; w: number; h: number },
    tg: { x: number; y: number; w: number; h: number },
    t: number
  ): { x: number; y: number; w: number; h: number } => {
    return {
      x: lerp(u.x, tg.x, t),
      y: lerp(u.y, tg.y, t),
      w: lerp(u.w, tg.w, t),
      h: lerp(u.h, tg.h, t),
    };
  };

  // Calcular quadTarget (encuadre forzado al formato, centrado y canónico)
  const calculateQuadTarget = (ratio: number): { x: number; y: number; w: number; h: number } | null => {
    if (!containerRef.current || containerSize.width === 0 || containerSize.height === 0) return null;
    
    const W = containerSize.width;
    const H = containerSize.height;
    const targetSize = Math.min(W, H) * 0.60;
    
    let w: number, h: number;
    
    if (ratio >= 1) {
      // Ancho >= alto
      w = Math.min(targetSize, W * 0.9);
      h = w / ratio;
      if (h > H * 0.9) {
        h = H * 0.9;
        w = h * ratio;
      }
    } else {
      // Alto > ancho
      h = Math.min(targetSize, H * 0.9);
      w = h * ratio;
      if (w > W * 0.9) {
        w = W * 0.9;
        h = w / ratio;
      }
    }
    
    const x = (W - w) / 2;
    const y = (H - h) / 2;
    
    return { x, y, w, h };
  };

  // Crear selección QUAD centrada con ratio específico
  const createQuadSelection = (ratio: number) => {
    const target = calculateQuadTarget(ratio);
    if (!target) return;
    
    setQuad(target);
    setCurrentCropRatio(ratio);
    setActiveSelectionKind('quad');
    setSelectionVisible(true);
  };
  
  // Crear selección CIRCLE centrada
  const createCircleSelection = () => {
    if (!containerRef.current || containerSize.width === 0 || containerSize.height === 0) return;
    
    const W = containerSize.width;
    const H = containerSize.height;
    const cx = W / 2;
    const cy = H / 2;
    const r = Math.min(W, H) * 0.30;
    
    setCircle({ cx, cy, r });
    setActiveSelectionKind('circle');
    setSelectionVisible(true);
  };
  
  // Hit test para QUAD
  const hitTestQuad = (px: number, py: number, quad: { x: number; y: number; w: number; h: number }): {
    mode: 'move' | 'resize-edge' | 'resize-corner' | null;
    edge?: 'l' | 'r' | 't' | 'b';
    corner?: 'tl' | 'tr' | 'bl' | 'br';
  } => {
    const T = 12; // Tolerancia en píxeles
    const { x, y, w, h } = quad;
    
    // Dentro del rectángulo
    const inside = px >= x && px <= x + w && py >= y && py <= y + h;
    
    // Esquinas (prioridad 1)
    const distTL = Math.hypot(px - x, py - y);
    const distTR = Math.hypot(px - (x + w), py - y);
    const distBL = Math.hypot(px - x, py - (y + h));
    const distBR = Math.hypot(px - (x + w), py - (y + h));
    const cornerTolerance = T * 1.6;
    
    if (distTL <= cornerTolerance) return { mode: 'resize-corner', corner: 'tl' };
    if (distTR <= cornerTolerance) return { mode: 'resize-corner', corner: 'tr' };
    if (distBL <= cornerTolerance) return { mode: 'resize-corner', corner: 'bl' };
    if (distBR <= cornerTolerance) return { mode: 'resize-corner', corner: 'br' };
    
    // Bordes (prioridad 2)
    const nearLeft = Math.abs(px - x) <= T && py >= y - T && py <= y + h + T;
    const nearRight = Math.abs(px - (x + w)) <= T && py >= y - T && py <= y + h + T;
    const nearTop = Math.abs(py - y) <= T && px >= x - T && px <= x + w + T;
    const nearBottom = Math.abs(py - (y + h)) <= T && px >= x - T && px <= x + w + T;
    
    if (nearLeft) return { mode: 'resize-edge', edge: 'l' };
    if (nearRight) return { mode: 'resize-edge', edge: 'r' };
    if (nearTop) return { mode: 'resize-edge', edge: 't' };
    if (nearBottom) return { mode: 'resize-edge', edge: 'b' };
    
    // Interior (prioridad 3)
    if (inside) return { mode: 'move' };
    
    return { mode: null };
  };
  
  // Hit test para CIRCLE
  const hitTestCircle = (px: number, py: number, circle: { cx: number; cy: number; r: number }): {
    mode: 'move' | 'resize-circle' | null;
  } => {
    const T = 12;
    const { cx, cy, r } = circle;
    const dist = Math.hypot(px - cx, py - cy);
    const nearEdge = Math.abs(dist - r) <= T;
    const inside = dist < r - T;
    
    if (nearEdge) return { mode: 'resize-circle' };
    if (inside) return { mode: 'move' };
    return { mode: null };
  };
  
  // Obtener coordenadas locales del pointer
  const getLocalPointerCoords = (e: React.PointerEvent): { x: number; y: number } | null => {
    if (!containerRef.current) return null;
    const rect = containerRef.current.getBoundingClientRect();
    return {
      x: e.clientX - rect.left,
      y: e.clientY - rect.top,
    };
  };
  
  // Handler onPointerDown
  const handlePointerDown = (e: React.PointerEvent) => {
    if (!selectionVisible || !containerRef.current) return;
    
    const coords = getLocalPointerCoords(e);
    if (!coords) return;
    
    DEBUG && console.log('[onPointerDown] tool=selection', {
      kind: activeSelectionKind,
      localX: coords.x,
      localY: coords.y,
    });
    
    let hitResult: { mode: 'move' | 'resize-edge' | 'resize-corner' | 'resize-circle' | null; edge?: 'l' | 'r' | 't' | 'b'; corner?: 'tl' | 'tr' | 'bl' | 'br' } = { mode: null };
    
    if (activeSelectionKind === 'quad' && quad) {
      hitResult = hitTestQuad(coords.x, coords.y, quad);
      DEBUG && console.log('[onPointerDown] hitTestQuad result:', hitResult, 'quad:', quad);
    } else if (activeSelectionKind === 'circle' && circle) {
      hitResult = hitTestCircle(coords.x, coords.y, circle);
      DEBUG && console.log('[onPointerDown] hitTestCircle result:', hitResult, 'circle:', circle);
    }
    
    if (!hitResult.mode) {
      DEBUG && console.log('[onPointerDown] no hit, returning');
      return;
    }
    
    // Crear snapshot del drag
    const dragSnapshot = {
      mode: hitResult.mode,
      pointerId: e.pointerId,
      startX: coords.x,
      startY: coords.y,
      startQuad: quad ? { ...quad } : null,
      startCircle: circle ? { ...circle } : null,
      edge: hitResult.edge,
      corner: hitResult.corner,
    };
    
    DEBUG && console.log('[onPointerDown] drag.mode set to:', dragSnapshot.mode, {
      edge: dragSnapshot.edge,
      corner: dragSnapshot.corner,
      startQuad: dragSnapshot.startQuad,
      startCircle: dragSnapshot.startCircle,
    });
    
    setDrag(dragSnapshot);
    
    e.currentTarget.setPointerCapture(e.pointerId);
    e.preventDefault();
  };
  
  // Handler onPointerMove
  const handlePointerMove = (e: React.PointerEvent) => {
    if (!containerRef.current) return;
    
    const coords = getLocalPointerCoords(e);
    if (!coords) return;
    
    if (!drag) {
      // Actualizar hover
      if (activeSelectionKind === 'quad' && quad) {
        const hitResult = hitTestQuad(coords.x, coords.y, quad);
        setHover({
          mode: hitResult.mode,
          edge: hitResult.edge,
          corner: hitResult.corner,
        });
      } else if (activeSelectionKind === 'circle' && circle) {
        const hitResult = hitTestCircle(coords.x, coords.y, circle);
        setHover({ mode: hitResult.mode });
      }
      return;
    }
    
    // Durante drag - LOGS OBLIGATORIOS
    const dx = coords.x - drag.startX;
    const dy = coords.y - drag.startY;
    const MIN_SIZE = 60;
    const MIN_RADIUS = 40;
    
    DEBUG && console.log('[onPointerMove] drag active', {
      mode: drag.mode,
      dx,
      dy,
      localX: coords.x,
      localY: coords.y,
    });
    
    if (drag.mode === 'move') {
      if (activeSelectionKind === 'quad' && drag.startQuad) {
        const newX = drag.startQuad.x + dx;
        const newY = drag.startQuad.y + dy;
        const next = { ...drag.startQuad, x: newX, y: newY };
        DEBUG && console.log('[onPointerMove] QUAD move', {
          prev: drag.startQuad,
          next,
        });
        setQuad(prev => {
          DEBUG && console.log('[onPointerMove] setQuad result:', next);
          return next;
        });
      } else if (activeSelectionKind === 'circle' && drag.startCircle) {
        const newCx = drag.startCircle.cx + dx;
        const newCy = drag.startCircle.cy + dy;
        const next = { ...drag.startCircle, cx: newCx, cy: newCy };
        DEBUG && console.log('[onPointerMove] CIRCLE move', {
          prev: drag.startCircle,
          next,
        });
        setCircle(prev => {
          DEBUG && console.log('[onPointerMove] setCircle result:', next);
          return next;
        });
      }
    } else if (drag.mode === 'resize-edge' && activeSelectionKind === 'quad' && drag.startQuad && drag.edge) {
      // Resize NO proporcional por borde
      let newQuad = { ...drag.startQuad };
      
      if (drag.edge === 'l') {
        newQuad.x = drag.startQuad.x + dx;
        newQuad.w = drag.startQuad.w - dx;
        if (newQuad.w < MIN_SIZE) {
          newQuad.w = MIN_SIZE;
          newQuad.x = drag.startQuad.x + drag.startQuad.w - MIN_SIZE;
        }
      } else if (drag.edge === 'r') {
        newQuad.w = drag.startQuad.w + dx;
        if (newQuad.w < MIN_SIZE) newQuad.w = MIN_SIZE;
      } else if (drag.edge === 't') {
        newQuad.y = drag.startQuad.y + dy;
        newQuad.h = drag.startQuad.h - dy;
        if (newQuad.h < MIN_SIZE) {
          newQuad.h = MIN_SIZE;
          newQuad.y = drag.startQuad.y + drag.startQuad.h - MIN_SIZE;
        }
      } else if (drag.edge === 'b') {
        newQuad.h = drag.startQuad.h + dy;
        if (newQuad.h < MIN_SIZE) newQuad.h = MIN_SIZE;
      }
      
      DEBUG && console.log('[onPointerMove] QUAD resize-edge', {
        edge: drag.edge,
        prev: drag.startQuad,
        next: newQuad,
      });
      
      setQuad(prev => {
        DEBUG && console.log('[onPointerMove] setQuad result:', newQuad);
        return newQuad;
      });
    } else if (drag.mode === 'resize-corner' && activeSelectionKind === 'quad' && drag.startQuad && drag.corner) {
      // Resize proporcional por esquina
      const ratio = drag.startQuad.w / drag.startQuad.h;
      let newQuad = { ...drag.startQuad };
      
      // Determinar driver según esquina
      if (drag.corner === 'tr' || drag.corner === 'br') {
        // Esquina derecha: usar dx como driver
        newQuad.w = drag.startQuad.w + dx;
        newQuad.h = newQuad.w / ratio;
      } else {
        // Esquina izquierda: usar -dx como driver
        newQuad.w = drag.startQuad.w - dx;
        newQuad.h = newQuad.w / ratio;
        newQuad.x = drag.startQuad.x + dx;
      }
      
      // Ajustar y según esquina superior/inferior
      if (drag.corner === 'tl' || drag.corner === 'tr') {
        // Esquinas superiores
        newQuad.y = drag.startQuad.y + (drag.startQuad.h - newQuad.h);
      } else {
        // Esquinas inferiores
        newQuad.y = drag.startQuad.y;
      }
      
      // Clamp mínimo
      if (newQuad.w < MIN_SIZE) {
        newQuad.w = MIN_SIZE;
        newQuad.h = newQuad.w / ratio;
        if (drag.corner === 'tl' || drag.corner === 'tr') {
          newQuad.y = drag.startQuad.y + (drag.startQuad.h - newQuad.h);
        }
        if (drag.corner === 'tl' || drag.corner === 'bl') {
          newQuad.x = drag.startQuad.x + drag.startQuad.w - MIN_SIZE;
        }
      }
      if (newQuad.h < MIN_SIZE) {
        newQuad.h = MIN_SIZE;
        newQuad.w = newQuad.h * ratio;
        if (drag.corner === 'tl' || drag.corner === 'tr') {
          newQuad.y = drag.startQuad.y + (drag.startQuad.h - MIN_SIZE);
        }
        if (drag.corner === 'tl' || drag.corner === 'bl') {
          newQuad.x = drag.startQuad.x + drag.startQuad.w - newQuad.w;
        }
      }
      
      DEBUG && console.log('[onPointerMove] QUAD resize-corner', {
        corner: drag.corner,
        prev: drag.startQuad,
        next: newQuad,
      });
      
      setQuad(prev => {
        DEBUG && console.log('[onPointerMove] setQuad result:', newQuad);
        return newQuad;
      });
    } else if (drag.mode === 'resize-circle' && activeSelectionKind === 'circle' && drag.startCircle) {
      // Resize círculo (cambiar radio)
      const newR = Math.hypot(coords.x - drag.startCircle.cx, coords.y - drag.startCircle.cy);
      const clampedR = Math.max(MIN_RADIUS, newR);
      const next = { ...drag.startCircle, r: clampedR };
      
      DEBUG && console.log('[onPointerMove] CIRCLE resize', {
        prev: { r: drag.startCircle.r },
        next: { r: clampedR },
      });
      
      setCircle(prev => {
        DEBUG && console.log('[onPointerMove] setCircle result:', next);
        return next;
      });
    }
  };
  
  // Handler onPointerUp / onPointerCancel
  const handlePointerUp = (e: React.PointerEvent) => {
    if (drag && e.pointerId === drag.pointerId) {
      DEBUG && console.log('[onPointerUp] drag cleared', { mode: drag.mode });
      e.currentTarget.releasePointerCapture(e.pointerId);
      setDrag(null);
      
      // Recalcular hover
      const coords = getLocalPointerCoords(e);
      if (coords) {
        if (activeSelectionKind === 'quad' && quad) {
          const hitResult = hitTestQuad(coords.x, coords.y, quad);
          setHover({
            mode: hitResult.mode,
            edge: hitResult.edge,
            corner: hitResult.corner,
          });
        } else if (activeSelectionKind === 'circle' && circle) {
          const hitResult = hitTestCircle(coords.x, coords.y, circle);
          setHover({ mode: hitResult.mode });
        }
      }
    }
  };
  
  const handlePointerCancel = (e: React.PointerEvent) => {
    if (drag && e.pointerId === drag.pointerId) {
      DEBUG && console.log('[onPointerCancel] drag cleared', { mode: drag.mode });
      e.currentTarget.releasePointerCapture(e.pointerId);
      setDrag(null);
      setHover({ mode: null });
    }
  };
  
  // Obtener cursor CSS según hover
  const getCursor = (): string => {
    if (!hover.mode) return 'default';
    
    if (hover.mode === 'move') return 'move';
    if (hover.mode === 'resize-circle') return 'nwse-resize';
    if (hover.mode === 'resize-edge') {
      if (hover.edge === 'l' || hover.edge === 'r') return 'ew-resize';
      return 'ns-resize';
    }
    if (hover.mode === 'resize-corner') {
      if (hover.corner === 'tl' || hover.corner === 'br') return 'nwse-resize';
      return 'nesw-resize';
    }
    return 'default';
  };

  // Auto-cerrar después de un delay
  const scheduleClose = () => {
    if (closeTimeoutRef.current) {
      clearTimeout(closeTimeoutRef.current);
    }
    closeTimeoutRef.current = window.setTimeout(() => {
      setActiveControl(null);
    }, 2000);
  };

  // Limpiar timeout al desmontar
  useEffect(() => {
    return () => {
      if (closeTimeoutRef.current) {
        clearTimeout(closeTimeoutRef.current);
      }
    };
  }, []);

  // Inicializar historial con el estado inicial cuando se carga la imagen
  useEffect(() => {
    if (imageUrl && history.length === 0) {
      const initialState: HistoryState = {
        pixelateValue: 0,
        blurValue: 0,
        cropValue: 0,
        classicAdjustments: initialClassicAdjustments,
        selectedDimension: null,
        dimensionPixels: 800,
        showCropOverlay: false,
        cropConfirmed: false,
        selectionDimensions: null,
        selectedColorMode: 'color',
        versions: [],
        currentVersionIndex: -1,
        removeMetadata: false,
        watermarkMode: 'NONE',
        watermarkEnabled: false,
        watermarkVisible: true,
        watermarkText: '',
        watermarkTransform: { x: 50, y: 50, rotation: 0, scale: 1 },
        pixelatedAreas: [],
        pixelWizardStep: 'IDLE' as PixelWizardStep,
        pixelSelectionSource: null,
        manualSelectionType: null,
        currentPixelRegion: null,
        pixelIntensity: 50,
        blurredAreas: [],
        blurWizardStep: 'IDLE' as BlurWizardStep,
        blurSelectionSource: null,
        manualBlurSelectionType: null,
        currentBlurRegion: null,
        blurIntensity: 50,
        activeSelectionKind: null,
        quad: null,
        circle: null,
        selectionVisible: false,
        maskInverted: false,
      };
      setHistory([initialState]);
      setHistoryIndex(0);
    }
  }, [imageUrl]);

  // Dimensiones del contenedor de imagen
  const [containerSize, setContainerSize] = useState({ width: 0, height: 0 });
  const containerRef = useRef<HTMLDivElement>(null);

  // Color predominante de la imagen
  const [dominantColor, setDominantColor] = useState('rgb(30, 30, 30)');
  const imageRef = useRef<HTMLImageElement>(null);
  
  // Ref para el contenedor wrapper de la imagen
  const imageContainerRef = useRef<HTMLDivElement | null>(null);
  
  // Proporción de la imagen (para crop automático)
  const [imageAspectRatio, setImageAspectRatio] = useState<'vertical' | 'square' | 'landscape' | null>(null);

  // Refs para inputs de archivo
  const imageInputRef = useRef<HTMLInputElement>(null);
  const videoInputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    const imageToUse = currentImageUrl || imageUrl;
    if (containerRef.current && imageToUse) {
      const updateSize = () => {
        if (containerRef.current) {
          const width = containerRef.current.offsetWidth;
          const height = containerRef.current.offsetHeight;
          if (width > 0 && height > 0) {
            setContainerSize({
              width,
              height,
            });
          }
        }
      };
      updateSize();
      // Usar requestAnimationFrame para asegurar que se ejecute después del render
      requestAnimationFrame(updateSize);
      window.addEventListener('resize', updateSize);
      return () => window.removeEventListener('resize', updateSize);
    }
  }, [currentImageUrl, imageUrl]);

  // Extraer color predominante y detectar proporción de la imagen
  useEffect(() => {
    const imageToUse = currentImageUrl || imageUrl;
    if (imageRef.current && imageToUse) {
      // Esperar a que la imagen esté completamente cargada
      if (imageRef.current.complete) {
        extractDominantColor();
        detectImageAspectRatio();
      } else {
        imageRef.current.onload = () => {
          extractDominantColor();
          detectImageAspectRatio();
        };
      }
    }
  }, [currentImageUrl, imageUrl]);

  

  const detectImageAspectRatio = () => {
    if (!imageRef.current) return;
    
    const width = imageRef.current.naturalWidth || imageRef.current.width;
    const height = imageRef.current.naturalHeight || imageRef.current.height;
    const ratio = width / height;
    
    // Guardar dimensiones reales
    setImageDimensions({ width, height });
    
    console.log('Dimensiones de imagen detectadas:', { width, height, ratio });
    
    // Determinar proporción
    let aspectRatio: 'vertical' | 'square' | 'landscape';
    if (ratio < 0.95) {
      // Vertical (más alto que ancho, ej: 300x600)
      aspectRatio = 'vertical';
    } else if (ratio > 1.05) {
      // Horizontal (más ancho que alto, ej: 600x300)
      aspectRatio = 'landscape';
    } else {
      // Cuadrado (aproximadamente 1:1, ej: 600x600)
      aspectRatio = 'square';
    }
    
    setImageAspectRatio(aspectRatio);
    
    // NO establecer automáticamente la dimensión aquí, se establecerá cuando se active la herramienta
    
    // Calcular los píxeles basándose en la dimensión más grande de la imagen
    // Para vertical: usar height como referencia
    // Para landscape: usar width como referencia
    // Para square: usar cualquiera de las dos
    let referenceDimension: number;
    if (aspectRatio === 'vertical') {
      referenceDimension = height; // Ej: 600 para 300x600
    } else if (aspectRatio === 'landscape') {
      referenceDimension = width; // Ej: 600 para 600x300
    } else {
      referenceDimension = Math.max(width, height); // Ej: 600 para 600x600
    }
    
    // Redondear a múltiplos de 50 para valores más limpios
    const roundedPixels = Math.round(referenceDimension / 50) * 50;
    // Asegurar un rango razonable (200-2000)
    const finalPixels = Math.max(200, Math.min(2000, roundedPixels));
    
    console.log('Disposición y píxeles establecidos:', { aspectRatio, finalPixels });
    setDimensionPixels(finalPixels);
    
    // Detectar modo de color (por ahora asumimos color, pero se puede mejorar)
    // Por defecto es color, el usuario puede cambiarlo
    setSelectedColorMode('color');
  };

  const extractDominantColor = () => {
    if (!imageRef.current) return;

    const canvas = document.createElement('canvas');
    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    canvas.width = imageRef.current.width;
    canvas.height = imageRef.current.height;
    ctx.drawImage(imageRef.current, 0, 0, canvas.width, canvas.height);

    const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height);
    const data = imageData.data;

    let r = 0, g = 0, b = 0;
    const sampleSize = 10; // Muestrear cada 10 píxeles para performance

    for (let i = 0; i < data.length; i += 4 * sampleSize) {
      r += data[i];
      g += data[i + 1];
      b += data[i + 2];
    }

    const pixelCount = data.length / (4 * sampleSize);
    r = Math.floor(r / pixelCount);
    g = Math.floor(g / pixelCount);
    b = Math.floor(b / pixelCount);

    // Oscurecer un poco para fondo
    r = Math.floor(r * 0.3);
    g = Math.floor(g * 0.3);
    b = Math.floor(b * 0.3);

    setDominantColor(`rgb(${r}, ${g}, ${b})`);
  };

  const handleImageButtonClick = () => {
    imageInputRef.current?.click();
  };

  const handleVideoButtonClick = () => {
    videoInputRef.current?.click();
  };

  const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      setSelectedFile(file);
      // Extraer extensión del archivo
      const extension = file.name.split('.').pop()?.toLowerCase() || '';
      setFileExtension(extension);
      setFileName(file.name);
      setFileSize(file.size);
      // Establecer formato por defecto según la extensión
      if (extension === 'jpg' || extension === 'jpeg') {
        setSelectedFormat('jpg');
      } else if (extension === 'png') {
        setSelectedFormat('png');
      } else if (extension === 'webp') {
        setSelectedFormat('webp');
      } else {
        setSelectedFormat('jpg'); // Por defecto JPG
      }
      onImageSelect(file);
    }
  };
  
  // Función para formatear el tamaño del archivo
  const formatFileSize = (bytes: number): string => {
    if (bytes === 0) return '0 B';
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
  };
  
  // Función para estimar el tamaño del archivo después del crop
  const estimateCropFileSize = (): number => {
    if (!selectionDimensions || !imageDimensions || !fileSize) return 0;
    
    // Calcular relación de área (selección vs imagen original)
    const originalArea = imageDimensions.width * imageDimensions.height;
    const selectionArea = selectionDimensions.width * selectionDimensions.height;
    const areaRatio = selectionArea / originalArea;
    
    // Factor de compresión según el formato
    let formatFactor = 1;
    if (selectedFormat === 'jpg' || selectedFormat === 'jpeg') {
      formatFactor = 0.8; // JPEG tiene mejor compresión
    } else if (selectedFormat === 'png') {
      formatFactor = 1.2; // PNG suele ser más pesado
    } else if (selectedFormat === 'webp') {
      formatFactor = 0.7; // WebP tiene mejor compresión
    } else if (selectedFormat === 'pdf') {
      formatFactor = 1.5; // PDF puede ser más pesado
    }
    
    // Estimar tamaño basándose en la relación de área y formato
    return Math.round(fileSize * areaRatio * formatFactor);
  };
  
  // Función para actualizar la definición (cambiar una dimensión, mantener proporción)
  const updateDefinition = (newWidth: number) => {
    if (!selectionDimensions || !selectedDimension) return;
    
    // Limitar el rango
    const minSize = 50;
    const maxSize = imageDimensions ? Math.max(imageDimensions.width, imageDimensions.height) : 4000;
    const clampedWidth = Math.max(minSize, Math.min(maxSize, newWidth));
    
    let newHeight = clampedWidth;
    
    // Mantener proporción según el tipo de dimensión
    if (selectedDimension === 'vertical') {
      // Vertical: mantener proporción 3:4 (o la de la imagen si es vertical)
      const aspectRatio = imageDimensions ? imageDimensions.width / imageDimensions.height : 0.75;
      if (aspectRatio < 1) {
        newHeight = clampedWidth / aspectRatio;
      } else {
        newHeight = clampedWidth / 0.75; // 3:4 por defecto
      }
    } else if (selectedDimension === 'landscape') {
      // Landscape: mantener proporción 4:3
      newHeight = clampedWidth / 1.33; // 4:3
    } else if (selectedDimension === 'square') {
      // Cuadrado: mismo ancho y alto
      newHeight = clampedWidth;
    } else if (selectedDimension === 'circular') {
      // Circular: mismo ancho y alto
      newHeight = clampedWidth;
    }
    
    // Actualizar dimensiones de selección
    const newDimensions = { width: Math.round(clampedWidth), height: Math.round(newHeight) };
    setSelectionDimensions(newDimensions);
    saveToHistory();
  };
  
  // Función para actualizar el tamaño del archivo (cambiar definición proporcionalmente)
  const updateFileSize = (targetSizeKB: number) => {
    if (!selectionDimensions || !imageDimensions || !fileSize) return;
    
    // Calcular el tamaño actual en KB
    const currentSizeKB = estimateCropFileSize() / 1024;
    
    if (currentSizeKB <= 0) return;
    
    // Calcular factor de escala basado en la relación de tamaños (área es cuadrática)
    const scaleFactor = Math.sqrt(targetSizeKB / currentSizeKB);
    
    // Aplicar factor a las dimensiones actuales
    const newWidth = Math.round(selectionDimensions.width * scaleFactor);
    updateDefinition(newWidth);
  };
  
  // Función para generar el nombre del archivo con _V001
  const getSelectionFileName = (): string => {
    if (!fileName) return '';
    
    const nameWithoutExtension = fileName.substring(0, fileName.lastIndexOf('.')) || fileName;
    const extension = fileExtension ? `.${fileExtension}` : '';
    return `${nameWithoutExtension}_V001${extension}`;
  };
  
  // Función para recortar la imagen usando Canvas API
  const cropImage = async (
    sourceImage: HTMLImageElement,
    cropX: number,
    cropY: number,
    cropWidth: number,
    cropHeight: number,
    isCircular: boolean,
    include: boolean = true
  ): Promise<string> => {
    return new Promise((resolve, reject) => {
      const canvas = document.createElement('canvas');
      const ctx = canvas.getContext('2d');
      if (!ctx) {
        reject(new Error('No se pudo obtener el contexto del canvas'));
        return;
      }

      if (include) {
        // INTERIOR: Recortar solo el área seleccionada
        canvas.width = cropWidth;
        canvas.height = cropHeight;

        if (isCircular) {
          // Para crop circular, crear un path circular
          ctx.beginPath();
          ctx.arc(cropWidth / 2, cropHeight / 2, Math.min(cropWidth, cropHeight) / 2, 0, 2 * Math.PI);
          ctx.clip();
        }

        // Dibujar la porción recortada de la imagen
        ctx.drawImage(
          sourceImage,
          cropX, cropY, cropWidth, cropHeight,
          0, 0, cropWidth, cropHeight
        );
      } else {
        // EXTERIOR: Mantener toda la imagen original, pero rellenar el área seleccionada con fondo gris
        const imageWidth = sourceImage.naturalWidth || sourceImage.width;
        const imageHeight = sourceImage.naturalHeight || sourceImage.height;
        
        canvas.width = imageWidth;
        canvas.height = imageHeight;

        // Dibujar la imagen original completa
        ctx.drawImage(sourceImage, 0, 0, imageWidth, imageHeight);

        // Rellenar el área seleccionada con fondo gris (#808080)
        ctx.fillStyle = '#808080';
        
        if (isCircular) {
          // Para área circular, crear un path circular y rellenar
          ctx.beginPath();
          const centerX = cropX + cropWidth / 2;
          const centerY = cropY + cropHeight / 2;
          const radius = Math.min(cropWidth, cropHeight) / 2;
          ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI);
          ctx.fill();
        } else {
          // Para área rectangular, rellenar el rectángulo
          ctx.fillRect(cropX, cropY, cropWidth, cropHeight);
        }
      }

      // Convertir a blob y crear URL
      canvas.toBlob((blob) => {
        if (!blob) {
          reject(new Error('No se pudo crear el blob'));
          return;
        }
        const url = URL.createObjectURL(blob);
        resolve(url);
      }, 'image/png');
    });
  };

  // Función para mostrar overlay INCLUDE/EXCLUDE antes del corte
  const handleCropClick = () => {
    // Este es un paso interno de la herramienta crop, NO cambio de herramienta
    // NO llamar switchTool aquí - solo ejecutar acción interna
    if (!selectionDimensions || !selectedDimension) {
      // Si no hay selección, no hacer nada
      return;
    }
    // Mostrar overlay INCLUDE/EXCLUDE (paso interno)
    setShowIncludeExcludeOverlay(true);
  };
  
  // Función para manejar el click en la tijera
  const handleScissorsClick = () => {
    // Verificar si hay una selección activa (quad o circle)
    if (!selectionVisible || (!quad && !circle)) {
      // Si no hay selección, no hacer nada
      return;
    }
    // Mostrar overlay de decisión de tijera
    setShowScissorsOverlay(true);
  };
  
  // Función para confirmar tijera con Interior
  const handleScissorsInterior = () => {
    setShowScissorsOverlay(false);
    // Interior = mantener la selección tal cual (no hacer nada)
    // No necesitamos cambiar nada, solo cerrar el overlay
  };
  
  // Función para confirmar tijera con Exterior
  const handleScissorsExterior = () => {
    setShowScissorsOverlay(false);
    // Exterior = invertir la máscara
    // Guardar estado antes de invertir
    saveToHistory();
    setMaskInverted(!maskInverted);
  };
  
  // Función para cancelar el overlay de tijera
  const handleScissorsCancel = () => {
    setShowScissorsOverlay(false);
  };
  
  // Función para confirmar el corte con modo INCLUDE
  const handleCropInclude = async () => {
    setShowIncludeExcludeOverlay(false);
    await performCrop(true);
  };
  
  // Función para confirmar el corte con modo EXCLUDE
  const handleCropExclude = async () => {
    setShowIncludeExcludeOverlay(false);
    await performCrop(false);
  };
  
  // Función para cancelar el overlay INCLUDE/EXCLUDE
  const handleCropCancel = () => {
    setShowIncludeExcludeOverlay(false);
  };
  
  // Función para realizar el corte (INCLUDE o EXCLUDE)
  const performCrop = async (include: boolean) => {
    if (!selectionDimensions || !fileName || !imageRef.current || !containerRef.current) return;
    
    // Guardar estado antes de confirmar el crop
    saveToHistory();
    
    try {
      const img = imageRef.current;
      const container = containerRef.current;
      
      // Obtener dimensiones reales de la imagen actual (puede ser una versión recortada)
      const imageNaturalWidth = img.naturalWidth || img.width;
      const imageNaturalHeight = img.naturalHeight || img.height;
      
      // selectionDimensions ya está en píxeles reales de la imagen (calculado por CropOverlay)
      // La selección siempre está centrada, así que calculamos la posición del crop
      const selectionWidth = selectionDimensions.width;
      const selectionHeight = selectionDimensions.height;
      
      // Calcular posición del crop (centrado)
      const cropX = Math.max(0, Math.round((imageNaturalWidth - selectionWidth) / 2));
      const cropY = Math.max(0, Math.round((imageNaturalHeight - selectionHeight) / 2));
      
      // Asegurar que el crop no exceda las dimensiones de la imagen
      const finalCropWidth = Math.min(selectionWidth, imageNaturalWidth - cropX);
      const finalCropHeight = Math.min(selectionHeight, imageNaturalHeight - cropY);
      
      // Recortar la imagen
      const isCircular = selectedDimension === 'circular';
      const croppedImageUrl = await cropImage(
        img,
        cropX,
        cropY,
        finalCropWidth,
        finalCropHeight,
        isCircular,
        include
      );
      
      // Para EXTERIOR, las dimensiones son las de la imagen original completa
      // Para INTERIOR, las dimensiones son las de la selección
      const versionDimensions = include 
        ? selectionDimensions 
        : { width: imageNaturalWidth, height: imageNaturalHeight };
      
      // Calcular tamaño estimado del archivo
      const versionFileSize = include 
        ? estimateCropFileSize() 
        : fileSize; // Para EXTERIOR, mantener tamaño similar al original
      
      const newVersion = {
        fileName: getSelectionFileName(),
        dimensions: versionDimensions,
        fileSize: versionFileSize,
        dimensionType: include ? selectedDimension : null, // EXTERIOR no tiene tipo de dimensión específico
        imageUrl: croppedImageUrl
      };
      
      // Agregar la nueva versión a la lista
      const updatedVersions = [...versions, newVersion];
      setVersions(updatedVersions);
      
      // Establecer como versión actual
      const newIndex = updatedVersions.length - 1;
      setCurrentVersionIndex(newIndex);
      setConfirmedVersionInfo(newVersion);
      
      // Actualizar la imagen mostrada
      setCurrentImageUrl(croppedImageUrl);
      
      // Confirmar el crop y ocultar el overlay
      setCropConfirmed(true);
      setShowCropOverlay(false);
      
      console.log(`Cortar selección confirmada (${include ? 'INCLUDE' : 'EXCLUDE'})`);
    } catch (error) {
      console.error('Error al recortar la imagen:', error);
      alert('Error al recortar la imagen. Por favor, inténtalo de nuevo.');
    }
  };
  
  // Función para navegar a la versión anterior
  const handlePreviousVersion = () => {
    if (currentVersionIndex > 0) {
      const newIndex = currentVersionIndex - 1;
      setCurrentVersionIndex(newIndex);
      const version = versions[newIndex];
      setConfirmedVersionInfo(version);
      setCurrentImageUrl(version.imageUrl);
      // Restaurar estados de privacidad si existen
      if (version.removeMetadata !== undefined) {
        setRemoveMetadata(version.removeMetadata);
      }
      if (version.watermarkMode !== undefined) {
        setWatermarkMode(version.watermarkMode);
      }
    } else if (currentVersionIndex === 0) {
      // Volver a la imagen original
      setCurrentVersionIndex(-1);
      setConfirmedVersionInfo(null);
      setCurrentImageUrl(imageUrl);
      setCropConfirmed(false);
      // Restaurar estados iniciales de privacidad
      setRemoveMetadata(false);
      setWatermarkMode('NONE');
      setWatermarkVisible(true);
      setWatermarkText('');
      setWatermarkImageFile(null);
    }
  };
  
  // Función para navegar a la versión siguiente
  const handleNextVersion = () => {
    if (currentVersionIndex < versions.length - 1) {
      const newIndex = currentVersionIndex + 1;
      setCurrentVersionIndex(newIndex);
      const version = versions[newIndex];
      setConfirmedVersionInfo(version);
      setCurrentImageUrl(version.imageUrl);
      setCropConfirmed(true);
      // Restaurar estados de privacidad si existen
      if (version.removeMetadata !== undefined) {
        setRemoveMetadata(version.removeMetadata);
      }
      if (version.watermarkMode !== undefined) {
        setWatermarkMode(version.watermarkMode);
      }
    }
  };
  
  // Actualizar barra naranja superior con mensaje de marca de agua
  useEffect(() => {
    // La barra naranja ya muestra la información de versión automáticamente
    // Solo necesitamos asegurarnos de que se actualice cuando cambie watermarkMode
  }, [watermarkMode, removeMetadata, currentVersionIndex]);
  
  // Función para volver atrás desde la versión confirmada
  const handleBackFromVersion = () => {
    setCropConfirmed(false);
    setConfirmedVersionInfo(null);
    setCurrentVersionIndex(-1);
    setCurrentImageUrl(imageUrl);
  };
  
  // Determinar si las flechas están deshabilitadas
  const canGoPrevious = versions.length > 0 && currentVersionIndex >= 0;
  const canGoNext = versions.length > 0 && currentVersionIndex < versions.length - 1;
  
  // Función para determinar el color de las flechas según el fondo
  const getArrowColor = (): 'white' | 'orange' => {
    // Extraer valores RGB del dominantColor (formato: "rgb(r, g, b)")
    const rgbMatch = dominantColor.match(/\d+/g);
    if (!rgbMatch || rgbMatch.length < 3) return 'white';
    
    const r = parseInt(rgbMatch[0]);
    const g = parseInt(rgbMatch[1]);
    const b = parseInt(rgbMatch[2]);
    
    // Calcular luminosidad relativa (0-1)
    // Fórmula: (0.299*R + 0.587*G + 0.114*B) / 255
    const luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255;
    
    // Si el fondo es oscuro (luminosidad < 0.5), usar blanco; si es claro, usar naranja
    return luminance < 0.5 ? 'white' : 'orange';
  };
  
  const arrowColor = getArrowColor();
  
  // Obtener la información actual para mostrar en la barra superior
  const getCurrentInfo = () => {
    if (currentVersionIndex >= 0 && versions[currentVersionIndex]) {
      return versions[currentVersionIndex];
    }
    if (cropConfirmed && confirmedVersionInfo) {
      return confirmedVersionInfo;
    }
    return null;
  };
  
  const currentInfo = getCurrentInfo();
  
  // Obtener el número de versión para mostrar
  const getVersionNumber = () => {
    if (currentVersionIndex >= 0) {
      return currentVersionIndex + 1;
    }
    return null;
  };
  
  // Obtener el texto de información de la versión para la barra blanca
  const getVersionInfoText = () => {
    // Obtener número de versión
    const versionNum = getVersionNumber();
    
    // Construir mensajes de privacidad (prioridad sobre preset/adjustment)
    const privacyMessages: string[] = [];
    
    // Metadatos: mostrar estado actual
    if (removeMetadata) {
      privacyMessages.push('Metadatos: Eliminados');
    } else if (versionNum) {
      // Solo mostrar "Conservados" si hay versión activa
      privacyMessages.push('Metadatos: Conservados');
    }
    
    // Watermark: mostrar estado actual
    if (watermarkMode === 'AUTO') {
      privacyMessages.push(`Marca de agua: automática (${watermarkVisible ? 'visible' : 'no visible'})`);
    } else if (watermarkMode === 'CUSTOM_TEXT') {
      privacyMessages.push(`Marca de agua: personalizada (texto${watermarkVisible ? ', visible' : ''})`);
    } else if (watermarkMode === 'CUSTOM_IMAGE') {
      privacyMessages.push(`Marca de agua: personalizada (imagen${watermarkVisible ? ', visible' : ''})`);
    }
    
    // Si hay mensajes de privacidad, combinarlos con versión
    if (privacyMessages.length > 0) {
      if (versionNum) {
        return `V${versionNum} · ${privacyMessages.join(' · ')}`;
      }
      return privacyMessages.join(' · ');
    }
    
    // Luego verificar información de versión (preset/adjustment)
    if (!currentInfo) return null;
    
    if (!versionNum) return null;
    
    if (currentInfo.preset) {
      const presetLabels: Record<ColorPreset, string> = {
        color: 'Color',
        grayscale: 'Grises',
        sepia: 'Sepia',
        bw: 'B&W',
      };
      return `V${versionNum} · Preset: ${presetLabels[currentInfo.preset]}`;
    }
    
    if (currentInfo.adjustment) {
      const adjustmentLabels: Record<AdjustmentType, string> = {
        brightness: 'Brillo',
        contrast: 'Contraste',
        saturation: 'Saturación',
        sharpness: 'Nitidez',
      };
      const sign = currentInfo.adjustment.value > 50 ? '+' : '';
      const value = currentInfo.adjustment.value - 50; // Convertir de 0-100 a -50 a +50
      return `V${versionNum} · Ajuste: ${adjustmentLabels[currentInfo.adjustment.type]} ${sign}${value}`;
    }
    
    return null;
  };

  const handleVideoChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      onVideoSelect(file);
    }
  };

  const handleSave = async () => {
    // Obtener la imagen actual (versión o original)
    const imageToSave = currentImageUrl || imageUrl;
    if (!imageToSave) {
      alert('No hay imagen para guardar');
      return;
    }
    
    try {
      // Si hay un filtro de color activo, aplicar al canvas
      if (selectedColorMode && selectedColorMode !== 'color' && imageRef.current) {
        const canvas = document.createElement('canvas');
        const ctx = canvas.getContext('2d');
        if (!ctx) {
          alert('Error al crear canvas para exportar');
          return;
        }
        
        // Crear imagen temporal para cargar
        const img = new Image();
        img.crossOrigin = 'anonymous';
        
        await new Promise((resolve, reject) => {
          img.onload = resolve;
          img.onerror = reject;
          img.src = imageToSave;
        });
        
        canvas.width = img.width;
        canvas.height = img.height;
        ctx.drawImage(img, 0, 0, canvas.width, canvas.height);
        
        // Aplicar filtro de color
        applyColorFilterToCanvas(ctx, canvas.width, canvas.height, selectedColorMode);
        
        // Convertir canvas a blob
        canvas.toBlob((blob) => {
          if (!blob) {
            alert('Error al procesar la imagen');
            return;
          }
          
          // Crear nombre de archivo
          const currentInfo = getCurrentInfo();
          const saveFileName = currentInfo?.fileName || fileName || 'imagen.jpg';
          
          // Exportar
          const url = URL.createObjectURL(blob);
          const a = document.createElement('a');
          a.href = url;
          a.download = saveFileName;
          document.body.appendChild(a);
          a.click();
          document.body.removeChild(a);
          URL.revokeObjectURL(url);
          
          console.log(`Imagen exportada al álbum ImageNrrobAART: ${saveFileName}`);
          alert(`Imagen guardada en álbum ImageNrrobAART: ${saveFileName}`);
        }, 'image/jpeg');
      } else {
        // Sin filtro de color, exportar directamente
        const response = await fetch(imageToSave);
        const blob = await response.blob();
        
        // Crear nombre de archivo
        const currentInfo = getCurrentInfo();
        const saveFileName = currentInfo?.fileName || fileName || 'imagen.jpg';
        
        // Crear archivo desde blob
        const file = new File([blob], saveFileName, { type: blob.type });
        
        // Exportar al álbum fijo ImageNrrobAART
        // En un entorno real, esto usaría la API del sistema para guardar en el álbum
        // Por ahora, simulamos la descarga
        const url = URL.createObjectURL(file);
        const a = document.createElement('a');
        a.href = url;
        a.download = saveFileName;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        URL.revokeObjectURL(url);
        
        console.log(`Imagen exportada al álbum ImageNrrobAART: ${saveFileName}`);
        alert(`Imagen guardada en álbum ImageNrrobAART: ${saveFileName}`);
      }
    } catch (error) {
      console.error('Error al guardar la imagen:', error);
      alert('Error al guardar la imagen. Por favor, inténtalo de nuevo.');
    }
  };

  const handleHome = () => {
    // Si existe react-router-dom, usar useNavigate()
    // Si no, usar window.location.href
    if (typeof window !== 'undefined') {
      window.location.href = '/';
    }
  };


  const handleSelectToolClick = () => {
    // Cambiar de herramienta
    switchTool('dimension');
    
    // Activar herramienta de selección
    setSelectedTool('select');
    
    // Limpiar todas las opciones de selección de la memoria
    setShowCropOverlay(false);
    setSelectionDimensions(null);
    setCropConfirmed(false);
    setSelectedDimension(null);
    setCircleShape(null);
    setCurrentPixelRegion(null);
    setPixelatedAreas([]);
    setPixelWizardStep('IDLE');
    setPixelSelectionSource(null);
    setManualSelectionType(null);
    
    // Siempre mostrar las opciones de dimensiones (sobreimpresión)
    setShowDimensionOptions(true);
  };

  // Estado inicial: sin imagen cargada
  if (!imageUrl) {
    return (
      <>
        <div className="min-h-screen flex flex-col bg-black">
          {/* Header con logo y descripción */}
          <div className="pt-8 pb-4 px-6 text-center">
            <h1 className="text-white text-2xl font-light mb-2 tracking-wide">
              Imagen<span className="font-normal">@</span>rte
            </h1>
            <p className="text-gray-400 text-xs mb-1">
              Tratamiento y protección de imágenes
            </p>
            <p className="text-gray-500 text-xs">
              Versión MVP • Offline-first • Sin backend
            </p>
          </div>

          {/* Área gris oscuro con botones centrados */}
          <div className="flex-1 bg-neutral-900 flex items-center justify-center">
            <div className="flex flex-col gap-4">
              <button
                onClick={handleImageButtonClick}
                className="flex items-center gap-3 px-6 py-3 text-gray-400 hover:text-gray-200 transition-colors"
              >
                <ImageIcon className="w-5 h-5" />
                <span className="text-sm">Seleccionar imagen</span>
              </button>
              
              <button
                onClick={handleVideoButtonClick}
                className="flex items-center gap-3 px-6 py-3 text-gray-400 hover:text-gray-200 transition-colors"
              >
                <Video className="w-5 h-5" />
                <span className="text-sm">Seleccionar video</span>
              </button>
            </div>
          </div>

          {/* Botones de Ajustes y Ayuda + Footer legal */}
          <div className="pb-4" style={{ paddingBottom: 'calc(1rem + env(safe-area-inset-bottom))' }}>
            {/* Botones de Ajustes y Ayuda */}
            <div className="flex justify-center items-center gap-7 mb-2">
              <button
                onClick={() => setOpenSheet('settings')}
                className="flex items-center gap-2 bg-transparent border-none cursor-pointer text-gray-400 hover:text-gray-200 transition-colors"
                style={{ opacity: 0.75 }}
              >
                <Settings className="w-5 h-5" />
                <span className="text-xs font-medium" style={{ fontSize: '12px' }}>Ajustes</span>
              </button>
              
              <button
                onClick={() => setOpenSheet('help')}
                className="flex items-center gap-2 bg-transparent border-none cursor-pointer text-gray-400 hover:text-gray-200 transition-colors"
                style={{ opacity: 0.75 }}
              >
                <span style={{ fontSize: '20px' }}>❓</span>
                <span className="text-xs font-medium" style={{ fontSize: '12px' }}>Ayuda</span>
              </button>
            </div>

            {/* Footer legal */}
            <div className="text-center">
              <p className="text-gray-500 text-xs mb-1" style={{ fontSize: '10px', opacity: 0.45 }}>
                © 2026 Imagen@rte — Todos los derechos reservados
              </p>
              <p className="text-gray-500 text-xs" style={{ fontSize: '10px', opacity: 0.45 }}>
                Tratamiento local · Sin backend · Sin tracking
              </p>
            </div>
          </div>

          {/* Inputs ocultos para selección de archivos */}
          <input
            ref={imageInputRef}
            type="file"
            accept="image/*"
            onChange={handleImageChange}
            className="hidden"
          />
          <input
            ref={videoInputRef}
            type="file"
            accept="video/*"
            onChange={handleVideoChange}
            className="hidden"
          />
        </div>

        {/* Modales */}
        {openSheet === 'settings' && (
          <SettingsModal onClose={() => setOpenSheet(null)} />
        )}
        {openSheet === 'help' && (
          <HelpModal onClose={() => setOpenSheet(null)} />
        )}
      </>
    );
  }

  // Estado con imagen: mostrar controles completos
  return (
    <div className="min-h-screen flex flex-col w-full" style={{ backgroundColor: dominantColor, margin: 0, padding: 0, gap: 0 }}>
      {/* Primera barra de herramientas - información del archivo (arriba de la imagen) */}
      <div className="w-full h-[25px] min-h-[25px] bg-orange-500 flex items-center gap-3 px-4 flex-shrink-0" style={{ borderRadius: 0, marginTop: 0, paddingTop: 0 }}>
        {/* Información: si hay versión actual, mostrar info de la versión, sino mostrar info original */}
        {currentVersionIndex >= 0 && currentInfo ? (
          <>
            {/* Nombre del archivo de la versión actual */}
            <span className="text-xs font-medium text-white">
              {currentInfo.fileName}
            </span>
            
            {/* Definición de la versión actual */}
            <span className="text-xs font-medium text-white">
              {currentInfo.dimensionType === 'circular' 
                ? `⌀${Math.min(currentInfo.dimensions.width, currentInfo.dimensions.height)}`
                : `${currentInfo.dimensions.width}×${currentInfo.dimensions.height}`
              }
            </span>
            
            {/* Tamaño estimado del archivo de la versión actual */}
            <span className="text-xs font-medium text-white">
              ~{formatFileSize(currentInfo.fileSize)}
            </span>
            
            {/* Mensaje de marca de agua si está activa */}
            {watermarkMode !== 'NONE' && (
              <span className="text-xs font-medium text-white ml-auto">
                Marca de agua aplicada
              </span>
            )}
          </>
        ) : (
          <>
            {/* Nombre del archivo con extensión */}
            {fileName && (
              <span className="text-xs font-medium text-white">
                {fileName}
              </span>
            )}
            
            {/* Definición (dimensiones) */}
            {imageDimensions && (
              <span className="text-xs font-medium text-white">
                {imageDimensions.width}×{imageDimensions.height}
              </span>
            )}
            
            {/* Tamaño del archivo */}
            {fileSize > 0 && (
              <span className="text-xs font-medium text-white">
                {formatFileSize(fileSize)}
              </span>
            )}
            
            {/* Mensaje de marca de agua si está activa */}
            {watermarkMode !== 'NONE' && (
              <span className="text-xs font-medium text-white ml-auto">
                Marca de agua aplicada
              </span>
            )}
          </>
        )}
      </div>

      {/* Barra blanca - información de selección o ayuda */}
      <div className="w-full h-[25px] min-h-[25px] bg-white flex items-center gap-3 px-4 flex-shrink-0 overflow-hidden" style={{ borderRadius: 0, marginTop: 0, paddingTop: 0 }}>
        {pixelWizardStep === 'DIAL' ? (
          /* Información de intensidad de pixelado */
          <div className="relative w-full h-full flex items-center overflow-hidden">
            <div 
              className="text-xs font-medium text-orange-500 whitespace-nowrap"
              style={{
                display: 'inline-block',
                animation: 'scroll-text 20s linear infinite',
                paddingRight: '50px'
              }}
            >
              {(() => {
                const message = `Intensidad de pixelado: ${pixelIntensity}%`;
                return `${message} • ${message} • `;
              })()}
            </div>
          </div>
        ) : getVersionInfoText() ? (
          /* Información de versión con preset o ajuste */
          <div className="relative w-full h-full flex items-center overflow-hidden">
            <div 
              className="text-xs font-medium text-orange-500 whitespace-nowrap"
              style={{
                display: 'inline-block',
                animation: 'scroll-text 20s linear infinite',
                paddingRight: '50px'
              }}
            >
              {(() => {
                const message = getVersionInfoText() || '';
                return `${message} • ${message} • `;
              })()}
            </div>
          </div>
        ) : showCropOverlay && !cropConfirmed ? (
          /* Información de la selección cuando está activa */
          <>
            {/* Nombre del archivo con _V001 */}
            {fileName && (
              <button 
                onClick={(e) => {
                  e.stopPropagation();
                  setShowFormatOptions(!showFormatOptions);
                }}
                className="flex items-center gap-1 text-xs font-medium text-orange-500 hover:opacity-80 transition-opacity min-w-0 flex-shrink"
              >
                <span className="truncate max-w-[200px]">{getSelectionFileName()}</span>
                <ChevronDown className="w-3 h-3 flex-shrink-0" />
              </button>
            )}
            
            {/* Definición de la selección */}
            {selectionDimensions && (
              <button
                onClick={(e) => {
                  e.stopPropagation();
                  setShowDefinitionDial(!showDefinitionDial);
                  setShowSizeDial(false);
                }}
                className="flex items-center gap-1 text-xs font-medium text-orange-500 hover:opacity-80 transition-opacity"
              >
                <span>
                  {selectedDimension === 'circular' 
                    ? `⌀${Math.min(selectionDimensions.width, selectionDimensions.height)}`
                    : `${selectionDimensions.width}×${selectionDimensions.height}`
                  }
                </span>
                <ChevronDown className="w-3 h-3 flex-shrink-0" />
              </button>
            )}
            
            {/* Tamaño estimado del archivo después del crop */}
            {selectionDimensions && fileSize > 0 && (
              <button
                onClick={(e) => {
                  e.stopPropagation();
                  setShowSizeDial(!showSizeDial);
                  setShowDefinitionDial(false);
                }}
                className="flex items-center gap-1 text-xs font-medium text-orange-500 hover:opacity-80 transition-opacity"
              >
                <span>~{formatFileSize(estimateCropFileSize())}</span>
                <ChevronDown className="w-3 h-3 flex-shrink-0" />
              </button>
            )}
          </>
        ) : (
          /* Mensajes de ayuda cuando no hay funcionalidad específica */
          <div className="relative w-full h-full flex items-center overflow-hidden">
            <div 
              className="text-xs font-medium text-orange-500 whitespace-nowrap"
              style={{
                display: 'inline-block',
                animation: 'scroll-text 20s linear infinite',
                paddingRight: '50px'
              }}
            >
              {(() => {
                // Ayuda contextual según el estado
                const message = (() => {
                  if ((pixelWizardStep === 'MANUAL_SELECT' || blurWizardStep === 'MANUAL_SELECT') && selectedTool === 'pointer') {
                    return ''; // Sin mensaje - la acción se comunica por la herramienta activa
                  } else if (selectedTool === 'select') {
                    return 'Selecciona una forma de recorte';
                  } else if (selectedTool === 'pointer') {
                    return 'Herramienta de selección: haz clic en los controles para ajustar valores';
                  } else if (selectedTool === 'undo' || historyIndex > 0) {
                    return `Deshace la última acción (${historyIndex} nivel${historyIndex > 1 ? 'es' : ''} disponible${historyIndex > 1 ? 's' : ''})`;
                  } else if (cropConfirmed && versions.length > 0) {
                    return 'Usa las flechas sobre la imagen para navegar entre versiones';
                  } else if (imageUrl) {
                    return 'Selecciona una herramienta del menú para comenzar a editar';
                  } else {
                    return 'Selecciona una imagen para comenzar';
                  }
                })();
                
                // Duplicar el mensaje para efecto circular continuo
                return `${message} • ${message} • `;
              })()}
            </div>
          </div>
        )}
      </div>
      
      {/* Estilos para la animación de scroll */}
      <style>{`
        @keyframes scroll-text {
          0% {
            transform: translateX(0);
          }
          100% {
            transform: translateX(-50%);
          }
        }
      `}</style>

      {/* Imagen con overlay de crop - pantalla completa */}
      <div 
        ref={containerRef}
        className="relative flex-1 overflow-hidden w-full preview-image-container" 
        style={{ 
          width: '100%', 
          margin: 0, 
          padding: 0, 
          marginTop: 0, 
          paddingTop: 0,
          marginBottom: 0,
          paddingBottom: 0,
          borderRadius: 0,
          backgroundColor: cropConfirmed ? '#808080' : 'transparent', // Gris medio cuando está confirmado
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          touchAction: 'auto',
          pointerEvents: 'auto',
          position: 'relative',
          zIndex: 1,
          cursor: selectionVisible ? getCursor() : 'default',
        }}
        onPointerDown={handlePointerDown}
        onPointerMove={handlePointerMove}
        onPointerUp={handlePointerUp}
        onPointerCancel={handlePointerCancel}
      >
        {/* Contenedor de imagen con pointer-events controlado */}
        <div
          ref={imageContainerRef}
          style={{
            width: '100%',
            height: '100%',
            position: 'absolute',
            inset: 0,
            pointerEvents: 'auto',
            zIndex: 1, // Debajo de los overlays
          }}
        >
          <img 
            ref={imageRef}
            src={currentImageUrl || imageUrl} 
            alt="Imagen seleccionada" 
            className={cropConfirmed ? "preview-image-flat" : "w-full h-full object-cover preview-image-flat"}
            style={{ 
              width: cropConfirmed ? 'auto' : '100%',
              height: cropConfirmed ? 'auto' : '100%',
              maxWidth: cropConfirmed ? '100%' : 'none',
              maxHeight: cropConfirmed ? '100%' : 'none',
              objectFit: cropConfirmed ? 'contain' : 'cover',
              display: 'block',
              margin: 0,
              padding: 0,
              marginTop: 0,
              paddingTop: 0,
              pointerEvents: 'none', // La imagen siempre sin eventos (el contenedor los controla)
              userSelect: 'none',
              WebkitUserSelect: 'none',
              filter: getCombinedFilterCSS(),
            }}
            onLoad={extractDominantColor}
            crossOrigin="anonymous"
            draggable={false}
          />
        </div>
        
        {/* Flechas de navegación sobre la imagen (solo cuando hay versiones) */}
        {versions.length > 0 && (
          <>
            {/* Flecha izquierda (anterior) */}
            <button
              onClick={handlePreviousVersion}
              disabled={!canGoPrevious}
              className="absolute left-4 top-1/2 -translate-y-1/2 flex items-center justify-center disabled:opacity-30 disabled:cursor-not-allowed transition-opacity hover:opacity-80"
              style={{ 
                zIndex: 10,
                background: 'transparent',
                border: 'none',
                padding: 0,
                margin: 0
              }}
              title="Anterior"
            >
              <ChevronLeft className={`w-8 h-8 ${arrowColor === 'white' ? 'text-white' : 'text-orange-500'}`} />
            </button>
            
            {/* Flecha derecha (siguiente) */}
            <button
              onClick={handleNextVersion}
              disabled={!canGoNext}
              className="absolute right-4 top-1/2 -translate-y-1/2 flex items-center justify-center disabled:opacity-30 disabled:cursor-not-allowed transition-opacity hover:opacity-80"
              style={{ 
                zIndex: 10,
                background: 'transparent',
                border: 'none',
                padding: 0,
                margin: 0
              }}
              title="Siguiente"
            >
              <ChevronRight className={`w-8 h-8 ${arrowColor === 'white' ? 'text-white' : 'text-orange-500'}`} />
            </button>
          </>
        )}
        
        {/* Overlay de Color Presets */}
        {showColorPresetsOverlay && (
          <ColorPresetsOverlay
            onSelect={handlePresetSelect}
            onClose={() => setShowColorPresetsOverlay(false)}
            selectedPreset={selectedColorMode}
          />
        )}
        
        {/* Overlay de Adjustments */}
        {showAdjustmentsOverlay && (
          <AdjustmentsOverlay
            onSelect={handleAdjustmentSelect}
            onClose={() => setShowAdjustmentsOverlay(false)}
          />
        )}
        
        {/* Mini overlay INCLUDE/EXCLUDE antes del corte */}
        {showIncludeExcludeOverlay && (
          <IncludeExcludeOverlay
            onInclude={handleCropInclude}
            onExclude={handleCropExclude}
            onCancel={handleCropCancel}
          />
        )}
        
        {/* Overlay de decisión de tijera */}
        {showScissorsOverlay && (
          <ScissorsDecisionOverlay
            onInterior={handleScissorsInterior}
            onExterior={handleScissorsExterior}
            onCancel={handleScissorsCancel}
          />
        )}
        
        {/* Overlay de marca de agua */}
        {showWatermarkOverlay && (
          <div className="absolute inset-0 z-30">
            <WatermarkOverlay
              onComplete={handleWatermarkComplete}
              onClose={() => {
                setShowWatermarkOverlay(false);
                setActiveControl(null);
              }}
            />
          </div>
        )}
        
        {/* Dial de ajuste activo (cuando se selecciona un ajuste del overlay) */}
        {activeAdjustment && (() => {
          // Convertir valor interno (0..100, 50 = neutral) a valor mostrado (-100..+100 para los primeros 3, 0..100 para sharpness)
          const getDisplayValue = (internalValue: number): number => {
            if (activeAdjustment === 'sharpness') {
              return internalValue; // 0..100 directamente
            }
            return (internalValue - 50) * 2; // -100..+100
          };
          
          const getInternalValue = (displayValue: number): number => {
            if (activeAdjustment === 'sharpness') {
              return Math.max(0, Math.min(100, displayValue));
            }
            // Convertir -100..+100 a 0..100 (50 = neutral)
            return Math.max(0, Math.min(100, (displayValue / 2) + 50));
          };
          
          const displayValue = getDisplayValue(adjustmentValue);
          const isSharpness = activeAdjustment === 'sharpness';
          
          return (
            <OverlayDial
              label={activeAdjustment === 'brightness' ? 'Brillo' : 
                     activeAdjustment === 'contrast' ? 'Contraste' :
                     activeAdjustment === 'saturation' ? 'Saturación' : 'Nitidez'}
              value={adjustmentValue}
              valueText={isSharpness ? `${displayValue} %` : `${displayValue > 0 ? '+' : ''}${displayValue} %`}
              min={0}
              max={100}
              step={1}
              onChange={(val) => {
                const clampedVal = Math.max(0, Math.min(100, val));
                const roundedVal = Math.round(clampedVal);
                setAdjustmentValue(roundedVal);
                
                // Actualizar classicAdjustments en tiempo real
                const adjustmentMap: Record<AdjustmentType, keyof typeof classicAdjustments> = {
                  brightness: 'brightness',
                  contrast: 'contrast',
                  saturation: 'saturation',
                  sharpness: 'sharpness',
                };
                setClassicAdjustments({
                  ...classicAdjustments,
                  [adjustmentMap[activeAdjustment]]: roundedVal,
                });
              }}
              onCommit={(val) => {
                handleAdjustmentConfirm();
              }}
              isVisible={true}
              onClose={handleAdjustmentCancel}
            />
          );
        })()}

        {/* ========== OVERLAYS DE PIXELADO DE ROSTRO ========== */}
        
        {/* Recuadro rojo provisional - se mantiene visible durante el dial */}
        {/* Mostrar recuadro si:
            - Hay currentPixelRegion durante DIAL (automática o manual)
            - O durante PICK_TYPE antes de seleccionar (detectedFaces)
            - O durante MANUAL_SELECT cuando se está seleccionando */}
        {(() => {
          const showRegionDuringDial = pixelWizardStep === 'DIAL' && currentPixelRegion;
          const showDetectedFaces = pixelWizardStep === 'PICK_TYPE' && detectedFaces.length > 0 && pixelSelectionSource === null;
          
          if (showRegionDuringDial) {
            // Mostrar recuadro durante el dial (OBLIGATORIO según especificación)
            return (
              <FacePixelatePreviewOverlay
                areas={[currentPixelRegion]}
                containerWidth={containerSize.width}
                containerHeight={containerSize.height}
                imageWidth={imageRef.current?.naturalWidth || imageRef.current?.width || 0}
                imageHeight={imageRef.current?.naturalHeight || imageRef.current?.height || 0}
              />
            );
          } else if (showDetectedFaces) {
            return (
              <FacePixelatePreviewOverlay
                areas={detectedFaces}
                containerWidth={containerSize.width}
                containerHeight={containerSize.height}
                imageWidth={imageRef.current?.naturalWidth || imageRef.current?.width || 0}
                imageHeight={imageRef.current?.naturalHeight || imageRef.current?.height || 0}
              />
            );
          }
          return null;
        })()}
        
        {/* Badge de debug temporal */}
        {activeControl === 'pixelate' && (
          <div 
            className="absolute top-2 left-2 z-50 text-white text-xs font-mono bg-black/50 px-2 py-1 rounded"
            style={{ pointerEvents: 'none' }}
          >
            PIXEL_STEP: {pixelWizardStep} | SOURCE: {pixelSelectionSource || 'null'} | REGION: {currentPixelRegion ? 'YES' : 'NO'}
          </div>
        )}

        {/* PASO 1: Overlay PICK_TYPE - Automática | Manual (OverlayOptionsRow) */}
        {pixelWizardStep === 'PICK_TYPE' && (
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
                options={[
                  { id: 'auto', label: 'Automática' },
                  { id: 'manual', label: 'Manual' },
                ]}
                selectedId={pixelSelectionSource === 'AUTO' ? 'auto' : pixelSelectionSource === 'MANUAL' ? 'manual' : null}
                onSelect={handlePixelTypeSelect}
                color="white"
              />
            </OverlayBox>
          </div>
        )}

        {/* PASO 1.5: Overlay MANUAL_SELECT_TYPE - Selección | Libre (OverlayOptionsRow) */}
        {pixelWizardStep === 'MANUAL_SELECT_TYPE' && (
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
                title="Modo de selección manual"
                mode="text"
                options={[
                  { id: 'select', label: 'Selección' },
                  { id: 'pointer', label: 'Libre' },
                ]}
                selectedId={manualSelectionType === 'select' ? 'select' : manualSelectionType === 'pointer' ? 'pointer' : null}
                onSelect={handleManualSelectionTypeSelect}
                color="white"
              />
            </OverlayBox>
          </div>
        )}

        {/* PASO 1 (continuación): Overlay de selección libre (herramienta pointer) */}
        {pixelWizardStep === 'MANUAL_SELECT' && selectedTool === 'pointer' && manualSelectionType === 'pointer' && (
          <FreeSelectionOverlay
            containerWidth={containerSize.width}
            containerHeight={containerSize.height}
            imageWidth={imageRef.current?.naturalWidth || imageRef.current?.width || 0}
            imageHeight={imageRef.current?.naturalHeight || imageRef.current?.height || 0}
            onSelectionComplete={handleManualSelectionComplete}
            onCancel={() => {
              setPixelWizardStep('IDLE');
              setSelectedTool(null);
              setPixelSelectionSource(null);
              setManualSelectionType(null);
              setCurrentPixelRegion(null);
            }}
          />
        )}

        {/* PASO 1 (continuación): Overlay de selección por formas (herramienta select) */}
        {/* El CropOverlay se renderiza más abajo cuando showCropOverlay es true */}
        
        {/* Botón de confirmación para selección por formas en modo manual */}
        {pixelWizardStep === 'MANUAL_SELECT' && manualSelectionType === 'select' && showCropOverlay && selectionDimensions && (
          <div
            className="absolute z-20"
            style={{
              bottom: '33px',
              left: '50%',
              transform: 'translateX(-50%)',
              width: 'calc(100% - 32px)',
            }}
          >
            <OverlayBox>
              <OverlayOptionsRow
                title="Confirmación"
                mode="text"
                options={[
                  { id: 'confirm', label: 'Confirmar' },
                  { id: 'cancel', label: 'Cancelar' },
                ]}
                onSelect={(id) => {
                  if (id === 'confirm') {
                    // Convertir selectionDimensions a coordenadas reales de la imagen
                    if (imageRef.current && selectionDimensions && containerSize.width > 0 && containerSize.height > 0) {
                      const imageNaturalWidth = imageRef.current.naturalWidth || imageRef.current.width;
                      const imageNaturalHeight = imageRef.current.naturalHeight || imageRef.current.height;
                      
                      // La selección está centrada, calcular posición
                      const selectionWidthReal = selectionDimensions.width;
                      const selectionHeightReal = selectionDimensions.height;
                      const x = Math.max(0, Math.round((imageNaturalWidth - selectionWidthReal) / 2));
                      const y = Math.max(0, Math.round((imageNaturalHeight - selectionHeightReal) / 2));
                      
                      handleManualSelectionComplete({
                        x,
                        y,
                        width: selectionWidthReal,
                        height: selectionHeightReal,
                      });
                    }
                  } else if (id === 'cancel') {
                    // Cancelar selección manual
                    setPixelWizardStep('IDLE');
                    setSelectedTool(null);
                    setPixelSelectionSource(null);
                    setManualSelectionType(null);
                    setCurrentPixelRegion(null);
                    setShowCropOverlay(false);
                    setShowDimensionOptions(false);
                  }
                }}
                color="white"
              />
            </OverlayBox>
          </div>
        )}

        {/* PASO 2: Dial de intensidad de pixelado */}
        {(() => {
          const shouldShowDial = pixelWizardStep === 'DIAL';
          console.log('[PIXEL] dial render check', { 
            pixelWizardStep, 
            shouldShowDial,
            currentPixelRegion,
            pixelSelectionSource,
            activeControl
          });
          
          return shouldShowDial ? (
            <OverlayDial
              label="Intensidad de pixelado"
              value={pixelIntensity}
              valueText={`${pixelIntensity}%`}
              min={0}
              max={100}
              step={1}
              onChange={(val) => {
                const clampedVal = Math.max(0, Math.min(100, val));
                setPixelIntensity(Math.round(clampedVal));
              }}
              onCommit={(val) => {
                applyPixelate();
              }}
              isVisible={true}
              onClose={() => {
                // Cerrar dial (paso interno, NO cleanup general)
                // Si se cierra el dial, volver a PICK_TYPE o finalizar según contexto
                setPixelWizardStep('IDLE');
                setCurrentPixelRegion(null);
                setPixelSelectionSource(null);
                setManualSelectionType(null);
                // activeControl se mantiene en 'pixelate' (botón sigue marcado)
              }}
            />
          ) : null;
        })()}

        {/* PASO 3: Overlay ASK_MORE - ¿Desea pixelar otra zona? (Sí | No) */}
        {pixelWizardStep === 'ASK_MORE' && (
          <>
            {/* Overlay para cerrar al hacer click fuera */}
            <div 
              className="absolute inset-0 z-10"
              onClick={() => {
                // Si se cierra, asumir "No" (finalizar)
                handleAskMoreSelect('no');
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
                  title="¿Desea pixelar otra área?"
                  mode="text"
                  options={[
                    { id: 'yes', label: 'Sí' },
                    { id: 'no', label: 'No' },
                  ]}
                  onSelect={handleAskMoreSelect}
                  color="white"
                />
              </OverlayBox>
            </div>
          </>
        )}

        {/* ========== OVERLAYS DE BLUR (MIRROR DE PIXELADO) ========== */}
        
        {/* Preview overlay para blur (reutilizando FacePixelatePreviewOverlay) */}
        {(() => {
          const showBlurPreview = blurWizardStep !== 'IDLE' && currentBlurRegion;
          const showDetectedFacesForBlur = blurWizardStep === 'PICK_TYPE' && detectedFacesForBlur.length > 0;
          
          if (showBlurPreview) {
            return (
              <FacePixelatePreviewOverlay
                areas={[currentBlurRegion]}
                containerWidth={containerSize.width}
                containerHeight={containerSize.height}
                imageWidth={imageRef.current?.naturalWidth || imageRef.current?.width || 0}
                imageHeight={imageRef.current?.naturalHeight || imageRef.current?.height || 0}
              />
            );
          } else if (showDetectedFacesForBlur) {
            return (
              <FacePixelatePreviewOverlay
                areas={detectedFacesForBlur}
                containerWidth={containerSize.width}
                containerHeight={containerSize.height}
                imageWidth={imageRef.current?.naturalWidth || imageRef.current?.width || 0}
                imageHeight={imageRef.current?.naturalHeight || imageRef.current?.height || 0}
              />
            );
          }
          return null;
        })()}

        {/* Badge de debug temporal para blur */}
        {activeControl === 'blur' && (
          <div 
            className="absolute top-2 left-2 z-50 text-white text-xs font-mono bg-black/50 px-2 py-1 rounded"
            style={{ pointerEvents: 'none' }}
          >
            BLUR_STEP: {blurWizardStep} | SOURCE: {blurSelectionSource || 'null'} | REGION: {currentBlurRegion ? 'YES' : 'NO'}
          </div>
        )}

        {/* PASO 1: Overlay PICK_TYPE - Automática | Manual (OverlayOptionsRow) */}
        {blurWizardStep === 'PICK_TYPE' && (
          <div
            className="absolute z-20"
            style={{
              bottom: '33px',
              left: '50%',
              transform: 'translateX(-50%)',
              width: 'calc(100% - 32px)',
            }}
          >
            <OverlayBox>
              <OverlayOptionsRow
                title="Tipo de selección"
                mode="text"
                options={[
                  { id: 'auto', label: 'Automática' },
                  { id: 'manual', label: 'Manual' },
                ]}
                selectedId={blurSelectionSource === 'AUTO' ? 'auto' : blurSelectionSource === 'MANUAL' ? 'manual' : null}
                onSelect={handleBlurTypeSelect}
                color="white"
              />
            </OverlayBox>
          </div>
        )}

        {/* PASO 1.5: Overlay MANUAL_SELECT_TYPE - Selección | Libre (OverlayOptionsRow) */}
        {blurWizardStep === 'MANUAL_SELECT_TYPE' && (
          <div
            className="absolute z-20"
            style={{
              bottom: '33px',
              left: '50%',
              transform: 'translateX(-50%)',
              width: 'calc(100% - 32px)',
            }}
          >
            <OverlayBox>
              <OverlayOptionsRow
                title="Modo de selección manual"
                mode="text"
                options={[
                  { id: 'select', label: 'Selección' },
                  { id: 'pointer', label: 'Libre' },
                ]}
                selectedId={manualBlurSelectionType === 'select' ? 'select' : manualBlurSelectionType === 'pointer' ? 'pointer' : null}
                onSelect={handleManualBlurSelectionTypeSelect}
                color="white"
              />
            </OverlayBox>
          </div>
        )}

        {/* PASO 1 (continuación): Overlay de selección libre (herramienta pointer) */}
        {blurWizardStep === 'MANUAL_SELECT' && selectedTool === 'pointer' && manualBlurSelectionType === 'pointer' && (
          <FreeSelectionOverlay
            containerWidth={containerSize.width}
            containerHeight={containerSize.height}
            imageWidth={imageRef.current?.naturalWidth || imageRef.current?.width || 0}
            imageHeight={imageRef.current?.naturalHeight || imageRef.current?.height || 0}
            onSelectionComplete={handleManualBlurSelectionComplete}
            onCancel={() => {
              setBlurWizardStep('IDLE');
              setSelectedTool(null);
              setBlurSelectionSource(null);
              setManualBlurSelectionType(null);
              setCurrentBlurRegion(null);
            }}
          />
        )}

        {/* Botón de confirmación para selección por formas en modo manual */}
        {blurWizardStep === 'MANUAL_SELECT' && manualBlurSelectionType === 'select' && showCropOverlay && selectionDimensions && (
          <div
            className="absolute z-20"
            style={{
              bottom: '33px',
              left: '50%',
              transform: 'translateX(-50%)',
              width: 'calc(100% - 32px)',
            }}
          >
            <OverlayBox>
              <OverlayOptionsRow
                title="Confirmación"
                mode="text"
                options={[
                  { id: 'confirm', label: 'Confirmar' },
                  { id: 'cancel', label: 'Cancelar' },
                ]}
                onSelect={(id) => {
                  if (id === 'confirm') {
                    if (imageRef.current && selectionDimensions && containerSize.width > 0 && containerSize.height > 0) {
                      const imageNaturalWidth = imageRef.current.naturalWidth || imageRef.current.width;
                      const imageNaturalHeight = imageRef.current.naturalHeight || imageRef.current.height;
                      
                      const selectionWidthReal = selectionDimensions.width;
                      const selectionHeightReal = selectionDimensions.height;
                      const x = Math.max(0, Math.round((imageNaturalWidth - selectionWidthReal) / 2));
                      const y = Math.max(0, Math.round((imageNaturalHeight - selectionHeightReal) / 2));
                      
                      handleManualBlurSelectionComplete({
                        x,
                        y,
                        width: selectionWidthReal,
                        height: selectionHeightReal,
                      });
                    }
                  } else if (id === 'cancel') {
                    setBlurWizardStep('IDLE');
                    setSelectedTool(null);
                    setBlurSelectionSource(null);
                    setManualBlurSelectionType(null);
                    setCurrentBlurRegion(null);
                    setShowCropOverlay(false);
                    setShowDimensionOptions(false);
                  }
                }}
                color="white"
              />
            </OverlayBox>
          </div>
        )}

        {/* PASO 2: Dial de intensidad de blur */}
        {(() => {
          const shouldShowDial = blurWizardStep === 'DIAL';
          
          return shouldShowDial ? (
            <OverlayDial
              label="Intensidad de blur"
              value={blurIntensity}
              valueText={`${blurIntensity}%`}
              min={0}
              max={100}
              step={1}
              onChange={(val) => {
                const clampedVal = Math.max(0, Math.min(100, val));
                setBlurIntensity(Math.round(clampedVal));
              }}
              onCommit={(val) => {
                applyBlur();
              }}
              isVisible={true}
              onClose={() => {
                setBlurWizardStep('IDLE');
                setCurrentBlurRegion(null);
                setBlurSelectionSource(null);
                setManualBlurSelectionType(null);
              }}
            />
          ) : null;
        })()}

        {/* PASO 3: Overlay ASK_MORE - ¿Desea blurrear otra zona? (Sí | No) */}
        {blurWizardStep === 'ASK_MORE' && (
          <>
            <div 
              className="absolute inset-0 z-10"
              onClick={() => {
                handleBlurAskMoreSelect('no');
              }}
            />
            
            <div
              className="absolute z-20"
              style={{
                bottom: '33px',
                left: '50%',
                transform: 'translateX(-50%)',
                width: 'calc(100% - 32px)',
              }}
            >
              <OverlayBox>
                <OverlayOptionsRow
                  title="¿Desea blurrear otra área?"
                  mode="text"
                  options={[
                    { id: 'yes', label: 'Sí' },
                    { id: 'no', label: 'No' },
                  ]}
                  onSelect={handleBlurAskMoreSelect}
                  color="white"
                />
              </OverlayBox>
            </div>
          </>
        )}
        
        {/* Opciones de dimensiones flotantes (cuando se presiona el botón de selección) - sobre la imagen */}
        {showDimensionOptions && !showCropOverlay && (() => {
          // Íconos SVG inline geométricos para cada proporción
          const Icon9_16 = () => (
            <svg className="w-full h-full" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <rect x="8" y="2" width="8" height="20" rx="1" />
            </svg>
          );
          const Icon1_1 = () => (
            <svg className="w-full h-full" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <rect x="6" y="6" width="12" height="12" rx="1" />
            </svg>
          );
          const Icon16_9 = () => (
            <svg className="w-full h-full" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <rect x="2" y="8" width="20" height="8" rx="1" />
            </svg>
          );
          const Icon4_3 = () => (
            <svg className="w-full h-full" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <rect x="3" y="7" width="18" height="10" rx="1" />
            </svg>
          );
          const IconCircular = () => (
            <svg className="w-full h-full" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <circle cx="12" cy="12" r="8" />
            </svg>
          );

          const dimensionOptions: OverlayOption[] = [
            { id: '9:16', icon: <Icon9_16 />, label: '9:16' },
            { id: '1:1', icon: <Icon1_1 />, label: '1:1' },
            { id: '16:9', icon: <Icon16_9 />, label: '16:9' },
            { id: '4:3', icon: <Icon4_3 />, label: '4:3' },
            { id: 'circular', icon: <IconCircular />, label: 'Circular' },
          ];

          return (
            <>
              {/* Overlay para cerrar al hacer click fuera - NO cerrar, mantener opciones visibles */}
              <div 
                className="absolute inset-0 z-10"
                style={{ pointerEvents: 'none' }}
              />
              
              {/* Contenedor estándar posicionado arriba de la barra blanca */}
              <div
                className="absolute z-30"
                style={{
                  bottom: '33px',
                  left: '50%',
                  transform: 'translateX(-50%)',
                  width: 'calc(100% - 32px)', // Ancho igual al DialButton (con padding del contenedor padre)
                  pointerEvents: 'auto',
                }}
                onClick={(e) => e.stopPropagation()}
              >
                <OverlayBox>
                  <OverlayOptionsRow
                    title=""
                    mode="icon"
                    options={dimensionOptions}
                    selectedId={null}
                    onSelect={(id) => {
                      // Ocultar overlay de opciones después de seleccionar
                      setShowDimensionOptions(false);
                      
                      // Crear selección directa según opción
                      if (id === '9:16') {
                        createQuadSelection(9 / 16);
                      } else if (id === '1:1') {
                        createQuadSelection(1);
                      } else if (id === '16:9') {
                        createQuadSelection(16 / 9);
                      } else if (id === '4:3') {
                        createQuadSelection(4 / 3);
                      } else if (id === 'circular') {
                        createCircleSelection();
                      }
                    }}
                    color={arrowColor === 'white' ? 'white' : 'orange'}
                    align="space-between"
                  />
                </OverlayBox>
              </div>
            </>
          );
        })()}

        {/* Dial de definición - arriba de la barra blanca, sobreimpreso sin fondo */}
        {/* Para crop rectangular */}
        {showDefinitionDial && showCropOverlay && !cropConfirmed && selectionDimensions && selectedDimension !== 'circular' && (
          <OverlayDial
            label="Ancho"
            value={selectionDimensions.width}
            valueText={`${selectionDimensions.width} px`}
            min={50}
            max={imageDimensions ? Math.max(imageDimensions.width, imageDimensions.height) : 4000}
            step={1}
            onChange={(val) => {
              updateDefinition(val);
            }}
            isVisible={true}
            onClose={() => setShowDefinitionDial(false)}
          />
        )}
        

        {/* Dial de tamaño - arriba de la barra blanca, sobreimpreso sin fondo */}
        {showSizeDial && showCropOverlay && !cropConfirmed && selectionDimensions && fileSize > 0 && (
          <OverlayDial
            label="Tamaño"
            value={Math.round(estimateCropFileSize() / 1024)}
            valueText={`${Math.round(estimateCropFileSize() / 1024)} KB`}
            min={10}
            max={10000}
            step={10}
            onChange={(val) => {
              updateFileSize(val);
            }}
            isVisible={true}
            onClose={() => setShowSizeDial(false)}
          />
        )}

        {/* Opciones de formato de archivo - arriba de la barra blanca, sobreimpresas sin fondo */}
        {showFormatOptions && showCropOverlay && !cropConfirmed && (() => {
          const formatOptions: OverlayOption[] = [
            { id: 'jpg', label: '.JPG' },
            { id: 'png', label: '.PNG' },
            { id: 'pdf', label: '.PDF' },
            { id: 'webp', label: '.WEBP' },
          ];

          return (
            <>
              {/* Overlay para cerrar al hacer click fuera */}
              <div 
                className="absolute inset-0 z-10"
                onClick={() => setShowFormatOptions(false)}
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
                    title="Formato de archivo"
                    mode="icon"
                    options={formatOptions}
                    selectedId={selectedFormat}
                    onSelect={(id) => {
                      setSelectedFormat(id);
                      setFileExtension(id);
                      setShowFormatOptions(false);
                    }}
                    color={arrowColor === 'white' ? 'white' : 'orange'}
                  />
                </OverlayBox>
              </div>
            </>
          );
        })()}

        
        {/* CropOverlay antiguo - solo para dimensiones NO circulares */}
        {showCropOverlay && !cropConfirmed && selectedDimension && selectedDimension !== 'circular' && (
          <CropOverlay
            dimension={selectedDimension}
            containerWidth={containerSize.width}
            containerHeight={containerSize.height}
            imageWidth={imageRef.current?.naturalWidth || imageRef.current?.width}
            imageHeight={imageRef.current?.naturalHeight || imageRef.current?.height}
            onSelectionChange={setSelectionDimensions}
            externalDimensions={selectionDimensions}
            containerRef={containerRef}
          />
        )}

        {/* Máscara para círculo - solo visualización */}
        {selectedDimension === 'circular' && circleShape && containerSize.width > 0 && containerSize.height > 0 && (
          <SelectionMaskOverlay
            shape={{
              kind: 'circle',
              center: {
                x: circleShape.x + circleShape.width / 2,
                y: circleShape.y + circleShape.height / 2,
              },
              radius: Math.min(circleShape.width, circleShape.height) / 2,
            }}
            containerWidth={containerSize.width}
            containerHeight={containerSize.height}
            opacity={0.55}
          />
        )}

        {/* Máscara y outline para selección directa QUAD */}
        {selectionVisible && activeSelectionKind === 'quad' && quad && containerSize.width > 0 && containerSize.height > 0 && (() => {
          // Calcular quadEffective usando blend determinista
          // quadUser = quad (manipulado por el usuario)
          // quadTarget = encuadre forzado al formato (centrado y canónico)
          const quadUser = quad;
          const quadTarget = currentCropRatio ? calculateQuadTarget(currentCropRatio) : null;
          
          // Si no hay ratio, usar quadUser directamente (sin blend)
          const quadEffective = quadTarget 
            ? lerpRect(quadUser, quadTarget, cropValue / 100)
            : quadUser;
          
          const maskId = `selection-mask-quad-${Math.random().toString(36).substr(2, 9)}`;
          return (
            <>
              {/* Máscara SVG */}
              <div
                className="absolute inset-0 pointer-events-none"
                style={{
                  width: `${containerSize.width}px`,
                  height: `${containerSize.height}px`,
                  zIndex: 5,
                }}
              >
                <svg
                  className="absolute inset-0"
                  style={{ width: '100%', height: '100%' }}
                >
                  <defs>
                    <mask id={maskId}>
                      {maskInverted ? (
                        // Máscara invertida: fondo negro (visible), área de selección blanca (oscura)
                        <>
                          <rect width="100%" height="100%" fill="black" />
                          <rect
                            x={quadEffective.x}
                            y={quadEffective.y}
                            width={quadEffective.w}
                            height={quadEffective.h}
                            fill="white"
                          />
                        </>
                      ) : (
                        // Máscara normal: fondo blanco (oscuro), área de selección negra (visible)
                        <>
                          <rect width="100%" height="100%" fill="white" />
                          <rect
                            x={quadEffective.x}
                            y={quadEffective.y}
                            width={quadEffective.w}
                            height={quadEffective.h}
                            fill="black"
                          />
                        </>
                      )}
                    </mask>
                  </defs>
                  <rect
                    width="100%"
                    height="100%"
                    fill="rgba(0, 0, 0, 0.55)"
                    mask={`url(#${maskId})`}
                  />
                </svg>
              </div>
              {/* Outline */}
              <svg
                className="absolute inset-0 pointer-events-none"
                style={{
                  width: `${containerSize.width}px`,
                  height: `${containerSize.height}px`,
                  zIndex: 6,
                }}
              >
                <rect
                  x={quadEffective.x}
                  y={quadEffective.y}
                  width={quadEffective.w}
                  height={quadEffective.h}
                  fill="none"
                  stroke="#f97316"
                  strokeWidth="2"
                />
              </svg>
            </>
          );
        })()}

        {/* Máscara y outline para selección directa CIRCLE */}
        {selectionVisible && activeSelectionKind === 'circle' && circle && containerSize.width > 0 && containerSize.height > 0 && (() => {
          const maskId = `selection-mask-circle-${Math.random().toString(36).substr(2, 9)}`;
          return (
            <>
              {/* Máscara SVG */}
              <div
                className="absolute inset-0 pointer-events-none"
                style={{
                  width: `${containerSize.width}px`,
                  height: `${containerSize.height}px`,
                  zIndex: 5,
                }}
              >
                <svg
                  className="absolute inset-0"
                  style={{ width: '100%', height: '100%' }}
                >
                  <defs>
                    <mask id={maskId}>
                      {maskInverted ? (
                        // Máscara invertida: fondo negro (visible), área de selección blanca (oscura)
                        <>
                          <rect width="100%" height="100%" fill="black" />
                          <circle
                            cx={circle.cx}
                            cy={circle.cy}
                            r={circle.r}
                            fill="white"
                          />
                        </>
                      ) : (
                        // Máscara normal: fondo blanco (oscuro), área de selección negra (visible)
                        <>
                          <rect width="100%" height="100%" fill="white" />
                          <circle
                            cx={circle.cx}
                            cy={circle.cy}
                            r={circle.r}
                            fill="black"
                          />
                        </>
                      )}
                    </mask>
                  </defs>
                  <rect
                    width="100%"
                    height="100%"
                    fill="rgba(0, 0, 0, 0.55)"
                    mask={`url(#${maskId})`}
                  />
                </svg>
              </div>
              {/* Outline */}
              <svg
                className="absolute inset-0 pointer-events-none"
                style={{
                  width: `${containerSize.width}px`,
                  height: `${containerSize.height}px`,
                  zIndex: 6,
                }}
              >
                <circle
                  cx={circle.cx}
                  cy={circle.cy}
                  r={circle.r}
                  fill="none"
                  stroke="#f97316"
                  strokeWidth="2"
                />
              </svg>
            </>
          );
        })()}

      </div>

      {/* Main Menu - barra de herramientas justo debajo de la imagen */}
      <EditorMainMenu
        selectedTool={selectedTool}
        onToolChange={(tool) => {
          // REGLA CANÓNICA PARA RESIZER (pointer tool):
          // Cada vez que se selecciona Resizer, SIEMPRE reiniciar completamente,
          // incluso si ya estaba activa. No reutilizar estado previo bajo ninguna circunstancia.
          if (tool === 'pointer') {
            // Resetear completamente la herramienta Resizer
            resetResizerCompletely();
            // Activar la herramienta después del reset
            setSelectedTool('pointer');
          } else {
            // Para otras herramientas, comportamiento normal
            setSelectedTool(tool);
          }
        }}
        selectedDimension={selectedDimension}
        imageAspectRatio={imageAspectRatio}
        onSelectToolClick={handleSelectToolClick}
        onCropClick={handleCropClick}
        onScissorsClick={handleScissorsClick}
        canUndo={historyIndex > 0}
        historyCount={historyIndex}
        onUndo={() => {
          handleUndo();
          setSelectedTool(null);
        }}
        hasChanges={historyIndex > 0}
        onSave={handleSave}
        onHome={handleHome}
        onColorPresetsClick={handleColorPresetsClick}
        onAdjustmentsClick={handleAdjustmentsClick}
        isColorPresetsActive={showColorPresetsOverlay}
        isAdjustmentsActive={showAdjustmentsOverlay}
        isManualPixelSelect={pixelWizardStep === 'MANUAL_SELECT'}
      />

      {/* Herramientas - 6 filas con fondo de color predominante */}
      <div className="overflow-y-auto flex-shrink-0 w-full" style={{ margin: 0, padding: 0, marginTop: 0, paddingTop: 0 }}>
        <div className="space-y-[5.33px] mt-2 px-4 mb-4">
          <button
            onClick={handlePixelateFaceClick}
            className={`
              relative w-full px-3 rounded-sm transition-all duration-300
              h-[30px] flex items-center justify-center
              ${activeControl === 'pixelate' 
                ? 'border-2 border-orange-500 bg-[#1C1C1E]' 
                : 'border-[1px] border-border bg-[#1C1C1E] hover:bg-[#2C2C2E] active:bg-[#2C2C2E]'
              }
              select-none touch-none
            `}
          >
            <span className={`text-xs font-medium ${activeControl === 'pixelate' ? 'text-orange-500' : 'text-white'}`}>
              Pixelar rostro {pixelatedAreas.length > 0 && `(${pixelatedAreas.length})`}
            </span>
          </button>

          <button
            onClick={handleBlurClick}
            className={`
              relative w-full px-3 rounded-sm transition-all duration-300
              h-[30px] flex items-center justify-center
              ${activeControl === 'blur' 
                ? 'border-2 border-orange-500 bg-[#1C1C1E]' 
                : 'border-[1px] border-border bg-[#1C1C1E] hover:bg-[#2C2C2E] active:bg-[#2C2C2E]'
              }
              select-none touch-none
            `}
          >
            <span className={`text-xs font-medium ${activeControl === 'blur' ? 'text-orange-500' : 'text-white'}`}>
              Blur {blurredAreas.length > 0 && `(${blurredAreas.length})`}
            </span>
          </button>

          <DialButton
            label="Intensidad de crop"
            value={cropValue}
            onChange={(val) => {
              if (cropValue !== val) {
                saveToHistory();
                setCropValue(val);
              }
              scheduleClose();
            }}
            active={activeControl === 'crop'}
            onActivate={() => setActiveControl('crop')}
          />

          <ToggleButton
            label="Eliminar metadatos"
            checked={removeMetadata}
            onChange={handleRemoveMetadataChange}
          />

          <button
            onClick={() => {
              if (showWatermarkOverlay) {
                setShowWatermarkOverlay(false);
                setActiveControl(null);
              } else {
                // Cambiar de herramienta
                switchTool('watermark');
                // Asegurar que se activa el overlay
                setShowWatermarkOverlay(true);
              }
            }}
            className={`
              relative w-full px-3 rounded-sm transition-all duration-300
              h-[30px] flex items-center justify-center
              ${watermarkMode !== 'NONE' && watermarkEnabled 
                ? 'border-2 border-orange-500 bg-[#1C1C1E]' 
                : 'border-[1px] border-border bg-[#1C1C1E] hover:bg-[#2C2C2E] active:bg-[#2C2C2E]'
              }
              ${showWatermarkOverlay ? 'ring-2 ring-orange-500/20' : ''}
              select-none touch-none
            `}
          >
            <span className={`text-xs font-medium ${watermarkMode !== 'NONE' && watermarkEnabled ? 'text-orange-500' : 'text-white'}`}>
              Marca de agua {watermarkMode !== 'NONE' && watermarkEnabled && '✓'}
            </span>
          </button>
        </div>

      </div>
    </div>
  );
}