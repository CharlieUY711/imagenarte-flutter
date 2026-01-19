import { useState, useRef, useEffect } from 'react';

interface OverlayTextInputProps {
  initialText?: string;
  initialPosition?: { x: number; y: number };
  onConfirm: (text: string, position: { x: number; y: number }) => void;
  onCancel?: () => void;
  placeholder?: string;
}

/**
 * Componente para ingreso de texto sobre la imagen
 * - Cursor titilando
 * - Tilde (✔) en el extremo derecho para confirmar
 * - Posicionado donde el usuario toque o centrado
 */
export function OverlayTextInput({
  initialText = '',
  initialPosition,
  onConfirm,
  onCancel,
  placeholder = 'Escribe aquí...',
}: OverlayTextInputProps) {
  const [text, setText] = useState(initialText);
  const [position, setPosition] = useState<{ x: number; y: number }>(
    initialPosition || { x: 50, y: 50 }
  );
  const inputRef = useRef<HTMLInputElement>(null);
  const containerRef = useRef<HTMLDivElement>(null);

  // Auto-focus al montar
  useEffect(() => {
    inputRef.current?.focus();
  }, []);

  // Manejar click en la imagen para posicionar el input
  useEffect(() => {
    const handleImageClick = (e: MouseEvent) => {
      const target = e.target as HTMLElement;
      if (target.tagName === 'IMG' && containerRef.current) {
        const rect = target.getBoundingClientRect();
        const x = ((e.clientX - rect.left) / rect.width) * 100;
        const y = ((e.clientY - rect.top) / rect.height) * 100;
        setPosition({ x, y });
        inputRef.current?.focus();
      }
    };

    const image = document.querySelector('.preview-image-container img');
    if (image) {
      image.addEventListener('click', handleImageClick);
      return () => image.removeEventListener('click', handleImageClick);
    }
  }, []);


  const handleConfirm = () => {
    if (text.trim()) {
      onConfirm(text.trim(), position);
    } else if (onCancel) {
      onCancel();
    }
  };

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleConfirm();
    } else if (e.key === 'Escape' && onCancel) {
      onCancel();
    }
  };

  return (
    <>
      {/* Overlay para cerrar al hacer click fuera */}
      {onCancel && (
        <div 
          className="absolute inset-0 z-10"
          onClick={onCancel}
        />
      )}
      
      {/* Contenedor del input - posicionado sobre la imagen */}
      <div
        ref={containerRef}
        className="absolute z-20 flex items-center gap-2 bg-transparent"
        style={{
          left: `${position.x}%`,
          top: `${position.y}%`,
          transform: 'translate(-50%, -50%)',
        }}
        onClick={(e) => e.stopPropagation()}
      >
        {/* Input de texto */}
        <input
          ref={inputRef}
          type="text"
          value={text}
          onChange={(e) => setText(e.target.value)}
          onKeyDown={handleKeyDown}
          placeholder={placeholder}
          className="bg-transparent border-none outline-none text-white text-lg font-medium placeholder:text-white/50 min-w-[100px] max-w-[300px]"
          style={{
            textShadow: '0 1px 3px rgba(0,0,0,0.8)',
            caretColor: 'white',
          }}
        />
        
        {/* Cursor titilante (simulado con animación) */}
        {inputRef.current === document.activeElement && (
          <span 
            className="inline-block w-0.5 h-5 bg-white ml-1 animate-pulse"
            style={{
              animation: 'blink 1s infinite',
            }}
          />
        )}
      </div>
      
      {/* Estilos para el cursor titilante */}
      <style>{`
        @keyframes blink {
          0%, 50% { opacity: 1; }
          51%, 100% { opacity: 0; }
        }
      `}</style>
    </>
  );
}
