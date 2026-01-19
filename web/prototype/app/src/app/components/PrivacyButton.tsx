import { useState } from 'react';

interface PrivacyButtonProps {
  label: string;
  isActive: boolean;
  onClick: () => void;
}

export function PrivacyButton({ 
  label, 
  isActive,
  onClick
}: PrivacyButtonProps) {
  const [pressed, setPressed] = useState(false);

  const handleClick = () => {
    setPressed(true);
    setTimeout(() => setPressed(false), 100);
    onClick();
  };

  return (
    <button
      onClick={handleClick}
      className={`
        relative w-full px-3 rounded-sm transition-all duration-300
        h-[33px] flex items-center justify-center
        ${isActive 
          ? 'border-2 border-orange-500 bg-[#1C1C1E]' 
          : 'border-[1px] border-border bg-[#1C1C1E] hover:bg-[#2C2C2E] active:bg-[#2C2C2E]'
        }
        ${pressed ? 'scale-[0.96]' : ''}
        select-none touch-none
      `}
    >
      <span className={`text-xs font-medium ${isActive ? 'text-orange-500' : 'text-white'}`}>
        {label} {isActive && '✓'}
      </span>
    </button>
  );
}
