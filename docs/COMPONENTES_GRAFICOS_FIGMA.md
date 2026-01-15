# Componentes Gráficos Extraídos de Figma

Este documento lista los componentes visuales extraídos del archivo `Figma.zip` y su estado de implementación en Flutter.

**Fuente:** `figma_extracted/src/app/components/`  
**Fecha de extracción:** 2026-01-13

---

## 📦 Componentes Extraídos

### 1. DialButton ✅

**Ubicación Figma:** `figma_extracted/src/app/components/DialButton.tsx`  
**Ubicación Flutter:** `apps/mobile/lib/presentation/widgets/dial_button.dart`

**Características:**
- Altura: 30px
- Modo botón (inactivo): Texto centrado, fondo #1C1C1E
- Modo dial (activo): Slider horizontal con valor, borde naranja 2px
- Soporte para arrastre horizontal para ajustar valor
- Estados: hover, active, dragging

**Props:**
- `label`: String - Etiqueta del botón
- `value`: Number (0-100) - Valor actual
- `onChange`: Function - Callback al cambiar valor
- `unit`: String - Unidad (default: '%')
- `active`: Boolean - Si está en modo dial
- `onActivate`: Function - Callback al activar

**Estado:** ✅ Implementado básico, falta modo dial con slider

---

### 2. ClassicAdjustments ✅

**Ubicación Figma:** `figma_extracted/src/app/components/ClassicAdjustments.tsx`  
**Ubicación Flutter:** `apps/mobile/lib/presentation/widgets/classic_adjustments_panel.dart`

**Características:**
- Grid de 4 iconos cuando está colapsado (Brillo, Contraste, Saturación, Nitidez)
- Slider horizontal cuando está expandido
- Mismo estilo visual que DialButton
- Soporte para arrastre horizontal

**Ajustes:**
- Brightness (Brillo)
- Contrast (Contraste)
- Saturation (Saturación)
- Sharpness (Nitidez)

**Valores iniciales:** Todos en 50 (neutral)

**Estado:** ✅ Implementado, verificar compatibilidad con diseño Figma

---

### 3. RadialMotif ⏳

**Ubicación Figma:** `figma_extracted/src/app/components/RadialMotif.tsx`  
**Ubicación Flutter:** `apps/mobile/lib/presentation/widgets/radial_motif.dart` (pendiente)

**Características:**
- Tres variantes: background, loading, progress
- Arcos parciales (nunca círculos completos)
- Eje diagonal a -135° (14:45 en reloj)
- Opacidad configurable

**Variantes:**
1. **Background:** Opacidad 3%, dos arcos diagonales
2. **Loading:** Opacidad 100%, arco parcial que rota
3. **Progress:** Opacidad 100%, arco que progresa 0-240°

**Estado:** ⏳ Documentación creada, pendiente implementación

---

### 4. Button ✅

**Ubicación Figma:** `figma_extracted/src/app/components/Button.tsx`  
**Ubicación Flutter:** Usar `ElevatedButton` o `FilledButton` de Material 3

**Características:**
- Variantes: primary, secondary
- Estado de carga con RadialMotif
- Animación de escala al presionar
- Border radius: 12px (xl)

**Props:**
- `variant`: 'primary' | 'secondary'
- `isLoading`: Boolean
- `disabled`: Boolean

**Estado:** ✅ Usar componentes nativos de Flutter Material 3

---

### 5. ImagePreview ⏳

**Ubicación Figma:** `figma_extracted/src/app/components/ImagePreview.tsx`  
**Ubicación Flutter:** `apps/mobile/lib/presentation/widgets/preview_area.dart`

**Estados:**
- Empty: Placeholder "Selecciona una imagen"
- Loaded: Imagen original mostrada
- Loading: Spinner con RadialMotif
- Error: Mensaje de error con botón "Intentar de nuevo"

**Características:**
- Mantiene aspect ratio
- object-fit: contain
- Fondo muted
- Ocupa 45vh del viewport

**Estado:** ⏳ Verificar implementación actual

---

### 6. Slider ⏳

**Ubicación Figma:** `figma_extracted/src/app/components/Slider.tsx`  
**Ubicación Flutter:** Usar `Slider` de Material 3 con estilos personalizados

**Características:**
- Track: bg-muted, height 4px
- Thumb: bg-primary, size 20px
- Label: sobre el slider, con valor numérico
- Rango: min=1, max=10 (para operaciones) o 0-100 (para ajustes)

**Estado:** ⏳ Usar Slider nativo con estilos personalizados

---

### 7. Toggle ⏳

**Ubicación Figma:** `figma_extracted/src/app/components/Toggle.tsx`  
**Ubicación Flutter:** Usar `Switch` de Material 3 con estilos personalizados

**Características:**
- Estado OFF: bg-muted, thumb blanco
- Estado ON: bg-primary, thumb blanco
- Estado DISABLED: opacity 0.5

**Estado:** ⏳ Usar Switch nativo con estilos personalizados

---

### 8. Stepper ⏳

**Ubicación Figma:** `figma_extracted/src/app/screens/WizardStep*.tsx`  
**Ubicación Flutter:** `apps/mobile/lib/ui/screens/wizard/wizard_screen.dart`

**Características:**
- Indicador de progreso con RadialMotif (variante progress)
- Muestra "Paso X de 3"
- Progreso: 33%, 66%, 100% (máximo 240° del arco)

**Estado:** ⏳ Verificar implementación actual

---

## 🎨 Sistema de Diseño

### Colores

Ver `DESIGN_TOKENS_FIGMA.md` para la paleta completa.

### Tipografía

- **Font family:** Inter, system-ui, sans-serif
- **Tamaños:**
  - Header: 18px
  - Body: 16px
  - Label: 14px
  - Caption: 12px

### Espaciado

- Padding interno: 16px
- Gap entre elementos: 12px
- Border radius: 8px (base), 12px (lg)

---

## 📋 Checklist de Implementación

### Componentes Core

- [x] DialButton - Implementado básico
- [x] ClassicAdjustments - Implementado
- [ ] RadialMotif - Pendiente
- [ ] ImagePreview - Verificar
- [ ] Stepper - Verificar

### Componentes UI Base

- [ ] Button - Usar Material 3
- [ ] Slider - Usar Material 3 con estilos
- [ ] Toggle/Switch - Usar Material 3 con estilos
- [ ] Dropdown - Usar Material 3
- [ ] Accordion - Usar ExpansionTile

### Pantallas

- [ ] Home - Verificar
- [ ] Wizard - Verificar
- [ ] Export - Verificar

---

## 🔗 Referencias

- **Tokens de diseño:** `docs/DESIGN_TOKENS_FIGMA.md`
- **Identidad visual:** `docs/IDENTIDAD_VISUAL_FLUTTER.md`
- **Especificación Figma:** `figma_extracted/FIGMA_SPEC.md`
- **Componentes React:** `figma_extracted/src/app/components/`

---

**Última actualización:** 2026-01-13  
**Estado:** 📋 Documentación completa, implementación en progreso
