# Guía de Componentes - Imagen@rte

Sistema de componentes reutilizables del prototipo.

---

## 📦 Componentes Base

### Button

**Ubicación:** `/src/app/components/Button.tsx`

**Variantes:**
- `primary` - Botón principal (fondo negro, texto blanco)
- `secondary` - Botón secundario (fondo gris claro, texto negro)

**Estados:**
- `default` - Estado normal
- `pressed` - Cuando se presiona (scale 0.98)
- `disabled` - Deshabilitado (opacity 50%)
- `loading` - Mostrando spinner

**Props:**
```typescript
{
  variant?: 'primary' | 'secondary';
  isLoading?: boolean;
  disabled?: boolean;
  onClick?: () => void;
  children: ReactNode;
}
```

**Uso:**
```tsx
<Button variant="primary" onClick={handleClick}>
  Siguiente
</Button>

<Button variant="secondary" disabled>
  Tratar video (próximamente)
</Button>

<Button variant="primary" isLoading>
  Exportando...
</Button>
```

---

### Toggle

**Ubicación:** `/src/app/components/Toggle.tsx`

**Variantes:**
- Estándar (solo label)
- Con subtítulo (label + texto explicativo)

**Estados:**
- `off` - Desactivado (gris)
- `on` - Activado (negro)
- `disabled` - Deshabilitado (gris claro + opacity)

**Props:**
```typescript
{
  label: string;
  subtitle?: string;
  checked: boolean;
  onCheckedChange: (checked: boolean) => void;
  disabled?: boolean;
  id?: string;
}
```

**Uso:**
```tsx
<Toggle
  label="Pixelar rostro"
  checked={pixelate.enabled}
  onCheckedChange={(checked) => setPixelate({ ...pixelate, enabled: checked })}
  id="toggle-pixelate"
/>

<Toggle
  label="Limpiar metadatos (EXIF)"
  subtitle="Recomendado: elimina información que puede revelar detalles del dispositivo."
  checked={cleanMetadata}
  onCheckedChange={setCleanMetadata}
  id="toggle-metadata"
/>
```

---

### Slider

**Ubicación:** `/src/app/components/Slider.tsx`

**Variantes:**
- Intensidad (1-10)
- Calidad (50-100)

**Props:**
```typescript
{
  label: string;
  value: number;
  onValueChange: (value: number) => void;
  min: number;
  max: number;
  step?: number;
  disabled?: boolean;
}
```

**Uso:**
```tsx
<Slider
  label="Intensidad"
  value={intensity}
  onValueChange={setIntensity}
  min={1}
  max={10}
/>

<Slider
  label="Calidad"
  value={quality}
  onValueChange={setQuality}
  min={50}
  max={100}
/>
```

---

### Dropdown

**Ubicación:** `/src/app/components/Dropdown.tsx`

**Variantes:**
- Formato (JPG/PNG/WebP)
- Aspect Ratio (1:1, 4:3, 16:9, 9:16)

**Estados:**
- `closed` - Cerrado (muestra valor seleccionado)
- `open` - Abierto (muestra opciones)
- `disabled` - Deshabilitado

**Props:**
```typescript
{
  label: string;
  value: string;
  onValueChange: (value: string) => void;
  options: Array<{ value: string; label: string }>;
  disabled?: boolean;
}
```

**Uso:**
```tsx
<Dropdown
  label="Formato"
  value={format}
  onValueChange={setFormat}
  options={[
    { value: 'jpg', label: 'JPG' },
    { value: 'png', label: 'PNG' },
    { value: 'webp', label: 'WebP' },
  ]}
/>
```

---

### Stepper

**Ubicación:** `/src/app/components/Stepper.tsx`

**Descripción:** Indicador de progreso "Paso X de Y"

**Props:**
```typescript
{
  currentStep: number;
  totalSteps: number;
}
```

**Uso:**
```tsx
<Stepper currentStep={1} totalSteps={3} />
// Renderiza: "Paso 1 de 3"
```

---

### ImagePreview

**Ubicación:** `/src/app/components/ImagePreview.tsx`

**Estados:**
- `empty` - Sin imagen (muestra placeholder)
- `loading` - Cargando (muestra spinner)
- `loaded` - Imagen cargada (muestra imagen)
- `error` - Error al cargar (muestra mensaje)

**Props:**
```typescript
{
  src: string | null;
  state: 'empty' | 'loading' | 'loaded' | 'error';
  className?: string;
}
```

**Uso:**
```tsx
<ImagePreview
  src={imageUrl}
  state={imageUrl ? 'loaded' : 'empty'}
  className="max-w-md mx-auto"
/>

<ImagePreview
  src={null}
  state="loading"
/>
```

---

### SectionCard

**Ubicación:** `/src/app/components/SectionCard.tsx`

**Descripción:** Contenedor para agrupar opciones relacionadas

**Props:**
```typescript
{
  title?: string;
  children: ReactNode;
  className?: string;
}
```

**Uso:**
```tsx
<SectionCard title="Privacidad">
  <Toggle label="Limpiar metadatos" ... />
</SectionCard>

<SectionCard title="Watermarks">
  <Toggle label="Watermark visible" ... />
  <Toggle label="Watermark invisible" ... />
</SectionCard>
```

---

## 🎨 Tokens de Diseño

### Colores

```css
/* Principales */
--background: #ffffff;
--foreground: #1a1a1a;
--primary: #1a1a1a;
--primary-foreground: #ffffff;

/* Secundarios */
--secondary: #f5f5f5;
--secondary-foreground: #1a1a1a;
--muted: #f5f5f5;
--muted-foreground: #737373;

/* Bordes */
--border: #e5e5e5;

/* Estados */
--destructive: #dc2626;
--accent: #f5f5f5;
```

### Espaciado

```
Base: 4px
Pequeño: 8px
Mediano: 16px
Grande: 24px
Extra grande: 32px
```

### Tipografía

```
H1 (Home): ~30px
H2 (Pantallas): ~24px
Body: 16px
Small: 14px
Extra small: 12px
```

### Border Radius

```
Botones: 12px
Cards: 12px
Inputs: 8px
```

---

## 📱 Pantallas (Screens)

### Home

**Ubicación:** `/src/app/screens/Home.tsx`

**Descripción:** Pantalla de inicio

**Props:**
```typescript
{
  onStartImageFlow: () => void;
}
```

**Elementos:**
- Título: "Imagen@rte"
- Subtítulo: "Tratamiento y protección de imágenes, sin nube."
- Botón primario: "Tratar imagen"
- Botón secundario (disabled): "Tratar video (próximamente)"

---

### WizardStep1

**Ubicación:** `/src/app/screens/WizardStep1.tsx`

**Descripción:** Selección de imagen

**Props:**
```typescript
{
  selectedImage: string | null;
  onImageSelect: (file: File) => void;
  onBack: () => void;
  onNext: () => void;
}
```

**Elementos:**
- Stepper: "Paso 1 de 3"
- ImagePreview (empty o loaded)
- Botón: "Elegir imagen"
- Botón: "Siguiente" (disabled hasta elegir imagen)

---

### WizardStep2

**Ubicación:** `/src/app/screens/WizardStep2.tsx`

**Descripción:** Configuración de acciones

**Props:**
```typescript
{
  actions: ActionsState;
  onActionsChange: (actions: ActionsState) => void;
  onBack: () => void;
  onNext: () => void;
}
```

**Elementos:**
- Stepper: "Paso 2 de 3"
- SectionCard con toggles:
  - Pixelar rostro + Slider (1-10)
  - Blur selectivo + Slider (1-10)
  - Quitar fondo (disabled)
  - Crop inteligente + Dropdown (aspect ratio)
- Botón: "Siguiente"

---

### WizardStep3

**Ubicación:** `/src/app/screens/WizardStep3.tsx`

**Descripción:** Vista previa y resumen

**Props:**
```typescript
{
  selectedImage: string | null;
  actions: ActionsState;
  onBack: () => void;
  onNext: () => void;
}
```

**Elementos:**
- Stepper: "Paso 3 de 3"
- ImagePreview
- Nota: "Vista previa. El procesamiento final ocurre al exportar."
- SectionCard "Operaciones activas" (lista o mensaje "No activaste ninguna acción")
- Botón: "Continuar a exportación"

---

### Export

**Ubicación:** `/src/app/screens/Export.tsx`

**Descripción:** Configuración de exportación

**Props:**
```typescript
{
  selectedImage: string | null;
  actions: ActionsState;
  onBack: () => void;
  onReset: () => void;
}
```

**Elementos:**
- ImagePreview (con estado loading → loaded)
- SectionCard "Formato y calidad":
  - Dropdown formato
  - Slider calidad (si JPG/WebP)
  - Nota explicativa
- SectionCard "Privacidad":
  - Toggle "Limpiar metadatos (EXIF)" (default: ON)
- SectionCard "Watermarks":
  - Toggle "Watermark visible" + Input (si ON)
  - Toggle "Watermark invisible" + Toggle "Exportar comprobante"
- Botón: "Exportar" (con estado loading)

**Estado Success:**
- Ícono de checkmark
- Título: "Exportación lista"
- Mensaje: "La imagen se guardó correctamente."
- Botón: "Tratar otra imagen"

---

## 🔧 Interfaces TypeScript

### ActionsState

```typescript
interface ActionsState {
  pixelate: {
    enabled: boolean;
    intensity: number; // 1-10
  };
  blur: {
    enabled: boolean;
    intensity: number; // 1-10
  };
  removeBackground: {
    enabled: boolean;
  };
  crop: {
    enabled: boolean;
    aspectRatio: '1:1' | '4:3' | '16:9' | '9:16';
  };
}
```

---

## 🎯 Patrones de Uso

### Navegación con Estado

```tsx
const [currentScreen, setCurrentScreen] = useState<Screen>('home');
const [selectedImage, setSelectedImage] = useState<string | null>(null);
const [actions, setActions] = useState<ActionsState>(initialActions);

// Home
<Home onStartImageFlow={() => setCurrentScreen('step1')} />

// Step 1
<WizardStep1
  selectedImage={selectedImage}
  onImageSelect={handleImageSelect}
  onBack={() => setCurrentScreen('home')}
  onNext={() => setCurrentScreen('step2')}
/>
```

### Actualización de Acciones

```tsx
const updateAction = <K extends keyof ActionsState>(
  action: K,
  updates: Partial<ActionsState[K]>
) => {
  onActionsChange({
    ...actions,
    [action]: { ...actions[action], ...updates },
  });
};

// Uso
updateAction('pixelate', { enabled: true });
updateAction('pixelate', { intensity: 7 });
```

---

## 📐 Responsive Design

### Breakpoints

```
Mobile (base): 360px - 414px
Tablet: 768px+
Desktop: 1024px+
```

### Mobile-First

Todos los componentes están diseñados para mobile primero:
- Tamaño táctil mínimo: 44x44px
- Espaciado generoso entre elementos
- Texto legible (min 16px)
- Botones de ancho completo en pantallas <768px

---

## 🎨 Sistema de Variantes

### Button

```tsx
// Primario (CTA principal)
<Button variant="primary">Siguiente</Button>

// Secundario (acción opcional)
<Button variant="secondary">Cancelar</Button>
```

### Toggle

```tsx
// Simple
<Toggle label="Activar opción" ... />

// Con explicación
<Toggle 
  label="Activar opción"
  subtitle="Esto hace X cosa importante"
  ...
/>
```

---

## 🔄 Estados de Carga

### ImagePreview

```tsx
// Inicial
<ImagePreview src={null} state="empty" />

// Cargando
<ImagePreview src={null} state="loading" />

// Cargada
<ImagePreview src={imageUrl} state="loaded" />

// Error
<ImagePreview src={null} state="error" />
```

### Button

```tsx
// Normal
<Button onClick={handleClick}>Exportar</Button>

// Loading
<Button isLoading onClick={handleExport}>
  Exportando...
</Button>
```

---

## 🎯 Accesibilidad

### Labels Asociados

```tsx
<Toggle
  label="Pixelar rostro"
  id="toggle-pixelate"
  ...
/>
// Genera <label htmlFor="toggle-pixelate"> internamente
```

### Estados Disabled

```tsx
<Button disabled>
  No disponible
</Button>

<Toggle disabled label="Próximamente" ... />

<Slider disabled value={5} ... />
```

---

## 📝 Checklist de Componente

Al crear un nuevo componente, asegurar:

- [ ] Props tipadas con TypeScript
- [ ] Estados visuales claros (default/hover/pressed/disabled)
- [ ] Tamaño táctil >44px (mobile)
- [ ] Responsive (funciona en 360px+)
- [ ] Accesible (labels, ARIA)
- [ ] Consistente con tokens de diseño
- [ ] Documentado en este archivo

---

**Última actualización:** 2026-01-13  
**Versión:** 1.0
