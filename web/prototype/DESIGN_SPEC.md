# Imagen@rte - Especificación de Diseño UX/UI (herramienta de dise�o)

**PROYECTO:** Imagen@rte (MVP Imagen)  
**OBJETIVO:** Wizard con preview persistente  
**VERSIÓN:** 3.0 (Final para herramienta de dise�o)  
**FECHA:** 2026-01-13

---

## 🎯 DECISIÓN UX CLAVE (OBLIGATORIA)

**La imagen seleccionada debe permanecer siempre visible.**

- Solo cambia el panel inferior de la pantalla
- **NO hay preview procesado en tiempo real** en el wizard
- El procesamiento real ocurre en la **pantalla de Export**

---

## 📐 ESTRUCTURA DEL WIZARD

Layout vertical, mobile-first (390×844):

```
┌────────────────────────────────┐
│  ← Tratamiento de imagen       │  60px - Header
├────────────────────────────────┤
│                                │
│    ┌──────────────────┐        │
│    │                  │        │
│    │   IMAGEN         │        │  ~380px (45vh)
│    │   ORIGINAL       │        │  PREVIEW PERSISTENTE
│    │   (sin procesar) │        │
│    │                  │        │
│    └──────────────────┘        │
│                                │
├────────────────────────────────┤
│  Pixelar rostro            ˅   │
├────────────────────────────────┤
│  Blur selectivo            ˅   │  ~380px
├────────────────────────────────┤  PANEL DE ACCIONES
│  Crop inteligente          ˅   │  (scrollable)
├────────────────────────────────┤
│  Quitar fondo              ˅   │
│  (deshabilitado)               │
├────────────────────────────────┤
│                                │
│       [Continuar]              │  60px - Footer
└────────────────────────────────┘
```

**Proporciones:**
- Header: 60px fijo
- Preview: 45vh (~380px) fijo
- Panel acciones: resto (~380px) con scroll
- Footer: 60px fijo con botón

---

## 🖼️ PREVIEW DE IMAGEN (ZONA SUPERIOR)

### Requisitos Obligatorios

✅ **Muestra siempre la imagen ORIGINAL seleccionada**  
✅ **Mantiene aspect ratio**  
✅ **NO muestra efectos aplicados**  
✅ **NO desaparece nunca**  
✅ **Ocupa 45% de la altura de viewport (45vh)**

### Estados a Diseñar

#### 1. Empty (antes de seleccionar)
```
┌─────────────────────────┐
│                         │
│    [📷 Icon]            │
│                         │
│  Selecciona una imagen  │
│                         │
└─────────────────────────┘
```

**Copy:** "Selecciona una imagen"  
**Estilo:** Fondo muted, icono + texto centrados

---

#### 2. Loaded (imagen seleccionada)
```
┌─────────────────────────┐
│                         │
│   ┌───────────────┐     │
│   │   [IMAGEN]    │     │
│   │   Original    │     │
│   └───────────────┘     │
│                         │
└─────────────────────────┘
```

**Estilo:** object-fit: contain, fondo muted

---

#### 3. Loading (carga en progreso)
```
┌─────────────────────────┐
│                         │
│    [⟳ Spinner]          │
│                         │
│  Cargando imagen...     │
│                         │
└─────────────────────────┘
```

**Copy:** "Cargando imagen..."  
**Estilo:** Spinner + texto centrado

---

#### 4. Error (fallo al cargar)
```
┌─────────────────────────┐
│                         │
│    [⚠️ Icon]            │
│                         │
│  Error al cargar imagen │
│  [Intentar de nuevo]    │
│                         │
└─────────────────────────┘
```

**Copy:** "Error al cargar imagen"  
**Botón:** "Intentar de nuevo"  
**Estilo:** Icono de error + mensaje + botón secundario

---

### Nota UX Obligatoria (Incluir en Frame de herramienta de dise�o)

Agregar un pequeño callout en la parte inferior del preview:

```
┌─────────────────────────────────────────┐
│ ℹ️  Nota de diseño UX:                  │
│                                         │
│ La imagen permanece fija como           │
│ referencia visual. El procesamiento     │
│ real ocurre en la pantalla de Export.   │
│ No hay preview procesado en tiempo      │
│ real en este paso.                      │
└─────────────────────────────────────────┘
```

**Estilo:** bg-background/90, backdrop-blur, border, text-xs, padding pequeño

---

## 🎛️ PANEL DE ACCIONES (ZONA INFERIOR)

### Requisitos Obligatorios

✅ **Solo las 4 operaciones MVP**  
✅ **Cada operación es un accordion/card**  
✅ **Los sliders solo aparecen cuando toggle está ON**  
✅ **Panel puede scrollear verticalmente**  
✅ **NO cambia el preview al mover controles**

---

## 📋 OPERACIONES MVP (LAS ÚNICAS PERMITIDAS)

### 1️⃣ Pixelar rostro

**Accordion colapsado:**
```
┌────────────────────────────────┐
│  Pixelar rostro            ˅   │
└────────────────────────────────┘
```

**Accordion expandido:**
```
┌────────────────────────────────┐
│  Pixelar rostro            ˄   │
│                                │
│  ⚪ Activar pixelado de rostro │ <- Toggle OFF
│                                │
│  Protege la identidad          │
│  pixelando rostros detectados. │
└────────────────────────────────┘
```

**Accordion expandido + Toggle ON:**
```
┌────────────────────────────────┐
│  Pixelar rostro            ˄   │
│                                │
│  🟢 Activar pixelado de rostro │ <- Toggle ON
│                                │
│  Protege la identidad          │
│  pixelando rostros detectados. │
│                                │
│  Intensidad: 5                 │ <- Label con valor
│  ├──────●──────────┤           │ <- Slider (1-10)
│  1                10           │
└────────────────────────────────┘
```

**Elementos:**
- Título: "Pixelar rostro"
- Toggle: "Activar pixelado de rostro"
- Copy: "Protege la identidad pixelando rostros detectados."
- Slider: min=1, max=10, step=1
- Label: "Intensidad: {value}"

---

### 2️⃣ Blur selectivo

**Accordion expandido + Toggle ON:**
```
┌────────────────────────────────┐
│  Blur selectivo            ˄   │
│                                │
│  🟢 Activar blur selectivo     │
│                                │
│  Difumina áreas sensibles      │
│  de la imagen.                 │
│                                │
│  Intensidad: 7                 │
│  ├─────────●───────┤           │
│  1                10           │
└────────────────────────────────┘
```

**Elementos:**
- Título: "Blur selectivo"
- Toggle: "Activar blur selectivo"
- Copy: "Difumina áreas sensibles de la imagen."
- Slider: min=1, max=10, step=1
- Label: "Intensidad: {value}"

---

### 3️⃣ Crop inteligente

**Accordion expandido + Toggle ON:**
```
┌────────────────────────────────┐
│  Crop inteligente          ˄   │
│                                │
│  🟢 Activar recorte            │
│                                │
│  Recorta la imagen según el    │
│  ratio seleccionado.           │
│                                │
│  Ratio de aspecto              │
│  ┌──────────────────────────┐ │
│  │ 1:1 (Cuadrado)        ▾  │ │ <- Dropdown
│  └──────────────────────────┘ │
│                                │
│  Opciones:                     │
│  • 1:1 (Cuadrado)              │
│  • 16:9 (Widescreen)           │
│  • 4:3 (Clásico)               │
│  • 9:16 (Vertical)             │
└────────────────────────────────┘
```

**Elementos:**
- Título: "Crop inteligente"
- Toggle: "Activar recorte"
- Copy: "Recorta la imagen según el ratio seleccionado."
- Dropdown label: "Ratio de aspecto"
- Opciones:
  - `1:1 (Cuadrado)`
  - `16:9 (Widescreen)`
  - `4:3 (Clásico)`
  - `9:16 (Vertical)`

---

### 4️⃣ Quitar fondo (DESHABILITADO)

**Accordion expandido (siempre deshabilitado):**
```
┌────────────────────────────────┐
│  Quitar fondo              ˄   │
│                                │
│  ⚪ Activar remoción de fondo  │ <- Toggle DISABLED
│     (opacidad 50%)             │
│                                │
│  (Próximamente) Esta función   │
│  estará disponible en una      │
│  futura actualización.         │
└────────────────────────────────┘
```

**Elementos:**
- Título: "Quitar fondo"
- Toggle: "Activar remoción de fondo" (DISABLED, opacity: 0.5)
- Copy: **(Próximamente)** Esta función estará disponible en una futura actualización.
- Estilo: Todo el bloque con opacidad reducida, pointer-events: none

---

## 🚫 ELEMENTOS PROHIBIDOS EN ESTA PANTALLA

❌ **Ajustar brillo**  
❌ **Ajustar contraste**  
❌ **Eliminar metadatos**  
❌ **Watermarks** (va en Export)  
❌ **Calidad o formato** (va en Export)  
❌ **Filtros estéticos**  
❌ **Herramientas de dibujo**  
❌ **Selección manual**  
❌ **Preview Antes/Después en tiempo real**

---

## 🧭 NAVEGACIÓN

### Botón "Atrás" (Header izquierda)
- Icono: `←` (ArrowLeft)
- Acción: Vuelve a Home
- **Mantiene el estado** (si vuelves, recuperas la imagen seleccionada)

### Botón "Continuar" (Footer)
- Estilo: Primary button (w-full)
- Copy: "Continuar"
- Acción: Navega a pantalla Export
- **Siempre habilitado** (incluso si no hay operaciones activas)

---

## 📝 COPY Y TONO

### Reglas de Copy

✅ **Lenguaje claro y directo**  
✅ **Sin tecnicismos innecesarios**  
✅ **Sin promesas exageradas**  
✅ **Usar "(Próximamente)" para funciones no disponibles**  
❌ **No mencionar backend, cloud, tracking ni servicios externos**

### Ejemplos de Copy Correcto

- ✅ "Protege la identidad pixelando rostros detectados."
- ✅ "Difumina áreas sensibles de la imagen."
- ✅ "Recorta la imagen según el ratio seleccionado."
- ✅ "(Próximamente) Esta función estará disponible en una futura actualización."

### Ejemplos de Copy Incorrecto

- ❌ "Usamos IA avanzada para detectar rostros con 99% de precisión"
- ❌ "Procesamiento en la nube para mejores resultados"
- ❌ "Algoritmo de pixelado de última generación"
- ❌ "Protege tu privacidad con nuestra tecnología patentada"

---

## 🎨 SISTEMA DE DISEÑO

### Paleta de Colores (Neutral, Sobria)

```css
--background: 0 0% 100%;          /* Blanco */
--foreground: 0 0% 9%;            /* Casi negro */
--muted: 0 0% 96%;                /* Gris muy claro */
--muted-foreground: 0 0% 45%;     /* Gris medio */
--border: 0 0% 90%;               /* Gris claro */
--primary: 0 0% 18%;              /* Gris oscuro */
--primary-foreground: 0 0% 98%;   /* Blanco */
```

### Tipografía

- **Font family:** Inter, system-ui, sans-serif
- **Tamaños:**
  - Header: 18px (1.125rem)
  - Body: 16px (1rem)
  - Label: 14px (0.875rem)
  - Caption: 12px (0.75rem)

### Espaciado

- **Padding interno:** 16px (1rem)
- **Gap entre elementos:** 12px (0.75rem)
- **Border radius:** 8px (0.5rem)

### Componentes Base

**Toggle:**
- Estado OFF: bg-muted, thumb blanco
- Estado ON: bg-primary, thumb blanco
- Estado DISABLED: opacity 0.5

**Slider:**
- Track: bg-muted, height 4px
- Thumb: bg-primary, size 20px
- Label: sobre el slider, con valor numérico

**Dropdown:**
- Border: 1px solid border
- Background: background
- Padding: 12px
- Chevron: derecha

**Accordion:**
- Header: clickable, con chevron (rota 180° al expandir)
- Content: slide-in animado
- Border-bottom: entre secciones

---

## 📐 PANTALLA EXPORT (SIGUIENTE PASO)

**IMPORTANTE:** En la pantalla Export, el preview SÍ muestra la imagen procesada con todos los efectos aplicados.

### Preview en Export
```
┌────────────────────────────────┐
│  ← Exportar imagen             │
├────────────────────────────────┤
│                                │
│    ┌──────────────────┐        │
│    │   IMAGEN         │        │
│    │   PROCESADA      │        │ <- CON efectos
│    │   (con pixelado, │        │
│    │    blur, crop)   │        │
│    └──────────────────┘        │
│                                │
├────────────────────────────────┤
│  Formato de salida         ˅   │
├────────────────────────────────┤
│  Calidad                   ˅   │
├────────────────────────────────┤
│  Marca de agua (opcional)  ˅   │
├────────────────────────────────┤
│                                │
│       [Exportar]               │
└────────────────────────────────┘
```

### Opciones de Exportación

1. **Formato de salida**
   - JPEG (menor tamaño)
   - PNG (mayor calidad)

2. **Calidad** (solo para JPEG)
   - Slider: 10% - 100%
   - Default: 80%

3. **Marca de agua (opcional)**
   - Toggle ON/OFF
   - Input de texto
   - Selector de posición (4 esquinas)

---

## 🎯 OBJETIVO DEL DISEÑO

El usuario debe sentir que:

✅ **Siempre sabe qué imagen está tratando**  
✅ **Decide qué hacer, no cómo editar**  
✅ **Mantiene control visual constante**  
✅ **Nada sucede de forma opaca**

---

## ⚖️ CRITERIO FINAL

**Si el diseño empieza a parecer un editor de imagen genérico, está mal.**

- Simplicidad > potencia
- Claridad > efectos
- Control > espectáculo

---

## 📱 FRAMES A DISEÑAR EN herramienta de dise�o

### 1. WizardActions - Estado Empty
- Preview: placeholder "Selecciona una imagen"
- Panel: todos los accordions colapsados
- Botón: "Continuar" (habilitado)

### 2. WizardActions - Estado Loaded (todos colapsados)
- Preview: imagen cargada
- Panel: accordions colapsados
- Botón: "Continuar"

### 3. WizardActions - Pixelar rostro (expandido, toggle OFF)
- Preview: imagen original
- Panel: accordion expandido, toggle OFF
- Sin slider

### 4. WizardActions - Pixelar rostro (expandido, toggle ON)
- Preview: imagen original (SIN cambios)
- Panel: accordion expandido, toggle ON, slider visible
- Slider en 5

### 5. WizardActions - Blur selectivo (expandido, toggle ON)
- Preview: imagen original (SIN cambios)
- Panel: accordion expandido, toggle ON, slider visible
- Slider en 7

### 6. WizardActions - Crop inteligente (expandido, toggle ON)
- Preview: imagen original (SIN cambios)
- Panel: accordion expandido, toggle ON, dropdown visible
- Dropdown mostrando "1:1 (Cuadrado)"

### 7. WizardActions - Quitar fondo (expandido, DISABLED)
- Preview: imagen original
- Panel: accordion expandido, todo deshabilitado
- Texto "(Próximamente)"

### 8. ExportScreen - Con efectos aplicados
- Preview: imagen PROCESADA (con pixelado, blur, crop)
- Panel: opciones de exportación
- Botón: "Exportar"

### 9. ExportScreen - Watermark activado
- Preview: imagen procesada + watermark visible
- Panel: accordion de watermark expandido
- Input con texto, dropdown de posición

---

## 🔍 CHECKLIST DE VALIDACIÓN

Antes de finalizar el diseño en herramienta de dise�o, verificar:

- [ ] La imagen en WizardActions NUNCA muestra efectos procesados
- [ ] El preview es claramente la imagen ORIGINAL
- [ ] Los sliders solo aparecen cuando toggle está ON
- [ ] "Quitar fondo" está claramente deshabilitado
- [ ] NO hay opciones de brillo, contraste o metadatos
- [ ] El botón dice "Continuar", no "Grabar" ni "Procesar"
- [ ] La nota UX está incluida en el frame
- [ ] Los accordions tienen chevron que rota
- [ ] La pantalla Export SÍ muestra imagen procesada
- [ ] El tono del copy es directo, sin marketing

---

## 🚀 PRÓXIMOS PASOS

1. **Diseñar frames en herramienta de dise�o** según esta especificación
2. **Validar con stakeholders** que cumple el criterio de simplicidad
3. **Crear prototipo interactivo** en herramienta de dise�o para testing
4. **Realizar testing de usabilidad** con usuarios reales
5. **Iterar basándose en feedback**
6. **Entregar a desarrollo** (Flutter) con specs completas

---

**Imagen@rte v3.0**  
*Tratamiento de imágenes con control visual constante.*

**Fecha:** 2026-01-13  
**Estado:** ✅ Especificación completa para diseño en herramienta de dise�o  
**Próximo paso:** Diseñar frames en herramienta de dise�o

