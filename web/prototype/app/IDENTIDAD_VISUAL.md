# Identidad Visual - Imagen@rte

**Motivo:** Lógica radial incompleta con eje diagonal a 14:45  
**Centro conceptual:** Símbolo "@" (identidad digital)

---

## 🎯 Concepto del Motivo

El motivo de identidad se basa en:
- **Arcos parciales** (nunca círculos completos)
- **Eje diagonal dominante** (~45° desde vertical, equivalente a 14:45 en reloj)
- **Sutil y no intrusivo** (opacidad 3-8%)
- **Progresión incompleta** (máximo 240° de 360°)

**Significado:**
- **Incompleto:** Refleja la naturaleza continua del tratamiento de imágenes
- **Diagonal:** Movimiento, dinamismo sin agresividad
- **"@":** Centro de identidad digital, sin representarlo literalmente

---

## ✅ Implementación en el Prototipo

### 1. Componente RadialMotif

**Ubicación:** `/src/app/components/RadialMotif.tsx`

**Tres variantes:**

#### a) Background (`variant="background"`)
- **Uso:** Fondos sutiles en Home
- **Opacidad:** 3%
- **Forma:** Dos arcos parciales diagonales (superior derecha + inferior izquierda)
- **Efecto:** Enmarca el contenido sin distraer

```tsx
<RadialMotif variant="background" className="text-foreground" />
```

#### b) Loading (`variant="loading"`)
- **Uso:** Estados de carga (ImagePreview, Button)
- **Forma:** Arco parcial de ~120° que rota
- **Efecto:** Indica procesamiento sin spinner circular completo

```tsx
<RadialMotif variant="loading" className="text-foreground" />
```

#### c) Progress (`variant="progress"`)
- **Uso:** Stepper del Wizard (Paso X de 3)
- **Forma:** Arco que progresa de 0° a 240° (nunca completo)
- **Inicio:** Diagonal superior izquierda (-135°)
- **Efecto:** Visualiza progreso del flujo

```tsx
<RadialMotif variant="progress" progress={33} />  // Paso 1 de 3
<RadialMotif variant="progress" progress={66} />  // Paso 2 de 3
<RadialMotif variant="progress" progress={100} /> // Paso 3 de 3 (80% del arco)
```

---

## 📍 Ubicaciones de Uso

### ✅ Implementado

| Pantalla/Componente | Variante | Propósito |
|---------------------|----------|-----------|
| **Home** | `background` | Fondo sutil con arcos diagonales |
| **Stepper** | `progress` | Indicador visual de progreso del wizard |
| **ImagePreview** (loading) | `loading` | Indicador de carga de imagen |
| **Button** (isLoading) | `loading` | Indicador de procesamiento |

### ❌ NO Implementado (por diseño)

- ~~Estados de error~~ → No usar motivo en contextos negativos
- ~~Toggles/Sliders~~ → No aplicar a UI funcional
- ~~Branding repetitivo~~ → No convertir en logo omnipresente
- ~~Decoraciones constantes~~ → No agregar por "llenar espacio"

---

## 🎨 Parámetros Técnicos

### Opacidad
```css
background: opacity 0.03 (3%)
loading: opacity 1 (100% del color primario)
progress: opacity 1 (100% del color primario)
```

### Ángulos
```
Inicio del arco de progreso: -135° (diagonal superior izquierda)
Máximo completado: 240° (2/3 del círculo)
Rotación del loading: continua (CSS animation)
```

### Colores
```
Siempre usa currentColor
En light mode: texto negro (#1a1a1a)
Hereda del contexto donde se usa
```

### Tamaños
```
loading: 32x32px (puede escalarse)
progress: 32x32px
background: 100% del contenedor (responsive)
```

---

## 📐 Geometría del Motivo

### Arco Parcial de Progreso

```
     ╱
    ●    ← Inicio (-135°)
   ╱ ╲
  ╱   ╲
 ╱     ╲
╱       ╲   ← Progreso 33% (80°)
         ╲
          ●

Progreso 100% alcanza ~105° (240° de arco)
```

### Background Diagonal

```
Pantalla (390x844)

    ╱
   ╱  (arco superior)
  ╱
 ╱
╱

        ╲
         ╲  (arco inferior, reflejo diagonal)
          ╲
           ╲
```

---

## 🚫 Reglas Estrictas

### NO HACER

1. **NO dibujar relojes literales**
   - ❌ No agregar números (12, 3, 6, 9)
   - ❌ No dibujar agujas
   - ❌ No usar marcas horarias

2. **NO usar círculos completos**
   - ❌ Spinners circulares completos
   - ❌ Loaders con 360° de rotación
   - ❌ Anillos cerrados

3. **NO convertir en logo**
   - ❌ No poner en header/footer constantemente
   - ❌ No usar como ícono de la app
   - ❌ No hacer branding explícito

4. **NO aplicar a UI funcional**
   - ❌ Botones (excepto loading state)
   - ❌ Toggles/Switches
   - ❌ Sliders
   - ❌ Dropdowns

5. **NO usar en contextos negativos**
   - ❌ Estados de error
   - ❌ Alertas
   - ❌ Validaciones fallidas

### SÍ HACER

1. **Usar para feedback sutil**
   - ✅ Indicar progreso del wizard
   - ✅ Mostrar carga/procesamiento
   - ✅ Enmarcar contenido importante

2. **Mantener opacidad baja en backgrounds**
   - ✅ 3-8% en fondos estáticos
   - ✅ 100% en indicadores activos (loading/progress)

3. **Respetar el eje diagonal**
   - ✅ Inicio a -135° (diagonal superior izquierda)
   - ✅ Movimiento en sentido horario
   - ✅ Nunca vertical (0°) ni horizontal (90°)

4. **Aplicar criterio de distracción**
   - ✅ Si distrae → eliminar
   - ✅ Si no aporta → eliminar
   - ✅ Si confunde → eliminar

---

## 🧪 Testing del Motivo

### Validar que:

- [ ] El background en Home NO distrae del contenido
- [ ] El stepper se entiende como indicador de progreso
- [ ] El loading NO se confunde con un error
- [ ] El motivo NO se interpreta como un reloj
- [ ] El motivo NO se siente como "decoración innecesaria"

### Preguntas para testers:

1. ¿Notaste el diseño del indicador de progreso?
2. ¿Te pareció útil o decorativo?
3. ¿Lo asociaste con algún concepto (reloj, carga, otro)?
4. ¿El background en Home te distrajo?
5. ¿Preferirías que no estuviera?

**Criterio de decisión:**
- Si >30% de testers lo encuentran distractivo → eliminar background
- Si >50% no entienden el progreso visual → volver a texto simple
- Si >20% lo asocian con "reloj" → rediseñar ángulos

---

## 🎯 Filosofía del Motivo

### Principios

**Minimalismo:**
> "El motivo debe ser descubrible, no evidente."

**Funcionalidad:**
> "Si no cumple una función, no debe existir."

**Sutileza:**
> "Debe aportar coherencia, no identidad ostentosa."

**Honestidad:**
> "No es un logo. Es un lenguaje visual interno."

### Inspiración

- **Relojes analógicos:** Progreso continuo, tiempo como flujo
- **Símbolo "@":** Identidad digital, conexión
- **Arcos incompletos:** Proceso continuo, siempre en mejora
- **Diagonal 14:45:** Momento específico, precisión sin rigidez

---

## 📊 Casos de Uso Futuros (Flutter)

Si se implementa en la app final:

### Pueden agregarse:

1. **Splash screen**
   - Arco que completa 240° al cargar
   - Transición diagonal de opacidad

2. **Procesamiento de imagen**
   - Arco de progreso durante detección de rostros
   - Indicador de procesamiento ML

3. **Exportación**
   - Arco de progreso durante compresión/exportación
   - Feedback visual de completado

4. **Onboarding (si se agrega)**
   - Stepper con arcos para pasos del tutorial
   - Transiciones diagonales entre pantallas

### NO deben agregarse:

- ❌ Animaciones de celebración con confetti radial
- ❌ Transiciones circulares completas entre pantallas
- ❌ Elementos decorativos en pantallas de error
- ❌ Branding en cada pantalla

---

## 🔧 Modificación del Motivo

Si necesitas ajustar:

### Cambiar opacidad del background
```tsx
// En RadialMotif.tsx
opacity="0.03"  // Actual (3%)
opacity="0.05"  // Más visible (5%)
opacity="0.01"  // Menos visible (1%)
```

### Cambiar ángulo de inicio
```tsx
// En RadialMotif.tsx (variant="progress")
const startAngle = -135;  // Actual (diagonal superior izq)
const startAngle = -120;  // Más vertical
const startAngle = -150;  // Más horizontal
```

### Cambiar máximo de progreso
```tsx
const angle = (progress / 100) * 240;  // Actual (máx 240°)
const angle = (progress / 100) * 270;  // Más completo (270°)
const angle = (progress / 100) * 180;  // Menos completo (180°)
```

### Deshabilitar completamente
```tsx
// Comentar importaciones de RadialMotif en:
// - Home.tsx
// - Stepper.tsx
// - ImagePreview.tsx
// - Button.tsx
```

---

## 📝 Decisiones de Diseño

### ¿Por qué arcos parciales y no círculos completos?

**Razones:**
1. Círculos completos sugieren "completado" o "ciclo cerrado"
2. Imagen@rte es un proceso continuo, no un loop
3. Arcos parciales generan dinamismo sin saturación
4. Evita confusión con spinners genéricos

### ¿Por qué diagonal a 14:45 específicamente?

**Razones:**
1. 45° es el ángulo más dinámico sin ser agresivo
2. Asociación sutil con "hora específica" (precisión)
3. Diferencia de otros ángulos comunes (0°, 90°, 180°)
4. Equilibrio entre horizontal y vertical

### ¿Por qué opacidad tan baja (3%)?

**Razones:**
1. El prototipo prioriza funcionalidad sobre estética
2. Backgrounds muy visibles distraen del contenido
3. Debe ser descubrible, no obvio
4. Permite testear si es necesario o prescindible

---

## ✅ Checklist de Implementación

Al agregar el motivo a nuevas pantallas:

- [ ] ¿Cumple una función (indicar progreso/carga)?
- [ ] ¿Es sutil y no distrae?
- [ ] ¿Respeta el eje diagonal?
- [ ] ¿NO es un círculo completo?
- [ ] ¿NO se parece a un reloj literal?
- [ ] ¿NO se usa como logo/branding?
- [ ] ¿Mejora la experiencia o es decorativo?

**Si respondiste "solo decorativo" → NO agregarlo.**

---

## 🎨 Exportar el Motivo para Figma

Si quieres usar el motivo en diseños de Figma:

### SVG del arco de progreso (100%)

```svg
<svg width="32" height="32" viewBox="0 0 32 32">
  <path
    d="M 6.343 6.343 A 14 14 0 0 1 25.657 25.657"
    stroke="#1a1a1a"
    stroke-width="2.5"
    stroke-linecap="round"
    fill="none"
  />
</svg>
```

### SVG del background diagonal

```svg
<svg width="390" height="844" viewBox="0 0 390 844">
  <path
    d="M 390 0 A 600 600 0 0 0 0 600"
    stroke="#1a1a1a"
    stroke-width="1"
    fill="none"
    opacity="0.03"
  />
  <path
    d="M 0 844 A 600 600 0 0 0 390 244"
    stroke="#1a1a1a"
    stroke-width="1"
    fill="none"
    opacity="0.03"
  />
</svg>
```

---

**Última actualización:** 2026-01-13  
**Estado:** Implementado en prototipo v1.0  
**Criterio de permanencia:** Sujeto a feedback de testing UX
