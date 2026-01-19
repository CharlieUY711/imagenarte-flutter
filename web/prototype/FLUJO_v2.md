# Flujo Simplificado - Imagen@rte v2.0

**Cambio principal:** Eliminado el wizard de 3 pasos. Ahora todo sucede en **una sola pantalla** con la imagen siempre visible arriba y herramientas colapsables abajo.

---

## 🎯 Flujo Canónico (Simplificado)

```
HOME → SELECCIONAR IMAGEN → IMAGE EDITOR (edit) → IMAGE EDITOR (export) → EXPORTAR → HOME
```

---

## 📱 Estructura de Pantallas

### 1️⃣ HOME (sin cambios)

```
┌────────────────────────┐
│                        │
│    Imagen@rte          │
│                        │
│   Tratamiento y        │
│   protección de        │
│   imágenes, sin nube.  │
│                        │
│  [Tratar imagen]       │
│                        │
│  [Tratar video]        │
│  (próximamente)        │
│                        │
└────────────────────────┘
```

**Acción:** Clic en "Tratar imagen" → Abre selector de archivo nativo → Selecciona imagen → Va a IMAGE EDITOR

---

### 2️⃣ IMAGE EDITOR (modo: edit)

Nueva pantalla única que reemplaza WizardStep1, Step2 y Step3.

```
┌────────────────────────┐
│ ← Editar imagen        │  <- Header con botón volver
├────────────────────────┤
│                        │
│   ┌──────────────┐     │
│   │   IMAGEN     │     │  <- 50% de altura (fija, siempre visible)
│   │   PREVIEW    │     │     Se actualiza en tiempo real
│   │  (updated)   │     │
│   └──────────────┘     │
│                        │
├────────────────────────┤
│ Desenfocar rostros  ˅  │  <- Acordeón (colapsado)
├────────────────────────┤
│ Ajustar brillo      ˅  │  <- Acordeón (colapsado)
├────────────────────────┤
│ Ajustar contraste   ˅  │  <- Acordeón (colapsado)
├────────────────────────┤
│ Eliminar metadatos  ˅  │  <- Acordeón (colapsado)
├────────────────────────┤
│                        │
│     [Grabar]           │  <- Botón fijo inferior
└────────────────────────┘
```

**Interacciones:**
- **Clic en un acordeón** → Se expande, muestra controles (Toggle/Slider)
- **Cambio en controles** → Preview se actualiza en tiempo real
- **Clic en "Grabar"** → Cambia a modo "export" (misma pantalla)
- **Botón "←"** → Vuelve a Home (confirma pérdida de cambios)

**Ejemplo de acordeón expandido:**

```
├────────────────────────┤
│ Ajustar brillo      ˄  │  <- Acordeón expandido
│                        │
│  [x] Activar ajuste    │  <- Toggle
│      de brillo         │
│                        │
│  Brillo: +25           │  <- Slider
│  ├────●─────────┤      │
│  -100         +100     │
│                        │
├────────────────────────┤
```

---

### 3️⃣ IMAGE EDITOR (modo: export)

Misma pantalla, pero ahora muestra opciones de exportación.

```
┌────────────────────────┐
│ ← Opciones de          │  <- Header (botón volver regresa a modo edit)
│   exportación          │
├────────────────────────┤
│                        │
│   ┌──────────────┐     │
│   │   IMAGEN     │     │  <- MISMA IMAGEN (fija)
│   │   FINAL      │     │     Con todas las ediciones aplicadas
│   │ (con cambios)│     │
│   └──────────────┘     │
│                        │
├────────────────────────┤
│ Formato de salida   ˅  │  <- Acordeón (colapsado)
├────────────────────────┤
│ Calidad de          ˅  │  <- Acordeón (colapsado)
│ compresión             │
├────────────────────────┤
│ Marca de agua       ˅  │  <- Acordeón (colapsado)
├────────────────────────┤
│                        │
│    [Exportar]          │  <- Botón fijo inferior
└────────────────────────┘
```

**Interacciones:**
- **Clic en un acordeón** → Se expande, muestra opciones
- **Cambio en opciones** → Preview se actualiza (ej: watermark)
- **Clic en "Exportar"** → Descarga imagen → Vuelve a Home
- **Botón "←"** → Vuelve a modo "edit" (sin perder cambios)

---

## 🔄 Diagrama de Flujo Completo

```
                    ┌─────────┐
                    │  HOME   │
                    └────┬────┘
                         │
                    [Tratar imagen]
                         │
                         ▼
              ┌──────────────────────┐
              │ Selector de archivo  │ (nativo del sistema)
              │ (input type="file")  │
              └──────────┬───────────┘
                         │
                [Selecciona imagen.jpg]
                         │
                         ▼
         ┌───────────────────────────────────┐
         │   IMAGE EDITOR (modo: edit)       │
         │                                   │
         │   ╔═══════════════════╗           │
         │   ║  IMAGEN PREVIEW   ║  50vh     │
         │   ║   (actualizada)   ║           │
         │   ╚═══════════════════╝           │
         │                                   │
         │   Desenfocar rostros      ˅       │
         │   Ajustar brillo          ˅       │
         │   Ajustar contraste       ˅       │
         │   Eliminar metadatos      ˅       │
         │                                   │
         │         [Grabar]                  │
         └─────────────┬─────────────────────┘
                       │
                  [Clic Grabar]
                       │
                       ▼
         ┌───────────────────────────────────┐
         │  IMAGE EDITOR (modo: export)      │
         │                                   │
         │   ╔═══════════════════╗           │
         │   ║  IMAGEN FINAL     ║  50vh     │
         │   ║ (con todas las    ║           │
         │   ║  ediciones)       ║           │
         │   ╚═══════════════════╝           │
         │                                   │
         │   Formato de salida       ˅       │
         │   Calidad de compresión   ˅       │
         │   Marca de agua           ˅       │
         │                                   │
         │        [Exportar]                 │
         └─────────────┬─────────────────────┘
                       │
                  [Clic Exportar]
                       │
                       ▼
                ┌──────────────┐
                │  Descarga    │
                │  imagen.jpg  │
                └──────┬───────┘
                       │
                       ▼
                  ┌─────────┐
                  │  HOME   │
                  └─────────┘
```

---

## 🎨 Ventajas del Nuevo Flujo

### ✅ Mejoras UX

1. **Imagen siempre visible**
   - El usuario ve el resultado en tiempo real
   - No hay que "recordar" cómo quedó la imagen
   - Feedback inmediato de los cambios

2. **Sin scroll**
   - Imagen fija en 50% superior
   - Herramientas colapsables en 50% inferior
   - Todo cabe en pantalla de móvil

3. **Menos pasos**
   - Home → Edit → Export (2 pantallas vs 5 anteriores)
   - Menos navegación = menos fricción

4. **Navegación clara**
   - "Grabar" = paso siguiente (edit → export)
   - "Exportar" = finalizar y descargar
   - "←" = volver atrás o cancelar

5. **Acordeones = menos sobrecarga cognitiva**
   - Solo se ve el título de cada herramienta
   - Usuario expande solo lo que necesita
   - Menos información visual a la vez

### ✅ Ventajas Técnicas

1. **Menos componentes**
   - 1 pantalla vs 4 pantallas del wizard
   - Menos estado compartido
   - Menos props drilling

2. **Preview en tiempo real**
   - Canvas se actualiza con cada cambio
   - No hay "vista previa" separada
   - Menos confusión entre "antes/después"

3. **Más eficiente**
   - No se re-renderiza toda la app al cambiar de paso
   - Solo cambia la sección inferior
   - Imagen se procesa una vez y se actualiza

---

## 📋 Estados de la Pantalla IMAGE EDITOR

### Estado: Loading (inicial)

```
┌────────────────────────┐
│ ← Editar imagen        │
├────────────────────────┤
│                        │
│   Cargando imagen...   │  <- Mientras se procesa File
│                        │
├────────────────────────┤
│                        │
└────────────────────────┘
```

### Estado: Edit (modo edición)

```
- Header: "Editar imagen"
- Preview: Imagen con cambios aplicados
- Secciones: Acciones (Desenfocar, Brillo, Contraste, Metadatos)
- Botón: "Grabar"
- Botón volver: regresa a Home
```

### Estado: Export (modo exportación)

```
- Header: "Opciones de exportación"
- Preview: Imagen final con todas las ediciones
- Secciones: Opciones (Formato, Calidad, Watermark)
- Botón: "Exportar" (con loading state)
- Botón volver: regresa a modo Edit
```

### Estado: Exporting (procesando)

```
- Botón cambia a: "Exportando..." con spinner
- Acordeones deshabilitados
- Después de export → vuelve a Home automáticamente
```

---

## 🧩 Componentes Nuevos

### CollapsibleSection

**Props:**
```tsx
{
  title: string;           // "Desenfocar rostros"
  children: ReactNode;     // Controles (Toggle, Slider, etc)
  defaultOpen?: boolean;   // false por defecto
  onToggle?: (isOpen: boolean) => void;
}
```

**Uso:**
```tsx
<CollapsibleSection title="Ajustar brillo">
  <Toggle label="Activar ajuste de brillo" ... />
  <Slider label="Brillo: +25" ... />
</CollapsibleSection>
```

**Comportamiento:**
- Clic en el header → expande/colapsa
- Icono chevron rota 180° al expandir
- Animación suave (slide-in-from-top)
- Border inferior entre secciones

---

## 🔧 Arquitectura Técnica

### Flujo de Datos

```
App.tsx
  ├─ selectedImageFile (File | null)
  ├─ currentScreen ('home' | 'editor')
  └─ handleStartImageFlow()
      └─ Abre <input type="file">
          └─ Selecciona archivo
              └─ setCurrentScreen('editor')

ImageEditor.tsx
  ├─ mode ('edit' | 'export')
  ├─ actions (ActionsState)
  ├─ exportOptions (format, quality, watermark)
  ├─ previewUrl (string - data URL del canvas)
  └─ canvasRef (HTMLCanvasElement)
      └─ applyActionsToImage()
          └─ Dibuja imagen + aplica filtros
              └─ Actualiza previewUrl
```

### Procesamiento en Tiempo Real

```
Usuario cambia un control (Toggle/Slider)
  ↓
setState de actions
  ↓
useEffect detecta cambio en actions
  ↓
applyActionsToImage(originalImage)
  ↓
Canvas API aplica filtros
  ↓
canvas.toDataURL() → previewUrl
  ↓
<img src={previewUrl}> se actualiza
  ↓
Usuario ve el cambio INMEDIATAMENTE
```

---

## 🎯 Casos de Uso

### Caso 1: Usuario aplica brillo y exporta

```
1. Home → Clic "Tratar imagen"
2. Selecciona foto.jpg
3. IMAGE EDITOR (edit)
   - Clic en "Ajustar brillo" → Se expande
   - Activa toggle
   - Mueve slider a +30
   - Preview se actualiza en tiempo real
4. Clic en "Grabar"
5. IMAGE EDITOR (export)
   - Clic en "Formato de salida" → Selecciona JPEG
   - Clic en "Calidad de compresión" → 85%
6. Clic en "Exportar"
7. Descarga imagenarte_123456.jpeg
8. Vuelve a Home
```

### Caso 2: Usuario cambia de opinión

```
1. Home → Selecciona imagen
2. IMAGE EDITOR (edit)
   - Aplica varios cambios
   - Clic en "Grabar"
3. IMAGE EDITOR (export)
   - Configura opciones
   - Piensa "mejor cambio el brillo"
   - Clic en "←" (volver)
4. IMAGE EDITOR (edit) <- Vuelve aquí
   - Ajusta brillo
   - Clic en "Grabar" de nuevo
5. IMAGE EDITOR (export)
   - Clic en "Exportar"
```

### Caso 3: Usuario cancela todo

```
1. Home → Selecciona imagen
2. IMAGE EDITOR (edit)
   - Aplica cambios
   - Cambia de opinión
   - Clic en "←" (volver)
3. HOME <- Vuelve al inicio
   (Se pierde todo el progreso)
```

---

## 📏 Dimensiones de Layout

### Mobile (390x844 - iPhone)

```
┌─────────────────┐  ─┐
│  Header (60px)  │   │
├─────────────────┤   │
│                 │   │
│     IMAGEN      │   │  50vh (422px)
│    (preview)    │   │
│                 │   │
├─────────────────┤  ─┤
│  Acordeón 1     │   │
│  Acordeón 2     │   │  Resto (362px)
│  Acordeón 3     │   │  Con scroll si es necesario
│  ...            │   │
│                 │   │
│  [Botón] (60px) │   │
└─────────────────┘  ─┘
```

**Proporciones:**
- Header: fijo 60px
- Preview: 50vh (~422px en iPhone)
- Herramientas: flex-1 con overflow-y-auto
- Botón: fijo 60px con padding

---

## ✅ Checklist de Implementación

### Componentes

- [x] CollapsibleSection.tsx
- [x] ImageEditor.tsx (modo edit)
- [x] ImageEditor.tsx (modo export)
- [x] Actualizar App.tsx (flujo simplificado)

### Funcionalidades

- [x] Selector de archivo nativo
- [x] Preview en tiempo real
- [x] Canvas API para filtros
- [x] Acordeones expandibles
- [x] Modo edit → export
- [x] Exportación con descarga
- [x] Navegación back (edit ← export)
- [x] Navegación back (home ← edit)

### UI/UX

- [x] Imagen siempre visible (50vh)
- [x] Sin scroll en la imagen
- [x] Herramientas colapsables
- [x] Animaciones suaves (slide-in)
- [x] Feedback de loading
- [x] Botón con estado loading

---

## 🚀 Próximos Pasos

### Testing

1. Validar que no hay scroll innecesario
2. Validar que la imagen es claramente visible
3. Validar que los acordeones son intuitivos
4. Validar que el flujo edit → export es claro
5. Validar que el botón "←" es predecible

### Posibles Mejoras

1. **Confirmación antes de volver**
   - Si hay cambios sin guardar
   - Alert: "¿Descartar cambios?"

2. **Preview antes/después**
   - Botón para comparar original vs editada
   - Slider para comparar (wipe effect)

3. **Deshacer/Rehacer**
   - Stack de estados
   - Botones en header

4. **Presets de edición**
   - "Optimizar para web"
   - "Máxima privacidad"
   - "Solo watermark"

---

**Imagen@rte v2.0 - Flujo simplificado**  
*Una pantalla, cero fricciones.*

**Fecha:** 2026-01-13  
**Estado:** ✅ Implementado

