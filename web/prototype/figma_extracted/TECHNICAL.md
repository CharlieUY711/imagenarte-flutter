# Notas Técnicas - Imagen@rte Prototipo

## Arquitectura del Prototipo

### Stack Tecnológico
- **Frontend Framework:** React 18.3.1
- **Styling:** Tailwind CSS v4.1.12
- **UI Components:** Radix UI (headless components)
- **Build Tool:** Vite 6.3.5
- **Language:** TypeScript (implícito via JSX/TSX)

### Estructura de Componentes

```
App.tsx (Estado global + Router)
│
├── Home.tsx
├── WizardStep1.tsx
├── WizardStep2.tsx
├── WizardStep3.tsx
└── Export.tsx

Componentes reutilizables:
├── Button.tsx
├── Toggle.tsx
├── Slider.tsx
├── Dropdown.tsx
├── Stepper.tsx
├── ImagePreview.tsx
└── SectionCard.tsx
```

### Estado Global

El estado se maneja en `App.tsx` sin librerías externas:

```typescript
{
  currentScreen: 'home' | 'step1' | 'step2' | 'step3' | 'export',
  selectedImage: string | null,  // Base64 data URL
  actions: {
    pixelate: { enabled: boolean, intensity: 1-10 },
    blur: { enabled: boolean, intensity: 1-10 },
    removeBackground: { enabled: boolean },
    crop: { enabled: boolean, aspectRatio: '1:1' | '4:3' | '16:9' | '9:16' }
  }
}
```

---

## Procesamiento de Imágenes

### Canvas API

El prototipo usa la **Canvas API** del navegador para procesar imágenes localmente.

#### Selección de Imagen

```javascript
// HTML File Input
<input type="file" accept="image/*" />

// FileReader para convertir a Base64
const reader = new FileReader();
reader.readAsDataURL(file);
reader.onload = (e) => setImage(e.target.result);
```

#### Procesamiento

```javascript
const canvas = document.createElement('canvas');
const ctx = canvas.getContext('2d');

// Cargar imagen
const img = new Image();
img.src = selectedImageBase64;

// Aplicar efectos
if (pixelate.enabled) {
  ctx.filter = `blur(${intensity * 2}px)`;  // Simulación
}

if (blur.enabled) {
  ctx.filter = `blur(${intensity}px)`;
}

// Watermark visible
if (watermarkVisible && text) {
  ctx.font = '24px sans-serif';
  ctx.fillStyle = 'rgba(255, 255, 255, 0.7)';
  ctx.fillText(text, 20, canvas.height - 20);
}
```

#### Exportación

```javascript
canvas.toBlob((blob) => {
  const url = URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = url;
  link.download = `imagen-arte-${Date.now()}.${format}`;
  link.click();
  URL.revokeObjectURL(url);
}, mimeType, quality);
```

---

## Limitaciones del Prototipo

### 1. Metadatos EXIF
**Estado actual:** Simulado (toggle visual únicamente)

**Por qué:** Los navegadores web NO exponen acceso directo a metadatos EXIF de imágenes por razones de privacidad.

**Solución para producción:** 
- Implementar en Flutter/nativo con librerías como `image/exif` (Dart) o `ExifInterface` (Android).
- En web: usar librerías JS como `piexifjs` (no implementado en prototipo).

---

### 2. Detección de Rostros
**Estado actual:** No implementado (pixelate manual)

**Por qué:** Requiere modelos ML (TensorFlow.js/MediaPipe) que exceden el alcance del prototipo.

**Solución para producción:**
- En Flutter: usar ML Kit o TensorFlow Lite
- En web: MediaPipe Face Detection (pero es pesado para MVP)

---

### 3. Watermark Invisible (Esteganografía)
**Estado actual:** Simulado (genera UUID pero no lo embebe)

**Por qué:** La esteganografía real requiere manipulación de bits LSB (Least Significant Bit) en píxeles.

**Implementación básica real:**
```javascript
// Ejemplo conceptual (no incluido en prototipo)
function embedWatermark(imageData, token) {
  const tokenBits = stringToBits(token);
  for (let i = 0; i < tokenBits.length; i++) {
    const pixelIndex = i * 4; // RGBA
    const lsb = imageData.data[pixelIndex] & 0xFE; // Limpiar LSB
    imageData.data[pixelIndex] = lsb | tokenBits[i]; // Escribir bit
  }
}
```

**Solución para producción:**
- Usar librerías especializadas como `steg.js` o implementar en nativo.

---

### 4. Quitar Fondo
**Estado actual:** Deshabilitado (próximamente)

**Por qué:** Requiere modelos de segmentación semántica (BodyPix, DeepLab, etc.).

**Solución para producción:**
- TensorFlow.js con modelo BodyPix (web)
- Flutter + TensorFlow Lite (móvil)
- Advertencia: es costoso computacionalmente

---

### 5. Crop Inteligente
**Estado actual:** Solo selector de aspect ratio (no aplica crop real)

**Por qué:** El prototipo solo muestra la UI; el crop real requiere:
- Detección de área de interés (saliency detection)
- Recorte y redimensionamiento del canvas

**Implementación básica:**
```javascript
// Ejemplo conceptual
function cropToAspectRatio(canvas, ratio) {
  const [width, height] = parseRatio(ratio); // ej: [16, 9]
  const targetAspect = width / height;
  const currentAspect = canvas.width / canvas.height;
  
  let newWidth = canvas.width;
  let newHeight = canvas.height;
  
  if (currentAspect > targetAspect) {
    newWidth = canvas.height * targetAspect;
  } else {
    newHeight = canvas.width / targetAspect;
  }
  
  // Centrar y recortar...
}
```

---

## Flujo de Datos

### Navegación entre Pantallas

```
Home
  ↓ onStartImageFlow()
  → setCurrentScreen('step1')

WizardStep1
  ↓ onImageSelect(file)
  → reader.readAsDataURL() → setSelectedImage(base64)
  ↓ onNext()
  → setCurrentScreen('step2')

WizardStep2
  ↓ onActionsChange(actions)
  → setActions({ ...actions })
  ↓ onNext()
  → setCurrentScreen('step3')

WizardStep3
  ↓ (solo vista de resumen)
  ↓ onNext()
  → setCurrentScreen('export')

Export
  ↓ handleExport()
  → Procesar canvas → toBlob() → download
  ↓ setExportSuccess(true)
  → Mostrar pantalla de éxito

Success
  ↓ onReset()
  → setCurrentScreen('home')
  → setSelectedImage(null)
  → setActions(initialState)
```

---

## Simulaciones vs Implementación Real

| Característica | Prototipo | Producción |
|---|---|---|
| **Selección de imagen** | ✅ Real (File Input) | ✅ Real (File Picker / Camera) |
| **Preview de imagen** | ✅ Real (Base64) | ✅ Real |
| **Pixelar rostro** | ⚠️ Blur genérico | ❌ Requiere ML (Face Detection) |
| **Blur selectivo** | ⚠️ Blur completo | ❌ Requiere selección manual/ML |
| **Quitar fondo** | ❌ Deshabilitado | ❌ Requiere ML (Segmentation) |
| **Crop inteligente** | ⚠️ Solo UI | ❌ Requiere saliency detection |
| **Exportar JPG/PNG/WebP** | ✅ Real | ✅ Real |
| **Slider de calidad** | ✅ Real | ✅ Real |
| **Limpiar EXIF** | ❌ Simulado (UI) | ❌ Requiere librería nativa |
| **Watermark visible** | ✅ Real (texto en canvas) | ✅ Real |
| **Watermark invisible** | ❌ Simulado (UUID) | ❌ Requiere esteganografía |
| **Manifest.json** | ✅ Real (descarga JSON) | ✅ Real |

---

## Optimizaciones para Producción

### Performance
1. **Lazy loading** de componentes pesados (Export, WizardStep2)
2. **Web Workers** para procesamiento de imágenes (no bloquear UI)
3. **Throttling** en sliders para evitar renders excesivos
4. **Compression** antes de exportar (mantener calidad vs tamaño)

### Accesibilidad
1. Agregar `aria-label` a todos los controles
2. Navegación completa con teclado
3. Anuncios de screen reader en cambios de pantalla
4. Contraste WCAG AA (ya cumplido con colores neutros)

### PWA (Offline-First)
1. Service Worker para cachear assets
2. Manifest.json para instalación como app
3. Storage API para guardar imágenes temporalmente (IndexedDB)

### Testing
1. **Unit tests:** Componentes individuales (Jest + RTL)
2. **Integration tests:** Flujo completo (Playwright)
3. **E2E tests:** Escenarios de usuario (Cypress)
4. **Visual regression:** Comparación de screenshots (Percy/Chromatic)

---

## Consideraciones de Privacidad

### ✅ Implementado
- Todas las operaciones son **client-side**
- No se envían imágenes a servidores
- No hay tracking/analytics
- Estado se pierde al refrescar (no persiste)

### ⚠️ Para Producción
- **Storage local:** Si se implementa cache/historial, usar IndexedDB con encriptación
- **Permisos de cámara:** Pedir solo cuando el usuario elija "Cámara" (no al inicio)
- **CORS:** Si se agregan features de carga desde URL, validar orígenes
- **HTTPS obligatorio:** Para acceso a cámara y APIs sensibles

---

## Dependencias del Prototipo

### Core
```json
{
  "react": "18.3.1",
  "react-dom": "18.3.1"
}
```

### UI
```json
{
  "@radix-ui/react-switch": "1.1.3",
  "@radix-ui/react-slider": "1.2.3",
  "@radix-ui/react-select": "2.1.6",
  "lucide-react": "0.487.0"
}
```

### Styling
```json
{
  "tailwindcss": "4.1.12",
  "tailwind-merge": "3.2.0",
  "class-variance-authority": "0.7.1"
}
```

### Build
```json
{
  "vite": "6.3.5",
  "@vitejs/plugin-react": "4.7.0"
}
```

---

## Próximos Pasos Técnicos

### Para Implementación Flutter
1. Migrar componentes a Widgets de Flutter
2. Usar `image` package para manipulación
3. Integrar ML Kit para detección de rostros
4. Usar `path_provider` para storage local
5. Implementar `share_plus` para compartir (si se agrega)

### Para Mejorar el Prototipo Web
1. Agregar Web Workers para procesamiento
2. Implementar `piexifjs` para EXIF real
3. Integrar TensorFlow.js para detección de rostros (opcional)
4. Mejorar feedback visual durante procesamiento (progress bars)
5. Agregar PWA manifest y service worker

---

**Última actualización:** 2026-01-13  
**Versión:** 1.0
