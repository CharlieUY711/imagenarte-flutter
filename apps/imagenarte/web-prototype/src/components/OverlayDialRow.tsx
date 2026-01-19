import React from 'react';

interface OverlayDialRowProps {
  label: string;
  value: number;
  min: number;
  max: number;
  formatValue?: (value: number) => string;
  disabled?: boolean;
  onChange?: (value: number) => void;
  onChangeEnd?: (value: number) => void;
}

/**
 * Componente canónico para ajustes con dial/slider en el overlay panel
 * 
 * Formato:
 * - Header: label izquierda naranja + value derecha
 * - Slider debajo que ocupa todo el ancho
 * - Track activo naranja, inactivo gris
 * - Thumb naranja
 */
export const OverlayDialRow: React.FC<OverlayDialRowProps> = ({
  label,
  value,
  min,
  max,
  formatValue = (val) => `${Math.round(val)}%`,
  disabled = false,
  onChange,
  onChangeEnd,
}) => {
  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const newValue = parseFloat(e.target.value);
    onChange?.(newValue);
  };

  const handleChangeEnd = (e: React.ChangeEvent<HTMLInputElement>) => {
    const newValue = parseFloat(e.target.value);
    onChangeEnd?.(newValue);
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
      {/* Header: label izquierda + value derecha */}
      <div
        style={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
        }}
      >
        <span
          style={{
            fontSize: '12px',
            fontWeight: 600,
            color: '#FF6B35', // Accent color (naranja)
          }}
        >
          {label}
        </span>
        <span
          style={{
            fontSize: '12px',
            fontWeight: 500,
            color: 'rgba(255, 255, 255, 0.7)',
          }}
        >
          {formatValue(value)}
        </span>
      </div>

      {/* Slider */}
      <input
        type="range"
        min={min}
        max={max}
        value={value}
        onChange={handleChange}
        onMouseUp={handleChangeEnd}
        onTouchEnd={handleChangeEnd}
        disabled={disabled}
        style={{
          width: '100%',
          height: '4px',
          appearance: 'none',
          background: disabled
            ? 'rgba(255, 255, 255, 0.2)'
            : `linear-gradient(to right, #FF6B35 0%, #FF6B35 ${((value - min) / (max - min)) * 100}%, rgba(255, 255, 255, 0.2) ${((value - min) / (max - min)) * 100}%, rgba(255, 255, 255, 0.2) 100%)`,
          borderRadius: '2px',
          outline: 'none',
          cursor: disabled ? 'not-allowed' : 'pointer',
        }}
      />
    </div>
  );
};
