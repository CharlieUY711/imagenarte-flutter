# Nuevos Dial Buttons - Dimensión y Modo de Color

## 📐 DimensionButton - Selección + Dial Condicional

**Archivo:** `DimensionButton.tsx`

### Concepto

Botón que permite:
1. **Seleccionar orientación:** Vertical, Cuadrada, Apaisada
2. **Ajustar píxeles:** Al seleccionar una opción → se activa dial
3. **Cálculo proporcional:** El segundo valor se calcula automáticamente

---

### Estados Visuales

#### Estado 1: Selección (sin selección)

```
┌─────────────────────────────────────┐
│           Dimensión                 │
│                                     │
│   📱        ⬜        📺            │  ← 3 opciones
│ Vertical  Cuadrada  Apaisada        │
│                                     │
└─────────────────────────────────────┘
```

---

#### Estado 2: Selección activa (Vertical seleccionada)

```
┌─────────────────────────────────────┐
│           Dimensión                 │
│                                     │
│   📱        ⬜        📺            │
│ Vertical  Cuadrada  Apaisada        │
│           ↑ destacada               │
│         600×800px                   │  ← Dimensiones calculadas
└─────────────────────────────────────┘
```

**Características:**
- Opción seleccionada en primary con border
- Otras opciones con opacity 40% (desactivadas)
- Muestra dimensiones calculadas abajo

---

#### Estado 3: Usuario toca la opción seleccionada → Dial activo

```
┌─────────────────────────────────────┐
│ Vertical (3:4)              800px   │  ← Label + valor
│                                     │
│ ████████████████░░░░░░░░░░░         │  ← Dial
│ ← Desliza →          600×800px      │  ← Hint + dimensiones
└─────────────────────────────────────┘
```

**Características:**
- Todos los iconos desaparecen
- Muestra dial de píxeles (200-2000px)
- Cálculo proporcional en tiempo real
- Border 2px primary

---

#### Estado 4: Usuario suelta → Vuelve a selección

```
┌─────────────────────────────────────┐
│           Dimensión                 │
│                                     │
│   📱        ⬜        📺            │
│ Vertical  Cuadrada  Apaisada        │
│           ↑ destacada               │
│         675×900px                   │  ← Nuevo valor
└─────────────────────────────────────┘
```

---

### Proporciones y Cálculos

**Vertical (3:4):**
```typescript
width = pixels * 0.75
height = pixels
// Si pixels = 800 → 600×800px
```

**Cuadrada (1:1):**
```typescript
width = pixels
height = pixels
// Si pixels = 800 → 800×800px
```

**Apaisada (4:3):**
```typescript
width = pixels
height = pixels * 0.75
// Si pixels = 800 → 800×600px
```

---

### Rango de Píxeles

- **Mínimo:** 200px
- **Máximo:** 2000px
- **Default:** 800px

**Por qué este rango:**
- 200px: Mínimo razonable para preview
- 2000px: Balance entre calidad y tamaño de archivo
- Rango suficiente para casos de uso móvil/desktop

---

### Props

```typescript
interface DimensionButtonProps {
  selectedDimension: 'vertical' | 'square' | 'landscape' | null;
  pixels: number; // 200-2000
  onDimensionChange: (dimension: DimensionType) => void;
  onPixelsChange: (pixels: number) => void;
}
```

---

### Ejemplo de Uso

```tsx
import { DimensionButton } from '@/app/components/DimensionButton';

function MyComponent() {
  const [dimension, setDimension] = useState<'vertical' | 'square' | 'landscape' | null>(null);
  const [pixels, setPixels] = useState(800);

  return (
    <DimensionButton
      selectedDimension={dimension}
      pixels={pixels}
      onDimensionChange={setDimension}
      onPixelsChange={setPixels}
    />
  );
}
```

---

## 🎨 ColorModeButton - Selección Simple

**Archivo:** `ColorModeButton.tsx`

### Concepto

Botón que permite seleccionar el modo de color de la imagen:
- **Color:** Original
- **Escala de Grises:** Blanco a negro
- **Sepia:** Tono cálido vintage
- **B/N:** Alto contraste blanco y negro

**NO tiene dial** - Solo selección simple.

---

### Estados Visuales

#### Estado Normal - Grid de 4 opciones

```
┌─────────────────────────────────────┐
│         Modo de color               │
│                                     │
│   🎨      📊      ☕      ⚫        │
│  Color  Grises  Sepia   B/N         │
│    ↑ seleccionado                   │
│              Original                │  ← Descripción
└─────────────────────────────────────┘
```

**Características:**
- Grid 4 columnas
- Opción seleccionada en primary con border
- Descripción del modo debajo
- Sin dial (es solo selección)

---

### Iconos y Modos

```typescript
const modeConfig = {
  color: { 
    icon: Palette, 
    label: 'Color', 
    description: 'Original' 
  },
  grayscale: { 
    icon: SlidersHorizontal, 
    label: 'Grises', 
    description: 'Escala de grises' 
  },
  sepia: { 
    icon: Coffee, 
    label: 'Sepia', 
    description: 'Tono cálido' 
  },
  bw: { 
    icon: Circle, 
    label: 'B/N', 
    description: 'Blanco y negro' 
  },
};
```

---

### Props

```typescript
interface ColorModeButtonProps {
  selectedMode: 'color' | 'grayscale' | 'sepia' | 'bw' | null;
  onChange: (mode: ColorMode) => void;
}
```

---

### Ejemplo de Uso

```tsx
import { ColorModeButton } from '@/app/components/ColorModeButton';

function MyComponent() {
  const [colorMode, setColorMode] = useState<'color' | 'grayscale' | 'sepia' | 'bw' | null>('color');

  return (
    <ColorModeButton
      selectedMode={colorMode}
      onChange={setColorMode}
    />
  );
}
```

---

## 📏 Altura Fija en Todos los Componentes

**Cambio aplicado:** `min-h-[120px] flex flex-col justify-center`

### Por qué Altura Fija

✅ **No hay saltos de layout** - Todos los botones misma altura  
✅ **Scroll predecible** - No cambia la posición al transformar  
✅ **Visual consistente** - Grid alineado perfectamente  
✅ **Mejor UX mobile** - No empuja contenido abajo/arriba

---

### Componentes Actualizados

1. **DialButton.tsx** → `min-h-[120px]`
2. **ClassicAdjustments.tsx** → `min-h-[120px]`
3. **DimensionButton.tsx** → `min-h-[120px]`
4. **ColorModeButton.tsx** → `min-h-[120px]`

---

### Antes vs Después

#### ❌ Antes (altura variable)

```
┌────────────────────┐  ← 60px
│  Botón normal      │
└────────────────────┘

↓ Usuario toca

┌────────────────────┐  ← 140px (empuja contenido abajo)
│  Dial activo       │
│  ━━━━━━━━━         │
└────────────────────┘
```

---

#### ✅ Ahora (altura fija)

```
┌────────────────────┐  ← 120px siempre
│                    │
│  Botón normal      │
│                    │
└────────────────────┘

↓ Usuario toca

┌────────────────────┐  ← 120px (sin cambios)
│  Dial activo       │
│  ━━━━━━━━━         │
│                    │
└────────────────────┘
```

**No hay movimiento de contenido** 🎯

---

## 🎬 Flujos de Interacción

### DimensionButton

```
1. Usuario ve 3 opciones: Vertical | Cuadrada | Apaisada
2. Toca "Vertical"
   → Vertical se destaca en primary
   → Otras opciones se desactivan (opacity 40%)
   → Muestra "600×800px" abajo
3. Toca de nuevo "Vertical"
   → Se activa dial
   → Muestra "Vertical (3:4)" y dial de píxeles
4. Desliza para ajustar píxeles
   → Valor cambia 200-2000px
   → Dimensiones se actualizan en tiempo real
5. Suelta
   → Vuelve a estado de selección
   → Muestra nuevas dimensiones
```

---

### ColorModeButton

```
1. Usuario ve 4 opciones: Color | Grises | Sepia | B/N
2. Toca "Sepia"
   → Sepia se destaca en primary
   → Muestra "Tono cálido" abajo
3. Toca "B/N"
   → B/N se destaca
   → Sepia vuelve a normal
   → Muestra "Blanco y negro"
```

**No hay dial** - Solo selección simple como radio buttons.

---

## 🎯 Comparación de Patrones

| Componente | Tipo | Dial | Altura |
|------------|------|------|--------|
| **DialButton** | Individual 0-100% | ✅ | 120px |
| **ClassicAdjustments** | Multi-opción (4 iconos) + dial | ✅ | 120px |
| **DimensionButton** | Selección + dial condicional | ✅ | 120px |
| **ColorModeButton** | Selección simple | ❌ | 120px |

---

## 💡 Casos de Uso

### ✅ DimensionButton ideal para:

- **Redimensionar imagen** - Con proporciones preestablecidas
- **Selección + ajuste** - Dos pasos en un componente
- **Cálculos proporcionales** - Un valor controla dos

---

### ✅ ColorModeButton ideal para:

- **Filtros de imagen** - Color, grises, sepia, b/n
- **Opciones mutuamente exclusivas** - Solo una puede estar activa
- **Sin necesidad de dial** - Selección binaria

---

## 🚀 Implementación en Imagen@rte

### Ubicación Sugerida

**WizardActions.tsx** - Panel de operaciones:

```tsx
{/* Dimensión de exportación */}
<CollapsibleSection title="Dimensión">
  <DimensionButton
    selectedDimension={dimension}
    pixels={pixels}
    onDimensionChange={setDimension}
    onPixelsChange={setPixels}
  />
</CollapsibleSection>

{/* Modo de color */}
<CollapsibleSection title="Modo de color">
  <ColorModeButton
    selectedMode={colorMode}
    onChange={setColorMode}
  />
</CollapsibleSection>
```

---

## ✅ Resumen

### 🆕 Nuevos Componentes

1. **DimensionButton** - Selección (3 orientaciones) + dial (píxeles)
2. **ColorModeButton** - Selección simple (4 modos de color)

### 🔧 Mejoras Aplicadas

- ✅ Altura fija (`min-h-[120px]`) en TODOS los componentes
- ✅ No hay saltos de layout
- ✅ Visual consistente
- ✅ Grid perfecto

### 🎨 Patrones Disponibles

1. **Dial simple** (DialButton) - 0-100% con dial
2. **Multi-opción + dial** (ClassicAdjustments) - 4 iconos → dial
3. **Selección + dial condicional** (DimensionButton) - 3 opciones → dial
4. **Selección simple** (ColorModeButton) - 4 opciones sin dial

---

**Imagen@rte v3.0**  
*Sistema completo de Dial Buttons*  
**Fecha:** 2026-01-13
