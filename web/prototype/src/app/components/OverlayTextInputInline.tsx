import { useState, useRef, useEffect } from 'react';

interface OverlayTextInputInlineProps {
  initialText?: string;
  onConfirm: (text: string) => void;
  onCancel?: () => void;
  placeholder?: string;
}

/**
 * Componente para ingreso de texto DENTRO del OverlayBox.
 * 
 * Características:
 * - Input editable con cursor titilando
 * - Placeholder opcional
 * - Ícono ✔ alineado a la derecha para confirmar
 * - Confirmar con click en ✔ o Enter
 * - Mantiene altura 40px, fondo oscuro transparente, tipografía igual al resto
 */
export function OverlayTextInputInline({
  initialText = '',
  onConfirm,
  onCancel,
  placeholder = 'Ingrese texto…',
}: OverlayTextInputInlineProps) {
  const [text, setText] = useState(initialText);
  const inputRef = useRef<HTMLInputElement>(null);

  // Auto-focus al montar
  useEffect(() => {
    inputRef.current?.focus();
  }, []);

  const handleConfirm = () => {
    if (text.trim()) {
      onConfirm(text.trim());
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
    <div 
      className="w-full flex items-center gap-2"
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
        className="flex-1 bg-transparent border-none outline-none text-white text-sm font-medium placeholder:text-white/50"
        style={{
          caretColor: 'white',
        }}
      />
      
      {/* Ícono ✔ para confirmar */}
      <button
        onClick={handleConfirm}
        className="text-white hover:text-orange-500 transition-colors flex items-center justify-center min-w-[24px] min-h-[24px]"
        aria-label="Confirmar"
      >
        <svg
          width="16"
          height="16"
          viewBox="0 0 16 16"
          fill="none"
          xmlns="http://www.w3.org/2000/svg"
          className="w-4 h-4"
        >
          <path
            d="M13.5 4.5L6 12L2.5 8.5"
            stroke="currentColor"
            strokeWidth="2"
            strokeLinecap="round"
            strokeLinejoin="round"
          />
        </svg>
      </button>
    </div>
  );
}
