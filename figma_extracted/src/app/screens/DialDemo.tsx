import { useState, useRef, useEffect } from 'react';
import { ArrowLeft, Save, Undo, SquareDashed, Pointer, Image as ImageIcon, Video, Scissors, ChevronLeft, ChevronRight, RectangleVertical, Square, RectangleHorizontal, Circle, ChevronDown } from 'lucide-react';
import { DialButton } from '@/app/components/DialButton';
import { ClassicAdjustments, initialClassicAdjustments } from '@/app/components/ClassicAdjustments';
import { ColorModeButton } from '@/app/components/ColorModeButton';
import { CropOverlay } from '@/app/components/CropOverlay';

interface DialDemoProps {
  imageUrl?: string;
  onImageSelect: (file: File) => void;
  onVideoSelect: (file: File) => void;
  onBack: () => void;
}

type ToolMode = 'select' | 'pointer' | 'undo' | null;
type ActiveControl = 'pixelate' | 'blur' | 'crop' | 'dimension' | 'adjustments' | null;

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
  
  // Estado para almacenar la información de la versión confirmada
  const [confirmedVersionInfo, setConfirmedVersionInfo] = useState<{
    fileName: string;
    dimensions: { width: number; height: number };
    fileSize: number;
    dimensionType: 'vertical' | 'square' | 'landscape' | 'circular' | null;
  } | null>(null);
  
  // Estado para manejar versiones y navegación
  const [currentVersionIndex, setCurrentVersionIndex] = useState<number>(-1); // -1 significa imagen original
  const [versions, setVersions] = useState<Array<{
    fileName: string;
    dimensions: { width: number; height: number };
    fileSize: number;
    dimensionType: 'vertical' | 'square' | 'landscape' | 'circular' | null;
    imageUrl: string; // URL de la imagen recortada
  }>>([]);
  
  // Estado para la URL de la imagen actual (puede ser original o una versión)
  const [currentImageUrl, setCurrentImageUrl] = useState<string | undefined>(imageUrl);

  // Tool mode state
  const [selectedTool, setSelectedTool] = useState<ToolMode>(null);

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
    isCircular: boolean
  ): Promise<string> => {
    return new Promise((resolve, reject) => {
      const canvas = document.createElement('canvas');
      const ctx = canvas.getContext('2d');
      if (!ctx) {
        reject(new Error('No se pudo obtener el contexto del canvas'));
        return;
      }

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

  // Función para cortar la selección
  const handleCrop = async () => {
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
        isCircular
      );
      
      const newVersion = {
        fileName: getSelectionFileName(),
        dimensions: selectionDimensions,
        fileSize: estimateCropFileSize(),
        dimensionType: selectedDimension,
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
      
      console.log('Cortar selección confirmada');
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
    } else if (currentVersionIndex === 0) {
      // Volver a la imagen original
      setCurrentVersionIndex(-1);
      setConfirmedVersionInfo(null);
      setCurrentImageUrl(imageUrl);
      setCropConfirmed(false);
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
    }
  };
  
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
    if (cropConfirmed && confirmedVersionInfo) {
      return confirmedVersionInfo;
    }
    return null;
  };
  
  const currentInfo = getCurrentInfo();

  const handleVideoChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      onVideoSelect(file);
    }
  };

  const handleSave = () => {
    console.log('Guardando imagen con ajustes:', {
      pixelate: pixelateValue,
      blur: blurValue,
      crop: cropValue,
      dimension: selectedDimension,
      pixels: dimensionPixels,
      colorMode: selectedColorMode,
      adjustments: classicAdjustments,
    });
    alert('Imagen guardada (simulación)');
  };

  // Estado inicial: sin imagen cargada
  if (!imageUrl) {
    return (
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
          </>
        )}
      </div>

      {/* Barra blanca - información de selección o ayuda */}
      <div className="w-full h-[25px] min-h-[25px] bg-white flex items-center gap-3 px-4 flex-shrink-0 overflow-hidden" style={{ borderRadius: 0, marginTop: 0, paddingTop: 0 }}>
        {showCropOverlay && !cropConfirmed ? (
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
                  if (selectedTool === 'select') {
                    return 'Selecciona una forma de recorte: vertical, cuadrado, apaisada o circular';
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
          justifyContent: 'center'
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
            paddingTop: 0
          }}
          onLoad={extractDominantColor}
          crossOrigin="anonymous"
        />
        
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
        
        {/* Opciones de dimensiones flotantes (cuando se presiona el botón de selección) - sobre la imagen */}
        {showDimensionOptions && (
          <>
            {/* Overlay para cerrar al hacer click fuera */}
            <div 
              className="absolute inset-0 z-10"
              onClick={() => setShowDimensionOptions(false)}
            />
            <div 
              className="absolute flex items-center gap-4 z-20"
              style={{
                bottom: '30px', // Justo arriba de la barra de menú
                left: '50%',
                transform: 'translateX(-50%)'
              }}
              onClick={(e) => e.stopPropagation()}
            >
              <button
                onClick={() => {
                  saveToHistory();
                  setSelectedDimension('vertical');
                  setShowDimensionOptions(false);
                  setShowCropOverlay(true);
                  setSelectedTool('select');
                }}
                className="flex items-center justify-center p-2 transition-opacity hover:opacity-80"
                title="Vertical"
              >
                <RectangleVertical className={`w-8 h-8 ${arrowColor === 'white' ? 'text-white' : 'text-orange-500'}`} />
              </button>
              
              <button
                onClick={() => {
                  saveToHistory();
                  setSelectedDimension('square');
                  setShowDimensionOptions(false);
                  setShowCropOverlay(true);
                  setSelectedTool('select');
                }}
                className="flex items-center justify-center p-2 transition-opacity hover:opacity-80"
                title="Cuadrada"
              >
                <Square className={`w-8 h-8 ${arrowColor === 'white' ? 'text-white' : 'text-orange-500'}`} />
              </button>
              
              <button
                onClick={() => {
                  saveToHistory();
                  setSelectedDimension('landscape');
                  setShowDimensionOptions(false);
                  setShowCropOverlay(true);
                  setSelectedTool('select');
                }}
                className="flex items-center justify-center p-2 transition-opacity hover:opacity-80"
                title="Apaisada"
              >
                <RectangleHorizontal className={`w-8 h-8 ${arrowColor === 'white' ? 'text-white' : 'text-orange-500'}`} />
              </button>
              
              <button
                onClick={() => {
                  saveToHistory();
                  setSelectedDimension('circular');
                  setShowDimensionOptions(false);
                  setShowCropOverlay(true);
                  setSelectedTool('select');
                }}
                className="flex items-center justify-center p-2 transition-opacity hover:opacity-80"
                title="Circular"
              >
                <Circle className={`w-8 h-8 ${arrowColor === 'white' ? 'text-white' : 'text-orange-500'}`} />
              </button>
            </div>
          </>
        )}

        {/* Dial de definición - arriba de la barra blanca, sobreimpreso sin fondo */}
        {showDefinitionDial && showCropOverlay && !cropConfirmed && selectionDimensions && (
          <>
            {/* Overlay para cerrar al hacer click fuera */}
            <div 
              className="absolute inset-0 z-10"
              onClick={() => setShowDefinitionDial(false)}
            />
            <div 
              className="absolute flex items-center gap-3 z-20 bg-transparent"
              style={{
                bottom: '30px', // Justo arriba de la barra blanca
                left: '50%',
                transform: 'translateX(-50%)'
              }}
              onClick={(e) => e.stopPropagation()}
            >
              <div className="flex items-center gap-3 px-4 py-2 bg-transparent">
                <span className="text-xs font-medium text-orange-500 whitespace-nowrap">
                  {selectedDimension === 'circular' ? 'Diámetro' : 'Ancho'}
                </span>
                <div className="flex-1 relative h-1.5 bg-white/20 rounded-full overflow-hidden" style={{ minWidth: '150px' }}>
                  <div 
                    className="absolute top-0 left-0 h-full bg-orange-500 transition-all duration-75"
                    style={{ 
                      width: `${Math.min(100, Math.max(0, ((selectionDimensions.width - 50) / (imageDimensions ? Math.max(imageDimensions.width, imageDimensions.height) - 50 : 3950)) * 100))}%` 
                    }}
                  />
                </div>
                <input
                  type="number"
                  value={selectedDimension === 'circular' 
                    ? Math.min(selectionDimensions.width, selectionDimensions.height)
                    : selectionDimensions.width
                  }
                  onChange={(e) => {
                    const newValue = parseInt(e.target.value) || 200;
                    updateDefinition(newValue);
                  }}
                  min="50"
                  max={imageDimensions ? Math.max(imageDimensions.width, imageDimensions.height) : 4000}
                  className="text-xs font-bold text-orange-500 bg-transparent border-none outline-none w-20 text-right"
                  style={{ color: '#f97316' }}
                />
                <span className="text-xs font-medium text-orange-500">px</span>
              </div>
            </div>
          </>
        )}

        {/* Dial de tamaño - arriba de la barra blanca, sobreimpreso sin fondo */}
        {showSizeDial && showCropOverlay && !cropConfirmed && selectionDimensions && fileSize > 0 && (
          <>
            {/* Overlay para cerrar al hacer click fuera */}
            <div 
              className="absolute inset-0 z-10"
              onClick={() => setShowSizeDial(false)}
            />
            <div 
              className="absolute flex items-center gap-3 z-20 bg-transparent"
              style={{
                bottom: '30px', // Justo arriba de la barra blanca
                left: '50%',
                transform: 'translateX(-50%)'
              }}
              onClick={(e) => e.stopPropagation()}
            >
              <div className="flex items-center gap-3 px-4 py-2 bg-transparent">
                <span className="text-xs font-medium text-orange-500 whitespace-nowrap">Tamaño</span>
                <div className="flex-1 relative h-1.5 bg-white/20 rounded-full overflow-hidden" style={{ minWidth: '150px' }}>
                  <div 
                    className="absolute top-0 left-0 h-full bg-orange-500 transition-all duration-75"
                    style={{ 
                      width: `${Math.min(100, Math.max(0, ((estimateCropFileSize() / 1024 - 10) / 9990) * 100))}%` 
                    }}
                  />
                </div>
                <input
                  type="number"
                  value={Math.round(estimateCropFileSize() / 1024)}
                  onChange={(e) => {
                    const newValueKB = parseFloat(e.target.value) || 10;
                    updateFileSize(newValueKB);
                  }}
                  min="10"
                  max="10000"
                  step="10"
                  className="text-xs font-bold text-orange-500 bg-transparent border-none outline-none w-20 text-right"
                  style={{ color: '#f97316' }}
                />
                <span className="text-xs font-medium text-orange-500">KB</span>
              </div>
            </div>
          </>
        )}

        {/* Opciones de formato de archivo - arriba de la barra blanca, sobreimpresas sin fondo */}
        {showFormatOptions && showCropOverlay && !cropConfirmed && (
          <>
            {/* Overlay para cerrar al hacer click fuera */}
            <div 
              className="absolute inset-0 z-10"
              onClick={() => setShowFormatOptions(false)}
            />
            <div 
              className="absolute flex items-center gap-3 z-20"
              style={{
                bottom: '30px', // Justo arriba de la barra blanca
                left: '50%',
                transform: 'translateX(-50%)'
              }}
              onClick={(e) => e.stopPropagation()}
            >
              <button
                onClick={() => {
                  setSelectedFormat('jpg');
                  setFileExtension('jpg');
                  setShowFormatOptions(false);
                }}
                className={`text-xs font-medium hover:opacity-80 transition-opacity px-2 py-1 ${arrowColor === 'white' ? 'text-white' : 'text-orange-500'} ${selectedFormat === 'jpg' ? 'opacity-100 font-bold' : 'opacity-80'}`}
              >
                .JPG
              </button>
              <button
                onClick={() => {
                  setSelectedFormat('png');
                  setFileExtension('png');
                  setShowFormatOptions(false);
                }}
                className={`text-xs font-medium hover:opacity-80 transition-opacity px-2 py-1 ${arrowColor === 'white' ? 'text-white' : 'text-orange-500'} ${selectedFormat === 'png' ? 'opacity-100 font-bold' : 'opacity-80'}`}
              >
                .PNG
              </button>
              <button
                onClick={() => {
                  setSelectedFormat('pdf');
                  setFileExtension('pdf');
                  setShowFormatOptions(false);
                }}
                className={`text-xs font-medium hover:opacity-80 transition-opacity px-2 py-1 ${arrowColor === 'white' ? 'text-white' : 'text-orange-500'} ${selectedFormat === 'pdf' ? 'opacity-100 font-bold' : 'opacity-80'}`}
              >
                .PDF
              </button>
              <button
                onClick={() => {
                  setSelectedFormat('webp');
                  setFileExtension('webp');
                  setShowFormatOptions(false);
                }}
                className={`text-xs font-medium hover:opacity-80 transition-opacity px-2 py-1 ${arrowColor === 'white' ? 'text-white' : 'text-orange-500'} ${selectedFormat === 'webp' ? 'opacity-100 font-bold' : 'opacity-80'}`}
              >
                .WEBP
              </button>
            </div>
          </>
        )}

        
        {showCropOverlay && !cropConfirmed && selectedDimension && (
          <CropOverlay
            dimension={selectedDimension}
            containerWidth={containerSize.width}
            containerHeight={containerSize.height}
            imageWidth={imageRef.current?.naturalWidth || imageRef.current?.width}
            imageHeight={imageRef.current?.naturalHeight || imageRef.current?.height}
            onSelectionChange={setSelectionDimensions}
            externalDimensions={selectionDimensions}
          />
        )}

      </div>

      {/* Primera barra de herramientas - justo debajo de la imagen */}
      <div className="w-full h-[25px] min-h-[25px] bg-orange-500 flex items-center justify-center gap-3 px-4 flex-shrink-0" style={{ borderRadius: 0, marginTop: 0, paddingTop: 0 }}>
          <button
            onClick={() => {
              if (selectedTool === 'select' && showCropOverlay) {
                // Si ya está activo, ocultar el overlay y mostrar las opciones
                setShowCropOverlay(false);
                setShowDimensionOptions(true);
              } else {
                // Activar herramienta de selección
                setSelectedTool('select');
                
                // Si no hay dimensión seleccionada y tenemos la proporción de la imagen, establecerla automáticamente
                if (!selectedDimension && imageAspectRatio) {
                  if (imageAspectRatio === 'vertical') {
                    setSelectedDimension('vertical');
                  } else if (imageAspectRatio === 'square') {
                    setSelectedDimension('square');
                  } else if (imageAspectRatio === 'landscape') {
                    setSelectedDimension('landscape');
                  }
                  setShowCropOverlay(true);
                } else {
                  // Mostrar opciones si ya hay una dimensión seleccionada o no tenemos la proporción
                  setShowDimensionOptions(true);
                }
              }
            }}
            className="flex items-center justify-center h-full px-2"
            title="Selección"
          >
{(() => {
              // Si hay una dimensión seleccionada, mostrar su icono
              if (selectedDimension === 'vertical') {
                return <RectangleVertical className={`w-4 h-4 ${selectedTool === 'select' ? 'text-black' : 'text-white'}`} />;
              } else if (selectedDimension === 'square') {
                return <Square className={`w-4 h-4 ${selectedTool === 'select' ? 'text-black' : 'text-white'}`} />;
              } else if (selectedDimension === 'landscape') {
                return <RectangleHorizontal className={`w-4 h-4 ${selectedTool === 'select' ? 'text-black' : 'text-white'}`} />;
              } else if (selectedDimension === 'circular') {
                return <Circle className={`w-4 h-4 ${selectedTool === 'select' ? 'text-black' : 'text-white'}`} />;
              } else {
                // Si no hay dimensión seleccionada, usar la dimensión de la imagen
                if (imageAspectRatio === 'vertical') {
                  return <RectangleVertical className={`w-4 h-4 ${selectedTool === 'select' ? 'text-black' : 'text-white'}`} />;
                } else if (imageAspectRatio === 'square') {
                  return <Square className={`w-4 h-4 ${selectedTool === 'select' ? 'text-black' : 'text-white'}`} />;
                } else if (imageAspectRatio === 'landscape') {
                  return <RectangleHorizontal className={`w-4 h-4 ${selectedTool === 'select' ? 'text-black' : 'text-white'}`} />;
                } else {
                  // Fallback por defecto (cuadrado)
                  return <Square className={`w-4 h-4 ${selectedTool === 'select' ? 'text-black' : 'text-white'}`} />;
                }
              }
            })()}
          </button>
          
          <button
            onClick={() => setSelectedTool(selectedTool === 'pointer' ? null : 'pointer')}
            className="flex items-center justify-center h-full px-2"
            title="Dedo"
          >
            <Pointer className={`w-4 h-4 ${selectedTool === 'pointer' ? 'text-black' : 'text-white'}`} />
          </button>
          
          {/* Botón de tijera para cortar la selección */}
          <button
            onClick={handleCrop}
            className="flex items-center justify-center h-full px-2"
            title="Cortar selección"
          >
            <Scissors className="w-4 h-4 text-white" />
          </button>
          
          {/* Botón de deshacer - fijo, siempre visible */}
          <button
            onClick={() => {
              handleUndo();
              setSelectedTool(null);
            }}
            disabled={historyIndex <= 0}
            className="flex items-center justify-center h-full px-2 ml-auto disabled:opacity-30 disabled:cursor-not-allowed"
            title={`Deshacer${historyIndex > 0 ? ` (${historyIndex} disponible${historyIndex > 1 ? 's' : ''})` : ''}`}
          >
            <Undo className={`w-4 h-4 ${historyIndex > 0 ? 'text-white' : 'text-white opacity-30'}`} />
          </button>
        </div>

      {/* Herramientas - 6 filas con fondo de color predominante */}
      <div className="overflow-y-auto flex-shrink-0 w-full" style={{ margin: 0, padding: 0, marginTop: 0, paddingTop: 0 }}>
        <div className="space-y-2 mt-2 px-4">
          <DialButton
            label="Pixelar rostro"
            value={pixelateValue}
            onChange={(val) => {
              if (pixelateValue !== val) {
                saveToHistory();
                setPixelateValue(val);
              }
              scheduleClose();
            }}
            active={activeControl === 'pixelate'}
            onActivate={() => setActiveControl('pixelate')}
          />

          <DialButton
            label="Blur selectivo"
            value={blurValue}
            onChange={(val) => {
              if (blurValue !== val) {
                saveToHistory();
                setBlurValue(val);
              }
              scheduleClose();
            }}
            active={activeControl === 'blur'}
            onActivate={() => setActiveControl('blur')}
          />

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


          <ColorModeButton
            selectedMode={selectedColorMode}
            onChange={(mode) => {
              if (selectedColorMode !== mode) {
                saveToHistory();
                setSelectedColorMode(mode);
              }
            }}
          />

          <ClassicAdjustments
            values={classicAdjustments}
            onChange={(val) => {
              setClassicAdjustments(val);
              scheduleClose();
            }}
            active={activeControl === 'adjustments'}
            onActivate={() => setActiveControl('adjustments')}
          />
        </div>

        {/* Fila de botones Volver y Grabar */}
        <div className="grid grid-cols-2 gap-2 mt-2 px-4 mb-4">
          <button
            onClick={onBack}
            className="flex items-center justify-center gap-1.5 rounded-md bg-orange-500 text-white hover:text-black active:text-black transition-colors px-2"
            style={{ height: '25px', minHeight: '25px', maxHeight: '25px' }}
          >
            <ArrowLeft className="w-3.5 h-3.5" />
            <span className="text-xs font-medium">Volver</span>
          </button>
          
          <button
            onClick={handleSave}
            className="flex items-center justify-center gap-1.5 rounded-md bg-orange-500 text-white hover:text-black active:text-black transition-colors px-2"
            style={{ height: '25px', minHeight: '25px', maxHeight: '25px' }}
          >
            <Save className="w-3.5 h-3.5" />
            <span className="text-xs font-medium">Grabar</span>
          </button>
        </div>
      </div>
    </div>
  );
}