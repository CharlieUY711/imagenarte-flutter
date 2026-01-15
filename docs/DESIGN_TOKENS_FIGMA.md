# Tokens de Diseño - Extraídos de Figma

Este documento contiene los tokens de diseño extraídos del archivo `Figma.zip` y aplicados al proyecto Flutter.

**Fuente:** `figma_extracted/src/styles/theme.css`  
**Fecha de extracción:** 2026-01-13

---

## 🎨 Paleta de Colores

### Modo Claro (Light Mode)

| Token | Valor Hex | Uso |
|-------|-----------|-----|
| `background` | `#FFFFFF` | Fondo principal |
| `foreground` | `#1A1A1A` | Texto principal |
| `card` | `#FFFFFF` | Fondo de tarjetas |
| `card-foreground` | `#1A1A1A` | Texto en tarjetas |
| `primary` | `#1A1A1A` | Color primario |
| `primary-foreground` | `#FFFFFF` | Texto sobre primario |
| `secondary` | `#F5F5F5` | Color secundario |
| `secondary-foreground` | `#1A1A1A` | Texto sobre secundario |
| `muted` | `#F5F5F5` | Fondos sutiles |
| `muted-foreground` | `#737373` | Texto en fondos sutiles |
| `accent` | `#F5F5F5` | Acentos |
| `accent-foreground` | `#1A1A1A` | Texto sobre acentos |
| `destructive` | `#DC2626` | Errores/acciones destructivas |
| `destructive-foreground` | `#FFFFFF` | Texto sobre destructivo |
| `border` | `#E5E5E5` | Bordes |
| `input` | `transparent` | Inputs |
| `input-background` | `#F5F5F5` | Fondo de inputs |
| `switch-background` | `#D4D4D4` | Fondo de switches |
| `ring` | `#A3A3A3` | Anillos de foco |

### Modo Oscuro (Dark Mode)

Los valores del modo oscuro están definidos en `theme.css` usando `oklch()`. Para Flutter, se recomienda usar los valores equivalentes en RGB o mantener el modo claro según el contexto.

### Colores Especiales

| Color | Valor Hex | Uso |
|-------|-----------|-----|
| `accentOrange` | `#F97316` | Color de acento naranja (usado en DialButton, estados activos) |
| `editorBackground` | `#000000` | Fondo del editor (negro para que la imagen destaque) |
| `editorSurface` | `#1C1C1E` | Superficie del editor (usado en DialButton) |
| `editorSurfaceHover` | `#2C2C2E` | Estado hover en editor |

---

## 📐 Dimensiones y Espaciado

### Border Radius

| Token | Valor | CSS Original |
|-------|-------|--------------|
| `radius` | `12.0` | `0.75rem` |
| `radius-sm` | `8.0` | `calc(var(--radius) - 4px)` |
| `radius-md` | `10.0` | `calc(var(--radius) - 2px)` |
| `radius-lg` | `12.0` | `var(--radius)` |
| `radius-xl` | `16.0` | `calc(var(--radius) + 4px)` |

### Espaciado

| Token | Valor | Uso |
|-------|-------|-----|
| `spacingBase` | `16.0` | Padding interno estándar (1rem) |
| `spacingGap` | `12.0` | Gap entre elementos (0.75rem) |

### Alturas Específicas

| Token | Valor | Uso |
|-------|-------|-----|
| `toolbarHeight` | `25.0` | Altura de la barra de herramientas |
| `dialButtonHeight` | `30.0` | Altura de los botones dial |

---

## 🔤 Tipografía

### Tamaños de Fuente

| Token | Valor | CSS Original | Uso |
|-------|-------|--------------|-----|
| `fontSizeBase` | `16.0` | `16px` (1rem) | Tamaño base |
| Header | `18.0` | `1.125rem` | Títulos principales |
| Body | `16.0` | `1rem` | Texto de cuerpo |
| Label | `14.0` | `0.875rem` | Etiquetas |
| Caption | `12.0` | `0.75rem` | Texto pequeño |

### Pesos de Fuente

| Token | Valor | CSS Original |
|-------|-------|--------------|
| `fontWeightNormal` | `FontWeight.w400` | `400` |
| `fontWeightMedium` | `FontWeight.w500` | `500` |

### Font Family

- **Primaria:** Inter, system-ui, sans-serif
- **Fallback:** System fonts del dispositivo

---

## 🎛️ Componentes Específicos

### DialButton

**Estados:**
- **Inactivo:** `border: 1px`, `bg: #1C1C1E`, `hover: #2C2C2E`
- **Activo:** `border: 2px`, `border-color: orange-500`, `bg: #1C1C1E`, `cursor: ew-resize`
- **Altura:** `30px`
- **Padding:** `12px` horizontal (`px-3`)

**Colores:**
- Texto: `white`
- Valor activo: `orange-500` (`#F97316`)
- Barra de progreso: `orange-500`

### ClassicAdjustments

**Layout:**
- Grid de 4 iconos cuando está colapsado
- Slider horizontal cuando está expandido
- Mismo estilo que DialButton

### RadialMotif

**Variantes:**
1. **Background:** Opacidad `0.03` (3%), arcos diagonales sutiles
2. **Loading:** Opacidad `1.0` (100%), arco parcial que rota
3. **Progress:** Opacidad `1.0` (100%), arco que progresa de 0° a 240°

**Ángulos:**
- Inicio del progreso: `-135°` (diagonal superior izquierda)
- Máximo completado: `240°` (nunca completo)
- Rotación del loading: continua (CSS animation)

---

## 📱 Breakpoints y Responsive

El diseño es **mobile-first** con viewport base de `390×844px`.

### Proporciones del Layout

- **Header:** `60px` fijo
- **Preview:** `45vh` (~380px) fijo
- **Panel acciones:** Resto (~380px) con scroll
- **Footer:** `60px` fijo

---

## 🎯 Implementación en Flutter

Los tokens están implementados en:
- `apps/mobile/lib/presentation/theme/app_theme.dart`

### Uso

```dart
// Colores
AppTokens.primary
AppTokens.accentOrange
AppTokens.editorBackground

// Dimensiones
AppTokens.radius
AppTokens.dialButtonHeight

// Tipografía
AppTokens.fontSizeBase
AppTokens.fontWeightMedium
```

### Temas

```dart
// Tema claro (para pantallas generales)
AppTheme.lightTheme

// Tema oscuro (para el editor)
AppTheme.darkEditorTheme
```

---

## 📚 Referencias

- **Archivo fuente CSS:** `figma_extracted/src/styles/theme.css`
- **Documentación de identidad visual:** `figma_extracted/IDENTIDAD_VISUAL.md`
- **Especificación completa:** `figma_extracted/FIGMA_SPEC.md`
- **Componentes React:** `figma_extracted/src/app/components/`

---

**Última actualización:** 2026-01-13  
**Estado:** ✅ Tokens extraídos e implementados en Flutter
