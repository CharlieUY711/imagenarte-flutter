# Dial Buttons - Transformación In-Place

## 🎯 Concepto Core

**Transformación del mismo contenedor** - El botón no abre un menú, sino que se transforma en dial.

---

## 1️⃣ DialButton Individual

### Estado 1: Botón Normal

```
┌─────────────────────────────────────┐
│                                     │
│        Pixelar rostro (73%)         │  ← Texto centrado
│                                     │
└─────────────────────────────────────┘
```

**Características:**
- Sin chevron ❌
- Texto centrado
- Muestra valor entre paréntesis si > 0
- Border 1px normal

---

### Estado 2: Usuario toca el botón

**Transformación in-place:**

```
┌─────────────────────────────────────┐
│ Pixelar rostro              73%     │  ← Texto pequeño arriba
│                                     │
│ ████████████████████░░░░░░░         │  ← Dial centro
│           ← Desliza →               │  ← Hint
└─────────────────────────────────────┘
```

**Características:**
- Mismo contenedor
- Texto se reduce y sube a esquina superior izquierda
- Valor grande en esquina superior derecha
- Barra de progreso en centro
- Border 2px primary
- Ring al arrastrar

---

### Estado 3: Usuario suelta

**Vuelve a estado normal (200ms delay):**

```
┌─────────────────────────────────────┐
│                                     │
│        Pixelar rostro (89%)         │  ← Nuevo valor
│                                     │
└─────────────────────────────────────┘
```

**Características:**
- Dial desaparece
- Texto vuelve a tamaño normal centrado
- Muestra nuevo valor actualizado
- Border vuelve a 1px

---

## 2️⃣ ClassicAdjustments (Multi-opción)

### Estado 1: Grid de Iconos

```
┌─────────────────────────────────────┐
│                                     │
│   ☀️        ⚫        💧        ✨   │  ← 4 iconos
│   60%                               │  ← Solo si != 50
│                                     │
└─────────────────────────────────────┘
```

**Características:**
- Grid 4 columnas (brillo, contraste, saturación, nitidez)
- Iconos en gris si valor = 50 (neutro)
- Iconos en primary si valor != 50 (modificado)
- Muestra % debajo SOLO si diferente de 50

---

### Estado 2: Usuario toca icono de Brillo (☀️)

**Transformación in-place:**

```
┌─────────────────────────────────────┐
│ Brillo                         60%  │  ← Label del ajuste
│                                     │
│ ████████████████░░░░░░░░░░░░        │  ← Dial
│           ← Desliza →               │  ← Hint
└─────────────────────────────────────┘
```

**Características:**
- Los 4 iconos desaparecen
- Mismo contenedor se transforma en dial
- Muestra label del ajuste seleccionado
- Funciona igual que DialButton individual

---

### Estado 3: Usuario suelta

**Vuelve a grid de iconos:**

```
┌─────────────────────────────────────┐
│                                     │
│   ☀️        ⚫        💧        ✨   │  ← 4 iconos
│   75%                               │  ← Brillo actualizado
│                                     │
└─────────────────────────────────────┘
```

**Características:**
- Dial desaparece
- Vuelven los 4 iconos
- Icono de brillo muestra nuevo valor (75%)
- Icono de brillo en primary (destacado)
- Usuario puede tocar otro icono

---

## 🎬 Flujo de Interacción Completo

### DialButton Individual

```
1. Reposo: "Pixelar rostro (73%)"
             ↓ (tap)
2. Transformación: texto sube, dial aparece
             ↓ (deslizar)
3. Ajuste: valor cambia 0-100%
             ↓ (soltar)
4. Vuelve: "Pixelar rostro (89%)"
```

**Tiempo:** Transformación instantánea + delay 200ms al volver

---

### ClassicAdjustments

```
1. Reposo: [☀️ ⚫ 💧 ✨]
             ↓ (tap en ☀️)
2. Transformación: iconos desaparecen, dial de Brillo aparece
             ↓ (deslizar)
3. Ajuste: brillo cambia 0-100%
             ↓ (soltar)
4. Vuelve: [☀️ ⚫ 💧 ✨] con brillo actualizado
             ↓ (tap en ⚫)
5. Repite con Contraste...
```

**Tiempo:** Igual, transformación instantánea + delay 200ms

---

## 🎯 Ventajas de Transformación In-Place

### vs. Accordion (expandible)

| Aspecto | In-Place | Accordion |
|---------|----------|-----------|
| **Espacio** | Mismo tamaño siempre | Expande verticalmente |
| **Scroll** | No mueve contenido | Empuja contenido abajo |
| **Taps** | 1 tap + deslizar | 2 taps (expandir + ajustar) |
| **Visual** | Transformación fluida | Apertura/cierre |
| **Mobile** | Óptimo | Bueno |

---

### vs. Modal/Drawer

| Aspecto | In-Place | Modal |
|---------|----------|-------|
| **Contexto** | Mantiene vista de lista | Pierde contexto |
| **Navegación** | No hay stack | Stack de navegación |
| **Pasos** | Directo | Abrir → ajustar → cerrar |
| **Complejidad** | Simple | Más complejo |

---

## ✅ Principios de Diseño

### 1. Transformación Fluida
- Sin cambios abruptos
- Transición CSS de 300ms
- Feedback visual claro

### 2. Mismo Contenedor
- No abre nuevos elementos
- Reutiliza el espacio existente
- Ahorra espacio vertical

### 3. Estado Claro
- Siempre se sabe en qué modo está
- Border indica estado activo (2px primary)
- Ring indica que se está arrastrando

### 4. Vuelta Automática
- No requiere botón "Cerrar"
- Delay de 200ms da feedback de "acción completada"
- Simplifica UX

---

## 📐 Especificaciones Técnicas

### Tamaños de Texto

**Modo Botón:**
- Texto: `text-sm` (14px)
- Centrado verticalmente y horizontalmente

**Modo Dial:**
- Label: `text-xs` (12px) + `text-muted-foreground`
- Valor: `text-2xl` (24px) + `font-bold` + `text-primary`
- Hint: `text-xs` (12px) + `opacity-70`

---

### Bordes y Espaciado

**Modo Botón:**
- Border: `border` (1px)
- Padding: `p-4` (16px)
- Hover: `hover:bg-muted`

**Modo Dial:**
- Border: `border-2 border-primary` (2px)
- Padding: `p-4` (16px)
- Ring (arrastrar): `ring-2 ring-primary/20`

---

### Barra de Progreso

```css
Height: 8px (h-2)
Background: var(--muted)
Fill: var(--primary)
Border-radius: 9999px (rounded-full)
Transition: width 75ms
```

---

### Transiciones

```css
Container: transition-all duration-300
Progress bar: transition-all duration-75
```

**Por qué diferentes tiempos:**
- Container (300ms): Transformación completa del layout
- Progress bar (75ms): Feedback inmediato al deslizar

---

## 🧪 Testing Checklist

### DialButton Individual

- [ ] Tap activa modo dial
- [ ] Texto se reduce y sube a esquina
- [ ] Dial aparece en centro
- [ ] Deslizar derecha aumenta valor
- [ ] Deslizar izquierda disminuye valor
- [ ] Salir del área sigue funcionando (pointer capture)
- [ ] Soltar vuelve a modo botón (200ms)
- [ ] Texto vuelve a tamaño normal centrado
- [ ] Muestra valor actualizado entre paréntesis

---

### ClassicAdjustments

- [ ] Muestra 4 iconos en grid
- [ ] Iconos neutros (valor 50) en gris
- [ ] Iconos modificados (!= 50) en primary
- [ ] Tap en icono activa dial de ese ajuste
- [ ] Los 4 iconos desaparecen
- [ ] Muestra label correcto (Brillo, Contraste, etc.)
- [ ] Deslizar ajusta valor del ajuste seleccionado
- [ ] Soltar vuelve a mostrar 4 iconos
- [ ] Icono modificado muestra % debajo
- [ ] Puede tocar otro icono y repetir

---

## 📱 Optimización Mobile

### Touch Events

```typescript
onPointerDown  // Captura inicio
onPointerMove  // Actualiza valor
onPointerUp    // Finaliza
setPointerCapture(e.pointerId)  // Sigue fuera del área
```

**Ventajas:**
- Funciona en touch y mouse
- Captura el gesto completo
- No pierde el tracking

---

### Prevent Default

```typescript
e.preventDefault();  // En modo dial
```

**Evita:**
- Scroll accidental
- Selección de texto
- Gestos del navegador

---

### Touch Action

```css
touch-action: none;  /* En modo dial */
user-select: none;   /* En modo dial */
```

**Optimiza:**
- Respuesta táctil directa
- Sin interferencias del navegador

---

## 🎨 Casos de Uso en Imagen@rte

### 1. Controles de Privacidad (DialButton)

```tsx
<DialButton label="Pixelar rostro" value={pixelate} onChange={setPixelate} />
<DialButton label="Blur selectivo" value={blur} onChange={setBlur} />
<DialButton label="Crop inteligente" value={crop} onChange={setCrop} />
```

**Por qué:**
- 3 controles independientes
- Cada uno tiene su propia escala
- No necesitan estar agrupados

---

### 2. Ajustes Clásicos (ClassicAdjustments)

```tsx
<ClassicAdjustments 
  values={adjustments} 
  onChange={setAdjustments} 
/>
```

**Por qué:**
- 4 ajustes relacionados (todos modifican la imagen)
- Ahorra espacio (67% menos altura)
- Feedback visual de cuáles están modificados
- Grid de iconos es más escaneable

---

## ✅ Conclusión

La transformación **in-place** del mismo contenedor es:

1. **Más eficiente** - No ocupa espacio adicional
2. **Más directa** - Menos taps necesarios
3. **Más clara** - El usuario ve la transformación
4. **Más mobile** - Optimizada para touch
5. **Más sobria** - Sin chevrons ni indicadores innecesarios

**Implementación:** ✅ Completa y funcional  
**Demo:** Disponible en Home → "🎛️ Demo: Dial Buttons"  
**Documentación:** DIAL_BUTTON.md

---

**Imagen@rte v3.0**  
*Dial Buttons con Transformación In-Place*  
**Fecha:** 2026-01-13
