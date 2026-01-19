import { Home, Undo, Save, Pointer, Scissors, RectangleVertical, Square, RectangleHorizontal, Circle, Palette, Sliders } from 'lucide-react';
import { useState } from 'react';

interface EditorMainMenuProps {
  // Herramientas
  selectedTool: 'select' | 'pointer' | null;
  onToolChange: (tool: 'select' | 'pointer' | null) => void;
  selectedDimension: 'vertical' | 'square' | 'landscape' | 'circular' | null;
  imageAspectRatio: 'vertical' | 'square' | 'landscape' | null;
  onSelectToolClick: () => void;
  onCropClick: () => void;
  onScissorsClick?: () => void;
  
  // Historial
  canUndo: boolean;
  historyCount: number;
  onUndo: () => void;
  
  // Save
  hasChanges: boolean;
  onSave: () => void;
  
  // Home
  onHome: () => void;
  
  // Nuevos botones
  onColorPresetsClick: () => void;
  onAdjustmentsClick: () => void;
  isColorPresetsActive?: boolean;
  isAdjustmentsActive?: boolean;
  
  // Restricci?n durante pixelado manual
  isManualPixelSelect?: boolean; // true cuando pixelWizardStep === 'MANUAL_SELECT'
}

export function EditorMainMenu({
  selectedTool,
  onToolChange,
  selectedDimension,
  imageAspectRatio,
  onSelectToolClick,
  onCropClick,
  onScissorsClick,
  canUndo,
  historyCount,
  onUndo,
  hasChanges,
  onSave,
  onHome,
  onColorPresetsClick,
  onAdjustmentsClick,
  isColorPresetsActive = false,
  isAdjustmentsActive = false,
  isManualPixelSelect = false,
}: EditorMainMenuProps) {
  const [pressedButton, setPressedButton] = useState<string | null>(null);

  const handlePress = (buttonId: string) => {
    setPressedButton(buttonId);
    setTimeout(() => setPressedButton(null), 100); // 80-120ms seg?n especificaci?n
  };

  const getSelectIcon = () => {
    if (selectedDimension === 'vertical') {
      return <RectangleVertical className={`w-4 h-4 ${selectedTool === 'select' ? 'text-black' : 'text-white'}`} />;
    } else if (selectedDimension === 'square') {
      return <Square className={`w-4 h-4 ${selectedTool === 'select' ? 'text-black' : 'text-white'}`} />;
    } else if (selectedDimension === 'landscape') {
      return <RectangleHorizontal className={`w-4 h-4 ${selectedTool === 'select' ? 'text-black' : 'text-white'}`} />;
    } else if (selectedDimension === 'circular') {
      return <Circle className={`w-4 h-4 ${selectedTool === 'select' ? 'text-black' : 'text-white'}`} />;
    } else {
      if (imageAspectRatio === 'vertical') {
        return <RectangleVertical className={`w-4 h-4 ${selectedTool === 'select' ? 'text-black' : 'text-white'}`} />;
      } else if (imageAspectRatio === 'square') {
        return <Square className={`w-4 h-4 ${selectedTool === 'select' ? 'text-black' : 'text-white'}`} />;
      } else if (imageAspectRatio === 'landscape') {
        return <RectangleHorizontal className={`w-4 h-4 ${selectedTool === 'select' ? 'text-black' : 'text-white'}`} />;
      } else {
        return <Square className={`w-4 h-4 ${selectedTool === 'select' ? 'text-black' : 'text-white'}`} />;
      }
    }
  };

  const buttonBaseClasses = "flex items-center justify-center transition-transform duration-75";
  const buttonPressedClasses = "scale-[0.96]";
  const disabledClasses = "opacity-40 cursor-not-allowed";

  return (
    <div className="w-full h-[25px] min-h-[25px] bg-orange-500 flex items-center gap-3 px-4 flex-shrink-0" style={{ borderRadius: 0, marginTop: 0, paddingTop: 0 }}>
      {/* Home - al inicio izquierdo */}
      <button
        onClick={() => {
          handlePress('home');
          onHome();
        }}
        className={`${buttonBaseClasses} ${pressedButton === 'home' ? buttonPressedClasses : ''}`}
        style={{ 
          minWidth: '44px', 
          minHeight: '44px',
          padding: '0 8px'
        }}
      >
        <Home className="w-4 h-4 text-white" />
      </button>

      {/* Herramientas existentes en el medio */}
      {/* Bot?n de selecci?n */}
      <button
        onClick={() => {
          handlePress('select');
          onSelectToolClick();
        }}
        className={`${buttonBaseClasses} ${pressedButton === 'select' ? buttonPressedClasses : ''}`}
        style={{ 
          minWidth: '44px', 
          minHeight: '44px',
          padding: '0 8px'
        }}
      >
        {getSelectIcon()}
      </button>

      {/* Bot?n de pointer */}
      <button
        onClick={() => {
          handlePress('pointer');
          onToolChange(selectedTool === 'pointer' ? null : 'pointer');
        }}
        className={`${buttonBaseClasses} ${pressedButton === 'pointer' ? buttonPressedClasses : ''}`}
        style={{ 
          minWidth: '44px', 
          minHeight: '44px',
          padding: '0 8px'
        }}
      >
        <Pointer className={`w-4 h-4 ${selectedTool === 'pointer' ? 'text-black' : 'text-white'}`} />
      </button>

      {/* Bot?n de tijera para cortar la selecci?n */}
      <button
        onClick={() => {
          if (!isManualPixelSelect) {
            handlePress('scissors');
            if (onScissorsClick) {
              onScissorsClick();
            } else {
              onCropClick(); // Fallback para compatibilidad
            }
          }
        }}
        disabled={isManualPixelSelect}
        className={`${buttonBaseClasses} ${pressedButton === 'scissors' ? buttonPressedClasses : ''} ${isManualPixelSelect ? disabledClasses : ''}`}
        style={{ 
          minWidth: '44px', 
          minHeight: '44px',
          padding: '0 8px',
          pointerEvents: isManualPixelSelect ? 'none' : 'auto'
        }}
      >
        <Scissors className={`w-4 h-4 ${isManualPixelSelect ? 'text-white opacity-40' : 'text-white'}`} />
      </button>

      {/* Bot?n de Color Presets */}
      <button
        onClick={() => {
          if (!isManualPixelSelect) {
            handlePress('colorPresets');
            onColorPresetsClick();
          }
        }}
        disabled={isManualPixelSelect}
        className={`${buttonBaseClasses} ${pressedButton === 'colorPresets' ? buttonPressedClasses : ''} ${isManualPixelSelect ? disabledClasses : ''}`}
        style={{ 
          minWidth: '44px', 
          minHeight: '44px',
          padding: '0 8px',
          pointerEvents: isManualPixelSelect ? 'none' : 'auto'
        }}
      >
        <Palette className={`w-4 h-4 ${isManualPixelSelect ? 'text-white opacity-40' : (isColorPresetsActive ? 'text-black' : 'text-white')}`} />
      </button>

      {/* Bot?n de Ajustes Cl?sicos */}
      <button
        onClick={() => {
          if (!isManualPixelSelect) {
            handlePress('adjustments');
            onAdjustmentsClick();
          }
        }}
        disabled={isManualPixelSelect}
        className={`${buttonBaseClasses} ${pressedButton === 'adjustments' ? buttonPressedClasses : ''} ${isManualPixelSelect ? disabledClasses : ''}`}
        style={{ 
          minWidth: '44px', 
          minHeight: '44px',
          padding: '0 8px',
          pointerEvents: isManualPixelSelect ? 'none' : 'auto'
        }}
      >
        <Sliders className={`w-4 h-4 ${isManualPixelSelect ? 'text-white opacity-40' : (isAdjustmentsActive ? 'text-black' : 'text-white')}`} />
      </button>

      {/* Undo - antes de Save */}
      <button
        onClick={() => {
          if (canUndo && !isManualPixelSelect) {
            handlePress('undo');
            onUndo();
          }
        }}
        disabled={!canUndo || isManualPixelSelect}
        className={`${buttonBaseClasses} ${pressedButton === 'undo' ? buttonPressedClasses : ''} ${(!canUndo || isManualPixelSelect) ? disabledClasses : ''}`}
        style={{ 
          minWidth: '44px', 
          minHeight: '44px',
          padding: '0 8px',
          pointerEvents: isManualPixelSelect ? 'none' : 'auto'
        }}
      >
        <Undo className={`w-4 h-4 ${(canUndo && !isManualPixelSelect) ? 'text-white' : 'text-white opacity-40'}`} />
      </button>

      {/* Save - al extremo derecho */}
      <button
        onClick={() => {
          if (hasChanges && !isManualPixelSelect) {
            handlePress('save');
            onSave();
          }
        }}
        disabled={!hasChanges || isManualPixelSelect}
        className={`${buttonBaseClasses} ${pressedButton === 'save' ? buttonPressedClasses : ''} ${(!hasChanges || isManualPixelSelect) ? disabledClasses : ''} ml-auto`}
        style={{ 
          minWidth: '44px', 
          minHeight: '44px',
          padding: '0 8px',
          pointerEvents: isManualPixelSelect ? 'none' : 'auto'
        }}
      >
        <Save className={`w-4 h-4 ${(hasChanges && !isManualPixelSelect) ? 'text-white' : 'text-white opacity-40'}`} />
      </button>
    </div>
  );
}
