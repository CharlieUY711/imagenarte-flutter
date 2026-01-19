# Guía de Testing - Imagen@rte Prototipo v1.0

## Objetivo del Testing

Validar el flujo UX/UI y el microcopy del prototipo de Imagen@rte para detectar:
- Puntos de fricción en la navegación
- Claridad del copy y las instrucciones
- Comprensión de las opciones disponibles
- Percepción de simplicidad vs complejidad

## Escenarios de Testing

### 📱 Escenario 1: Flujo Mínimo (Usuario Básico)
**Persona:** Usuario que solo quiere exportar una imagen sin modificaciones.

**Pasos:**
1. Ingresar a Home
2. Click en "Tratar imagen"
3. Seleccionar una imagen
4. Click en "Siguiente" (sin activar ninguna acción en Step 2)
5. Click en "Siguiente" en Step 3
6. Click en "Exportar" directamente en pantalla Export

**Validar:**
- [ ] ¿Es claro que puede avanzar sin activar acciones?
- [ ] ¿El mensaje "No activaste ninguna acción (opcional)" se entiende?
- [ ] ¿El flujo se siente rápido?

---

### 🎨 Escenario 2: Flujo Completo (Usuario Avanzado)
**Persona:** Usuario que quiere usar todas las funciones disponibles.

**Pasos:**
1. Ingresar a Home
2. Seleccionar imagen en Step 1
3. En Step 2:
   - Activar "Pixelar rostro" → ajustar intensidad a 8
   - Activar "Blur selectivo" → ajustar intensidad a 6
   - Intentar activar "Quitar fondo" (debe estar deshabilitado)
   - Activar "Crop inteligente" → seleccionar "16:9 (Horizontal)"
4. Revisar resumen en Step 3
5. En Export:
   - Cambiar formato a PNG
   - Activar "Watermark visible" → escribir "@usuario_test"
   - Activar "Watermark invisible" → activar "Exportar comprobante"
6. Exportar

**Validar:**
- [ ] ¿Los sliders de intensidad se sienten intuitivos?
- [ ] ¿Es claro por qué "Quitar fondo" está deshabilitado?
- [ ] ¿El resumen en Step 3 refleja correctamente las acciones?
- [ ] ¿Se entiende la diferencia entre watermark visible e invisible?
- [ ] ¿Se descargaron ambos archivos (imagen + manifest.json)?

---

### 🔒 Escenario 3: Privacidad y Metadatos
**Persona:** Usuario preocupado por la privacidad.

**Pasos:**
1. Completar flujo hasta pantalla Export
2. Observar que "Limpiar metadatos (EXIF)" está activado por defecto
3. Leer el subtítulo explicativo
4. Exportar

**Validar:**
- [ ] ¿Es claro qué son los metadatos EXIF?
- [ ] ¿El copy transmite confianza sin prometer seguridad absoluta?
- [ ] ¿El lenguaje es honesto ("Recomendado") sin ser alarmista?

---

### 📂 Escenario 4: Formatos y Calidad
**Persona:** Usuario técnico que entiende de compresión.

**Pasos:**
1. Completar flujo hasta Export
2. Cambiar entre formatos JPG/PNG/WebP
3. Observar cuándo aparece/desaparece el slider de calidad
4. Leer las notas explicativas

**Validar:**
- [ ] ¿Es claro que PNG no tiene slider de calidad?
- [ ] ¿Las notas ("PNG exporta sin pérdida") son útiles?
- [ ] ¿El rango 50-100 de calidad tiene sentido?

---

### ↩️ Escenario 5: Navegación hacia Atrás
**Persona:** Usuario indeciso que quiere cambiar opciones.

**Pasos:**
1. Completar flujo hasta Step 3
2. Volver a Step 2 (botón Atrás)
3. Modificar opciones
4. Avanzar nuevamente a Step 3
5. Volver a Step 2 nuevamente
6. Volver a Step 1
7. Cambiar imagen
8. Completar flujo completo

**Validar:**
- [ ] ¿El botón Atrás está siempre visible?
- [ ] ¿Los cambios se mantienen al navegar hacia atrás/adelante?
- [ ] ¿Se puede cambiar la imagen sin reiniciar todo?

---

### ❌ Escenario 6: Casos de Error
**Persona:** Usuario que comete errores.

**Pasos:**
1. En Step 1, intentar avanzar sin seleccionar imagen
2. En Export, intentar activar watermark visible sin escribir texto
3. Probar con una imagen muy grande (>5MB)

**Validar:**
- [ ] ¿El botón "Siguiente" está deshabilitado correctamente?
- [ ] ¿Es claro por qué no puede avanzar?
- [ ] ¿Hay feedback visual claro?

---

## Checklist de Copy (Microcopy)

Verificar que el texto sea exactamente:

### Home
- [ ] Título: "Imagen@rte"
- [ ] Subtítulo: "Tratamiento y protección de imágenes, sin nube."
- [ ] Botón primario: "Tratar imagen"
- [ ] Botón secundario: "Tratar video (próximamente)"

### Wizard Step 1
- [ ] Stepper: "Paso 1 de 3"
- [ ] Título: "Seleccioná una imagen"
- [ ] Botón: "Elegir imagen"

### Wizard Step 2
- [ ] Stepper: "Paso 2 de 3"
- [ ] Título: "Acciones"
- [ ] Toggles:
  - [ ] "Pixelar rostro" → Intensidad 1-10
  - [ ] "Blur selectivo" → Intensidad 1-10
  - [ ] "Quitar fondo" → (próximamente)
  - [ ] "Crop inteligente" → Aspecto ratio

### Wizard Step 3
- [ ] Stepper: "Paso 3 de 3"
- [ ] Título: "Vista previa"
- [ ] Nota: "Vista previa. El procesamiento final ocurre al exportar."
- [ ] Si no hay acciones: "No activaste ninguna acción (opcional)."

### Export
- [ ] Título: "Exportar"
- [ ] Sección "Formato y calidad"
- [ ] Sección "Privacidad"
  - [ ] Toggle: "Limpiar metadatos (EXIF)"
  - [ ] Subtítulo: "Recomendado: elimina información que puede revelar detalles del dispositivo."
- [ ] Sección "Watermarks"
  - [ ] Toggle: "Watermark visible"
  - [ ] Placeholder: "Ej: @mi_usuario"
  - [ ] Toggle: "Watermark invisible (básico)"
  - [ ] Subtítulo: "Agrega un token de verificación a la imagen."
  - [ ] Toggle: "Exportar comprobante"
  - [ ] Subtítulo: "Guarda un manifest.json para verificación local."

### Success
- [ ] Título: "Exportación lista"
- [ ] Mensaje: "La imagen se guardó correctamente."
- [ ] Botón: "Tratar otra imagen"

---

## Checklist de UI/UX

### Visual
- [ ] Colores neutros y profesionales (sin colores vibrantes)
- [ ] Espaciado consistente (4/8/16/24/32px)
- [ ] Bordes redondeados sutiles (12-16px)
- [ ] Tipografía clara y legible

### Interacción
- [ ] Botones responden al tap/click (feedback visual)
- [ ] Toggles se ven claramente ON/OFF
- [ ] Sliders son fáciles de arrastrar
- [ ] Dropdowns se abren correctamente

### Estados
- [ ] Botones deshabilitados tienen opacidad reducida
- [ ] Loading spinners aparecen durante exportación
- [ ] Mensajes de éxito/error son claros

### Mobile-First
- [ ] Todo es legible en pantalla de 360px de ancho
- [ ] Botones tienen tamaño táctil adecuado (min 44x44px)
- [ ] No hay scroll horizontal
- [ ] El flujo funciona solo con pulgar (one-handed)

---

## Preguntas para Testers

Al finalizar cada escenario, preguntar:

1. **Claridad:** ¿En algún momento no supiste qué hacer o qué significaba algo?
2. **Confianza:** ¿Te sentís seguro de que tus imágenes no se suben a ningún servidor?
3. **Simplicidad:** ¿Hay algo que sobra o que hace el flujo más complejo?
4. **Copy:** ¿Algún texto te pareció confuso, técnico o poco claro?
5. **Expectativas:** ¿Esperabas alguna función que no encontraste?
6. **Velocidad:** ¿El flujo se sintió rápido o lento?

---

## Métricas de Éxito

- ✅ **90%+** de testers completan el flujo mínimo sin ayuda
- ✅ **80%+** entienden que pueden avanzar sin activar acciones
- ✅ **100%** entienden que no hay login/cloud
- ✅ **0** testers buscan botones de compartir/redes sociales
- ✅ **0** testers preguntan por onboarding/tutorial

---

## Notas para Facilitar el Testing

- Usar imágenes de prueba (no personales sensibles)
- Probar en diferentes dispositivos (Android/iOS, diferentes tamaños)
- Probar en diferentes navegadores (Chrome, Safari, Firefox)
- Tomar notas de verbalizaciones espontáneas ("¿dónde está...?", "no entiendo...", etc.)
- No intervenir a menos que el tester esté bloqueado >30 segundos

---

**Fecha de última actualización:** 2026-01-13  
**Versión del prototipo:** 1.0
