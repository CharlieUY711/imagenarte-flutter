# DialButton - Control Inline Deslizable

**Componente:** `DialButton.tsx`  
**Tipo:** Control de entrada mobile-first  
**Función:** Botón que se transforma in-place en dial deslizable para ajustar valores 0-100%

---

## 🎯 Concepto

El **DialButton** es una innovación UX que transforma el mismo contenedor:
- **Estado botón:** Texto centrado mostrando "Pixelar rostro (73%)"
- **Estado dial:** El mismo contenedor se transforma - texto sube a esquina, aparece dial en centro

### Ventajas UX

✅ **Transformación in-place** - No abre menús, el botón mismo cambia  
✅ **Interacción directa** - Deslizar izquierda/derecha para ajustar  
✅ **Visual claro** - Siempre muestra el valor actual  
✅ **Mobile-first** - Optimizado para touch  
✅ **Feedback inmediato** - Barra de progreso visual  
✅ **Sin chevron** - Interfaz limpia sin indicadores de desplegable

---

## 🎨 Estados

### 1. Estado Botón (Reposo)

```
┌────────────────────────────────┐
│                                │
│      Pixelar rostro (73%)      │  ← Texto centrado
│                                │
└────────────────────────────────┘
```

**Visual:**
- Fondo: background
- Border: 1px solid border
- Hover: bg-muted
- **Sin chevron** - Interfaz limpia

---

### 2. Estado Dial (Activo) - MISMO CONTENEDOR

```
┌────────────────────────────────┐
│ Pixelar rostro           73%   │  ← Texto pequeño arriba
│                                │
│ ━━━━━━━━━━━━━━━━━━━━━━━░░░░   │  ← Dial centro
│       ← Desliza →              │  ← Hint
└────────────────────────────────┘
```

**Visual:**
- Border: 2px solid primary
- Ring: 2px ring-primary/20 (cuando se arrastra)
- Texto reducido en esquina superior izquierda
- Valor grande en esquina superior derecha
- Barra de progreso en centro
- Texto de instrucción abajo

---

## 🔧 Mecánica de Interacción

### Flujo Completo - Transformación In-Place

```
1. Usuario toca el botón
   → El MISMO contenedor se transforma
   → Texto "Pixelar rostro (73%)" se reduce y sube a esquina
   → Aparece dial con barra de progreso en centro
   → Border cambia a 2px primary
   
2. Usuario mueve el dedo izquierda/derecha
   → Valor cambia en tiempo real (0-100%)
   → Barra de progreso se actualiza
   → Número grande derecha se actualiza
   
3. Usuario suelta el dedo
   → Delay de 200ms
   → Dial desaparece
   → Texto vuelve a tamaño normal centrado
   → Muestra "Pixelar rostro (nuevo valor)"
   → Border vuelve a 1px normal
```

### Touch/Pointer Events

**onPointerDown:**
- Captura el punto inicial (clientX)
- Guarda el valor inicial
- Captura el puntero (setPointerCapture)

**onPointerMove:**
- Calcula delta X desde punto inicial
- Convierte delta a porcentaje (basado en ancho del dial)
- Actualiza valor (clamp 0-100)

**onPointerUp:**
- Libera captura del puntero
- Delay 200ms → vuelve a modo botón

**Click fuera:**
- Listener de documento
- Si click fuera del dial → vuelve a modo botón

---

## 📋 Props

```typescript
interface DialButtonProps {
  label: string;      // Nombre del control
  value: number;      // Valor actual (0-100)
  onChange: (value: number) => void; // Callback al cambiar
  unit?: string;      // Unidad a mostrar (default: '%')
}
```

### Ejemplo de Uso

```tsx
import { DialButton } from '@/app/components/DialButton';

function MyComponent() {
  const [pixelateValue, setPixelateValue] = useState(0);

  return (
    <DialButton
      label="Pixelar rostro"
      value={pixelateValue}
      onChange={setPixelateValue}
    />
  );
}
```

---

## 🎨 Variaciones

### Con valor en 0 (sin activar)

```
┌────────────────────────────────┐
│                                │
│      Pixelar rostro            │  ← Texto centrado
│                                │
└────────────────────────────────┘
```

No muestra "(0%)" - queda limpio.

---

### Con valor > 0

```
┌────────────────────────────────┐
│                                │
│      Pixelar rostro (73%)      │  ← Texto centrado
│                                │
└────────────────────────────────┘
```

Muestra el valor entre paréntesis.

---

### Durante arrastre

```
┌────────────────────────────────┐
│ Pixelar rostro           73%   │  ← Texto primary
│                                │
│ ━━━━━━━━━━━━━━━━━━━━━━━░░░░   │  ← Barra animada
│       ← Desliza →              │  ← Hint
└────────────────────────────────┘
     └─ Ring 2px (efecto glow)
```

Visual destacado con border-2 y ring.

---

## 📦 Componente ClassicAdjustments

**Archivo:** `ClassicAdjustments.tsx`

**Un SOLO botón que contiene 4 ajustes de imagen con transformación in-place.**

### Concepto

En lugar de tener 4 botones separados, `ClassicAdjustments` es un único contenedor que:
- **Estado normal:** Muestra grid de 4 iconos (☀️ Brillo, ⚫ Contraste, 💧 Saturación, ✨ Nitidez)
- **Estado dial:** Al tocar un icono, TODOS los iconos desaparecen y el contenedor se transforma en dial para ese ajuste
- **Volver:** Al soltar, vuelve a mostrar los 4 iconos con los valores actualizados

### Estados Visuales

#### Estado Normal - Grid de Iconos

```
┌────────────────────────────────┐
│  ☀️      ⚫      💧      ✨     │  ← 4 iconos
│          50%                   │  ← Solo muestra % si != 50
└────────────────────────────────┘
```

- Grid 4 columnas
- Iconos centrados
- Muestra valor debajo SOLO si es diferente de 50% (valor neutral)
- Iconos en `text-primary` si tienen valor modificado, sino `text-muted-foreground`

---

#### Usuario toca icono de Brillo (☀️)

**Transformación:**
1. Los 4 iconos desaparecen
2. El MISMO contenedor se transforma en dial
3. Muestra "Brillo" + barra de progreso

```
┌────────────────────────────────┐
│ Brillo                    60%  │  ← Label + valor
│                                │
│ ━━━━━━━━━━━━━━━━░░░░░░░░░░░░  │  ← Dial
│       ← Desliza →              │  ← Hint
└────────────────────────────────┘
```

---

#### Usuario ajusta y suelta

**Vuelve a estado normal:**
```
┌────────────────────────────────┐
│  ☀️      ⚫      💧      ✨     │  ← 4 iconos de nuevo
│  60%                           │  ← Brillo ahora muestra 60%
└────────────────────────────────┘
```

- Iconos vuelven a aparecer
- Brillo muestra "60%" debajo del icono
- Icono de brillo en `text-primary` (destacado porque cambió)

---

### Flujo de Interacción

```
1. Usuario ve 4 iconos en grid
   → Toca icono de Contraste (⚫)

2. Transformación in-place:
   → Los 4 iconos desaparecen
   → Aparece dial de Contraste
   → Border cambia a primary

3. Usuario desliza izquierda/derecha
   → Valor de contraste cambia 0-100%
   → Barra de progreso se actualiza

4. Usuario suelta
   → Delay 200ms
   → Dial desaparece
   → Vuelven los 4 iconos
   → Icono de Contraste ahora muestra el nuevo valor

5. Usuario puede tocar otro icono
   → Proceso se repite
```

---

### Props e Iconos

```typescript
interface ClassicAdjustmentsState {
  brightness: number;   // 0-100
  contrast: number;     // 0-100
  saturation: number;   // 0-100
  sharpness: number;    // 0-100
}

const adjustmentConfig = {
  brightness: { icon: Sun, label: 'Brillo' },
  contrast: { icon: Contrast, label: 'Contraste' },
  saturation: { icon: Droplet, label: 'Saturación' },
  sharpness: { icon: Sparkles, label: 'Nitidez' },
};
```

**Iconos de lucide-react:**
- ☀️ `Sun` - Brillo
- ⚫ `Contrast` - Contraste  
- 💧 `Droplet` - Saturación
- ✨ `Sparkles` - Nitidez

---

### Ejemplo de Uso

```tsx
import { ClassicAdjustments, initialClassicAdjustments } from '@/app/components/ClassicAdjustments';

function MyComponent() {
  const [adjustments, setAdjustments] = useState(initialClassicAdjustments);

  return (
    <ClassicAdjustments
      values={adjustments}
      onChange={setAdjustments}
    />
  );
}
```

### Estado Inicial

```typescript
{
  brightness: 50,   // Brillo central (50%)
  contrast: 50,     // Contraste central
  saturation: 50,   // Saturación central
  sharpness: 50,    // Nitidez central
}
```

---

### Lógica de Destacado

```typescript
const hasValue = value !== 50; // Diferente del valor neutral

<Icon 
  className={`w-6 h-6 ${hasValue ? 'text-primary' : 'text-muted-foreground'}`}
/>
```

**Regla:**
- Valor = 50% → Neutro → `text-muted-foreground` (gris)
- Valor ≠ 50% → Modificado → `text-primary` (destacado)

**Por qué 50% es neutral:**
- Brillo 50% = sin cambio
- Contraste 50% = sin cambio  
- Saturación 50% = sin cambio
- Nitidez 50% = sin cambio

---

### Ventajas UX

✅ **Un solo contenedor** - No ocupa 4x el espacio  
✅ **Transformación clara** - Usuario ve que el contenedor entero cambia  
✅ **Feedback visual** - Iconos destacados en primary cuando cambian  
✅ **Solo muestra valores modificados** - No muestra "50%" en todos los iconos  
✅ **Compacto** - Grid de 4 iconos ocupa mucho menos que 4 botones

---

### Comparación de Espacio

#### Antes (4 DialButtons separados)
```
┌────────────────────────────────┐
│      Brillo (50%)              │
└────────────────────────────────┘

┌────────────────────────────────┐
│      Contraste (50%)           │
└────────────────────────────────┘

┌────────────────────────────────┐
│      Saturación (50%)          │
└────────────────────────────────┘

┌────────────────────────────────┐
│      Nitidez (50%)             │
└────────────────────────────────┘
```
**Espacio vertical:** ~240px

#### Ahora (ClassicAdjustments)
```
┌────────────────────────────────┐
│  ☀️      ⚫      💧      ✨     │
│                                │
└────────────────────────────────┘
```
**Espacio vertical:** ~80px

**Ahorro de espacio:** 67% menos altura 🎯

---

## 🎬 Demo Interactiva

**Pantalla:** `DialDemo.tsx`  
**Acceso:** Home → "🎛️ Demo: Dial Buttons"

### Contenido de la Demo

1. **Controles de privacidad** (DialButton individual)
   - Pixelar rostro
   - Blur selectivo
   - Intensidad de crop

2. **Ajustes clásicos** (ClassicAdjustments)
   - Brillo
   - Contraste
   - Saturación
   - Nitidez

3. **Instrucciones de uso**
   - Explicación del modo botón/dial
   - Cómo deslizar

4. **Valores actuales** (debug panel)
   - Todos los valores en tiempo real

---

## 🎯 Casos de Uso

### ✅ Ideal para:

- **Ajustes frecuentes** - Valores que el usuario toca varias veces
- **Controles visuales** - Brillo, contraste, etc.
- **Mobile-first** - Touch es la interacción principal
- **Espacios reducidos** - Cuando no hay lugar para sliders permanentes

### ❌ No ideal para:

- **Ajustes de precisión** - Mejor usar input numérico
- **Valores discretos** - Mejor usar dropdown
- **Opciones on/off** - Mejor usar toggle
- **Desktop-only** - El dial es mejor en touch

---

## 🔍 Detalles Técnicos

### Cálculo del Delta

```typescript
const deltaX = e.clientX - startXRef.current;
const percentageChange = (deltaX / rect.width) * 100;
const newValue = Math.max(0, Math.min(100, startValueRef.current + percentageChange));
```

**Lógica:**
- Delta positivo (derecha) → aumenta valor
- Delta negativo (izquierda) → disminuye valor
- Clamp entre 0-100

---

### Captura del Puntero

```typescript
e.currentTarget.setPointerCapture(e.pointerId);
```

**Ventajas:**
- Sigue el arrastre aunque el dedo salga del dial
- Funciona en touch y mouse
- Compatible con Pointer Events API

---

### Transición Suave

```typescript
setTimeout(() => {
  setIsDialMode(false);
}, 200);
```

**Por qué 200ms:**
- Da feedback visual de que la acción terminó
- Evita parpadeo abrupto
- Tiempo suficiente para ver el valor final

---

## 🎨 Estilos Clave

### Modo Botón

```css
.dial-button-mode {
  border: 1px solid var(--border);
  background: var(--background);
  hover:bg-muted;
  active:bg-muted;
  transition: background-color 150ms;
}
```

### Modo Dial

```css
.dial-active-mode {
  border: 2px solid var(--primary);
  cursor: ew-resize;        /* Cursor horizontal */
  user-select: none;        /* No seleccionar texto */
  touch-action: none;       /* Evita scroll en mobile */
}

.dial-active-mode.dragging {
  ring: 2px var(--primary/20);
}
```

### Barra de Progreso

```css
.dial-progress-bar {
  height: 8px;
  background: var(--muted);
  border-radius: 9999px;
}

.dial-progress-fill {
  height: 100%;
  background: var(--primary);
  transition: width 75ms;   /* Suave pero responsivo */
}
```

---

## 🧪 Testing UX

### Checklist de Validación

- [ ] Tap en botón → activa modo dial
- [ ] Deslizar derecha → aumenta valor
- [ ] Deslizar izquierda → disminuye valor
- [ ] Salir del dial mientras arrastra → sigue funcionando
- [ ] Soltar dedo → vuelve a modo botón después de 200ms
- [ ] Click fuera del dial → vuelve a modo botón
- [ ] Valor se muestra correctamente en modo botón
- [ ] Barra de progreso se actualiza en tiempo real

### Escenarios de Uso

**Escenario 1: Ajuste rápido**
1. Tap en "Brillo (50%)"
2. Deslizar a la derecha
3. Soltar en 70%
4. Confirmar que muestra "Brillo (70%)"

**Escenario 2: Múltiples ajustes**
1. Ajustar Brillo a 60%
2. Ajustar Contraste a 70%
3. Ajustar Saturación a 40%
4. Confirmar valores en panel debug

**Escenario 3: Cancelar ajuste**
1. Tap en "Pixelar rostro (50%)"
2. Empezar a deslizar
3. Click fuera del dial
4. Confirmar que mantiene el valor original

---

## 💡 Mejoras Futuras (Opcional)

### Vibración háptica (mobile nativo)

```typescript
if ('vibrate' in navigator) {
  navigator.vibrate(10); // Vibrar al cambiar valor
}
```

### Snap to increments

```typescript
const snappedValue = Math.round(newValue / 10) * 10; // Snap cada 10%
```

### Animación de entrada/salida

```css
@keyframes dialIn {
  from { transform: scaleY(0.95); opacity: 0; }
  to { transform: scaleY(1); opacity: 1; }
}

.dial-mode-enter {
  animation: dialIn 150ms ease-out;
}
```

---

## 📊 Comparación con Slider

| Aspecto | DialButton | Slider tradicional |
|---------|------------|-------------------|
| **Espacio** | Compacto (solo activo cuando se usa) | Siempre ocupa espacio |
| **Mobile** | Excelente (touch-first) | Bueno (pero thumb pequeño) |
| **Visual** | Limpio (modo botón) | Siempre visible |
| **Feedback** | Inmediato (barra + valor) | Inmediato (thumb) |
| **Precisión** | Media (deslizar libre) | Alta (thumb preciso) |
| **Casos de uso** | Ajustes frecuentes | Ajustes permanentes |

---

## 🎯 Decisiones de Diseño

### ¿Por qué no accordion?

El accordion requiere dos taps:
1. Tap para expandir
2. Mover slider

Con DialButton:
1. Tap + deslizar en un solo gesto

---

### ¿Por qué volver a modo botón?

**Razones:**
- Ahorra espacio vertical
- Lista de controles más compacta
- Feedback visual de "acción completada"
- Evita confusión (solo un dial activo a la vez)

---

### ¿Por qué 0-100% siempre?

**Simplificación UX:**
- Escala universal (todos entienden porcentajes)
- Fácil de mapear a cualquier rango real
- Visual claro (0% = nada, 100% = máximo)

**Mapeo interno:**
```typescript
// Ejemplo: Pixelado de 1-10
const pixelIntensity = Math.round((value / 100) * 9) + 1; // 0% → 1, 100% → 10
```

---

## 🚀 Implementación en Imagen@rte

### Ubicación Actual

**Pantalla:** `WizardActions.tsx`  
**Sección:** "Ajustes clásicos" (CollapsibleSection)

### Ejemplo de Integración

```tsx
<CollapsibleSection title="Ajustes clásicos">
  <ClassicAdjustments
    values={classicAdjustments}
    onChange={setClassicAdjustments}
  />
</CollapsibleSection>
```

### Flujo Completo

```
Home → WizardActions → "Ajustes clásicos" → DialButtons individuales
```

---

## ✅ Conclusión

El **DialButton** es un control innovador que:

- ✅ Optimiza el espacio vertical en mobile
- ✅ Reduce taps necesarios (1 tap + deslizar vs 2 taps + mover)
- ✅ Proporciona feedback visual inmediato
- ✅ Es intuitivo para usuarios touch-first
- ✅ Se integra perfectamente con el diseño sobrio de Imagen@rte

**Recomendación:** Ideal para ajustes de imagen (brillo, contraste, etc.) que requieren modificación frecuente pero no necesitan estar siempre visibles.

---

**Imagen@rte v3.0**  
*DialButton - Control inline deslizable*

**Fecha:** 2026-01-13  
**Estado:** ✅ Implementado y funcional  
**Demo:** Accesible desde Home → "🎛️ Demo: Dial Buttons"
