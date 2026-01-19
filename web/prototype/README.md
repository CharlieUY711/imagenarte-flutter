# Imagen@rte - Prototipo Funcional Web

**Versión:** 3.0 (Wizard con Preview Persistente)  
**Fecha:** 2026-01-13  
**Estado:** Prototipo completo según brief de diseño herramienta de dise�o

---

## 🎯 ¿Qué es esto?

Prototipo funcional **mobile-first** de Imagen@rte que sirve como **referencia visual exacta** para el diseño en herramienta de dise�o.

**Decisión UX clave:** La imagen seleccionada permanece siempre visible (sin procesamiento en tiempo real). El procesamiento real ocurre en la pantalla Export.

**Objetivo:** Validar flujo UX y servir como guía de implementación antes del diseño pixel-perfect en herramienta de dise�o.

---

## ✅ Flujo Implementado (v3.0)

```
HOME → Seleccionar imagen → WIZARD (preview persistente) → EXPORT (procesamiento) → HOME
```

### Arquitectura

**Pantalla WIZARD (WizardActions):**
- **Preview superior (45vh):** Muestra imagen ORIGINAL (sin efectos en tiempo real)
- **Panel inferior (scrollable):** 4 operaciones MVP en accordions
- **Sin procesamiento en tiempo real**
- Botón: "Continuar"

**Pantalla EXPORT (ExportScreen):**
- **Preview superior (45vh):** Muestra imagen PROCESADA (con todos los efectos)
- **Panel inferior (scrollable):** Opciones de exportación
- **Aquí SÍ se procesa la imagen**
- Botón: "Exportar"

---

## 🎛️ Operaciones MVP Implementadas

### En WIZARD (sin preview en tiempo real):

1. **Pixelar rostro**
   - Toggle ON/OFF
   - Slider de intensidad (1-10)
   - Copy: "Protege la identidad pixelando rostros detectados."

2. **Blur selectivo**
   - Toggle ON/OFF
   - Slider de intensidad (1-10)
   - Copy: "Difumina áreas sensibles de la imagen."

3. **Crop inteligente**
   - Toggle ON/OFF
   - Selector de ratio: 1:1, 16:9, 4:3, 9:16
   - Copy: "Recorta la imagen según el ratio seleccionado."

4. **Quitar fondo** (DESHABILITADO)
   - Toggle DISABLED (opacity 0.5)
   - Copy: "(Próximamente) Esta función estará disponible..."

### En EXPORT (con procesamiento):

5. **Formato de salida**
   - JPEG (menor tamaño)
   - PNG (mayor calidad)

6. **Calidad**
   - Slider 10-100% (solo para JPEG)

7. **Marca de agua (opcional)**
   - Toggle ON/OFF
   - Input de texto
   - Selector de posición (4 esquinas)

---

## 🚫 Elementos Prohibidos (NO incluidos)

❌ Ajustar brillo  
❌ Ajustar contraste  
❌ Eliminar metadatos  
❌ Filtros estéticos  
❌ Herramientas de dibujo  
❌ Preview antes/después en tiempo real en Wizard

---

## 📱 Instrucciones de Uso

### Como Diseñador UX/UI

1. **Explorar el prototipo web** en navegador
2. **Usar DevTools** (F12) → Toggle device toolbar (Ctrl+Shift+M)
3. **Configurar como iPhone** (390×844)
4. **Observar comportamiento:**
   - Preview NO cambia al mover sliders en Wizard
   - Preview SÍ cambia en Export
   - Accordions expandibles
   - Toggle DISABLED en "Quitar fondo"
5. **Usar como referencia** para diseño en herramienta de dise�o

### Como Tester

1. Seleccionar una imagen con rostros
2. Activar "Pixelar rostro" → mover slider → ver que preview NO cambia
3. Clic en "Continuar"
4. En Export, ahora SÍ ver la imagen procesada
5. Configurar opciones de exportación
6. Clic en "Exportar" → descargar resultado

---

## 🎨 Sistema de Diseño

### Paleta (Neutral, Sobria)

```css
--background: #FFFFFF (blanco)
--foreground: #171717 (casi negro)
--muted: #F5F5F5 (gris muy claro)
--border: #E5E5E5 (gris claro)
--primary: #2E2E2E (gris oscuro)
```

### Tipografía

- Font: Inter, system-ui, sans-serif
- Header: 18px (1.125rem)
- Body: 16px (1rem)
- Label: 14px (0.875rem)

### Espaciado

- Padding: 16px (1rem)
- Gap: 12px (0.75rem)
- Border radius: 8px (0.5rem)

---

## 🔧 Arquitectura Técnica

### Flujo de Datos

```
App.tsx
  ├─ currentScreen: 'home' | 'wizard' | 'export'
  ├─ selectedImageFile: File | null
  ├─ imageUrl: string (URL.createObjectURL)
  └─ actions: ActionsStateMVP
      ├─ pixelate: { enabled, intensity }
      ├─ blur: { enabled, intensity }
      ├─ crop: { enabled, ratio }
      └─ removeBackground: { enabled: false }

WizardActions.tsx (Wizard)
  - Muestra imageUrl ORIGINAL
  - NO procesa imagen
  - Usuario configura actions
  - Botón "Continuar" → export

ExportScreen.tsx (Export)
  - Recibe imageUrl + actions
  - Canvas API procesa imagen
  - Aplica todos los efectos
  - Muestra preview procesado
  - Botón "Exportar" → descarga
```

### Procesamiento (solo en Export)

```typescript
Canvas API:
1. Dibujar imagen original
2. Si crop.enabled → recortar según ratio
3. Si pixelate.enabled → pixelar área de rostro
4. Si blur.enabled → aplicar blur
5. Si watermark → dibujar texto
6. canvas.toBlob() → descargar
```

---

## 📋 Componentes Reutilizables

### CollapsibleSection
- Accordion expandible
- Chevron que rota 180°
- Animación slide-in

### Toggle
- Estados: ON / OFF / DISABLED
- Visual: switch con thumb

### Slider
- Label con valor numérico
- Min/max configurables
- Puede deshabilitarse

### Dropdown
- Select nativo estilizado
- Opciones con labels descriptivos

---

## 📄 Documentación Completa

### Para Diseñadores
- **[DESIGN_SPEC.md](./DESIGN_SPEC.md)** - Especificación completa para diseño en herramienta de dise�o
  - Todos los estados del wizard
  - Copy exacto
  - Dimensiones y proporciones
  - Paleta y tipografía
  - Checklist de validación

### Para Testers
- **[TESTING.md](./TESTING.md)** - Guía de testing UX (actualizar con v3)

### Para Developers
- **[TECHNICAL.md](./TECHNICAL.md)** - Notas técnicas de implementación

### Navegación
- **[INDEX.md](./INDEX.md)** - Índice completo de documentación

---

## 🎯 Criterio de Diseño

**Si el diseño empieza a parecer un editor de imagen genérico, está mal.**

Principios:
- **Simplicidad > potencia**
- **Claridad > efectos**
- **Control > espectáculo**

El usuario debe sentir:
- ✅ Siempre sabe qué imagen está tratando
- ✅ Decide qué hacer, no cómo editar
- ✅ Mantiene control visual constante
- ✅ Nada sucede de forma opaca

---

## 🚀 Próximos Pasos

1. **Validar prototipo web** con stakeholders
2. **Diseñar en herramienta de dise�o** usando DESIGN_SPEC.md como guía
3. **Testing de usabilidad** con prototipo herramienta de dise�o
4. **Iterar basándose en feedback**
5. **Implementar en Flutter**

---

## 📞 Uso de este Prototipo

### ✅ Este prototipo ES:
- Referencia visual para diseño herramienta de dise�o
- Validación de flujo UX
- Demo interactivo para stakeholders
- Guía de comportamiento de componentes

### ❌ Este prototipo NO ES:
- Implementación final (será Flutter)
- Diseño pixel-perfect (será herramienta de dise�o)
- Sistema de procesamiento real (es simulación)

---

## 🔍 Puntos Clave para Validar

Al explorar el prototipo, validar:

- [ ] Preview en Wizard muestra imagen ORIGINAL (sin efectos)
- [ ] Sliders y toggles NO cambian el preview en Wizard
- [ ] "Quitar fondo" está claramente deshabilitado
- [ ] Botón dice "Continuar", no "Procesar"
- [ ] Al llegar a Export, ahora SÍ se ve imagen procesada
- [ ] El copy es directo, sin marketing
- [ ] NO hay opciones de brillo/contraste/metadatos

---

## 💡 Nota de Diseño UX

> **"La imagen permanece fija como referencia visual.**  
> **El procesamiento real ocurre en la pantalla de Export.**  
> **No hay preview procesado en tiempo real en este paso."**

Esta decisión UX es **obligatoria** y debe respetarse en todas las fases del proyecto (herramienta de dise�o, Flutter, testing).

---

**Imagen@rte v3.0**  
*Tratamiento de imágenes con control visual constante.*

**Fecha:** 2026-01-13  
**Estado:** ✅ Completo según especificación de diseño  
**Próximo paso:** Diseñar frames en herramienta de dise�o usando DESIGN_SPEC.md

