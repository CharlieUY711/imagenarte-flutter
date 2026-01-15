# Guía de Diseño UX/UI para Figma — Imagen@rte (MVP Imagen)

**Versión:** 1.0  
**Fecha:** 2024  
**Propósito:** Brief operativo para diseño en Figma y handoff a desarrollo Flutter

---

## 1. PRINCIPIOS VISUALES

### 1.1 Minimalismo Funcional
- **Prioridad:** Claridad sobre decoración
- **Estética:** Sobria, profesional, no infantil
- **Filosofía:** Cada elemento visual debe tener un propósito funcional claro
- **Evitar:** Gradientes innecesarios, sombras decorativas, animaciones llamativas

### 1.2 Confianza y Privacidad
- **Mensaje visual:** Transparencia, control, seguridad
- **Indicadores:** Mostrar claramente qué se está protegiendo y cómo
- **Evitar:** Lenguaje de marketing agresivo, promesas exageradas
- **Paleta sugerida:** Colores neutros, con acentos discretos para acciones importantes

### 1.3 Anti-Features Visuales
- ❌ **NO incluir:** Iconos de redes sociales, botones de compartir, badges de "popular"
- ❌ **NO incluir:** Gamificación (puntos, niveles, logros)
- ❌ **NO incluir:** Elementos que sugieran conexión a internet o cloud
- ❌ **NO incluir:** Formularios de registro o login
- ❌ **NO incluir:** Notificaciones push o banners promocionales

### 1.4 Jerarquía Visual
- **Acción principal:** Siempre visible, clara, sin ambigüedad
- **Acciones secundarias:** Menos prominentes pero accesibles
- **Información:** Contextual, no invasiva
- **Máximo 3 acciones visibles por pantalla** (regla estricta)

---

## 2. SISTEMA DE PANTALLAS

### 2.1 Pantalla Home

#### Objetivo Principal
Punto de entrada único. El usuario debe entender inmediatamente qué hace la app y cómo comenzar.

#### Decisiones del Usuario
- Decidir si quiere tratar una imagen
- (Opcional) Acceder a configuración de protección por sesión

#### Componentes Requeridos
1. **Título/Logo:** Nombre de la app (Imagen@rte) o logo simple
2. **Descripción breve:** Una línea que explique el propósito (ej: "Tratamiento y protección de imágenes")
3. **Botón primario:** "Tratar Imagen"
   - Debe ser el elemento más prominente
   - Icono: foto/galería
   - Estado: enabled (siempre activo)
4. **Botón secundario:** "Tratar Video (próximamente)"
   - Estado: disabled (visualmente deshabilitado)
   - Debe ser claro que no está disponible
5. **Acceso a Protección:** (Opcional, puede ser un icono discreto o texto pequeño)
   - Link/icono que lleve a configuración de protección por sesión

#### Qué NO Debe Aparecer
- ❌ Lista de imágenes recientes
- ❌ Tutorial o onboarding
- ❌ Notificaciones o badges
- ❌ Menú hamburguesa con múltiples opciones
- ❌ Footer con links a redes sociales

#### Estados a Diseñar
- Default (estado inicial)
- (Opcional) Loading si hay alguna inicialización

---

### 2.2 Wizard de Tratamiento — Paso 1: Selección de Imagen

#### Objetivo Principal
Permitir al usuario seleccionar una imagen desde galería o capturarla con la cámara.

#### Decisiones del Usuario
- Elegir fuente: Galería o Cámara
- Confirmar selección

#### Componentes Requeridos
1. **Indicador de paso:** "Paso 1 de 3" o similar
2. **Área de preview:** 
   - Si no hay imagen: Placeholder con icono/texto "Selecciona una imagen"
   - Si hay imagen: Preview de la imagen seleccionada
3. **Botón de selección:** "Seleccionar Imagen"
   - Al presionar: Mostrar diálogo con dos opciones (Galería / Cámara)
4. **Navegación:**
   - Botón "Atrás" (vuelve a Home)
   - Botón "Siguiente" (solo habilitado si hay imagen seleccionada)

#### Qué NO Debe Aparecer
- ❌ Editor de imagen en este paso
- ❌ Opciones de tratamiento
- ❌ Múltiples imágenes (solo una a la vez)

#### Estados a Diseñar
- Sin imagen seleccionada
- Con imagen seleccionada
- Diálogo de selección (Galería / Cámara)
- (Opcional) Loading durante selección

---

### 2.3 Wizard de Tratamiento — Paso 2: Acciones

#### Objetivo Principal
Permitir al usuario configurar qué operaciones aplicar a la imagen. Cada operación es independiente y opcional.

#### Decisiones del Usuario
- Activar/desactivar cada operación (toggle)
- Ajustar parámetros de operaciones activas (sliders, selectores)

#### Componentes Requeridos

**2.3.1 Pixelar Rostro**
- **Toggle:** ON/OFF
- **Cuando está ON:**
  - Slider de intensidad (1-10)
  - Etiqueta mostrando valor actual (ej: "Intensidad: 5")
  - (Opcional) Preview pequeño del efecto

**2.3.2 Blur Selectivo**
- **Toggle:** ON/OFF
- **Cuando está ON:**
  - Slider de intensidad (1-10)
  - Etiqueta mostrando valor actual
  - (Opcional) Preview pequeño del efecto

**2.3.3 Quitar Fondo**
- **Toggle:** ON/OFF
- **Estado:** Disabled (no implementado en MVP)
- **Indicador visual:** Debe mostrar claramente que no está disponible
- **Texto:** "(próximamente)" o similar

**2.3.4 Crop Inteligente**
- **Toggle:** ON/OFF
- **Cuando está ON:**
  - Selector de aspect ratio (dropdown o botones)
  - Opciones: 1:1 (Cuadrado), 16:9 (Widescreen), 4:3 (Clásico), 9:16 (Vertical)
  - (Opcional) Preview del crop

**Navegación:**
- Botón "Atrás" (vuelve a Paso 1)
- Botón "Siguiente" (siempre habilitado, incluso si no hay operaciones activas)

#### Qué NO Debe Aparecer
- ❌ Editor de imagen complejo
- ❌ Herramientas de dibujo o selección manual
- ❌ Múltiples capas o historial
- ❌ Filtros decorativos o efectos artísticos

#### Estados a Diseñar
- Cada toggle: OFF / ON
- Sliders: Todos los valores (1-10)
- Selector de crop: Cada opción seleccionada
- Operación deshabilitada (Quitar Fondo)

#### Notas de Interacción
- Los sliders solo aparecen cuando su toggle está ON
- Las operaciones son independientes (pueden activarse varias a la vez)
- No hay preview en tiempo real del procesamiento (eso ocurre en Export)

---

### 2.4 Wizard de Tratamiento — Paso 3: Preview

#### Objetivo Principal
Mostrar al usuario qué imagen va a procesar antes de exportar. **Importante:** El procesamiento real ocurre en Export, no aquí.

#### Decisiones del Usuario
- Confirmar que quiere proceder a exportar
- Volver atrás para ajustar operaciones

#### Componentes Requeridos
1. **Indicador de paso:** "Paso 3 de 3" o similar
2. **Preview de imagen:**
   - Muestra la imagen original seleccionada
   - **NO muestra el procesamiento real** (eso ocurre en Export)
   - Texto aclaratorio: "Vista previa (procesamiento real en export)"
3. **Resumen de operaciones activas:** (Opcional pero recomendado)
   - Lista simple de qué operaciones están activas
   - Ej: "• Pixelar rostro (intensidad: 7)\n• Blur selectivo (intensidad: 5)"
4. **Navegación:**
   - Botón "Atrás" (vuelve a Paso 2)
   - Botón "Continuar" o "Exportar" (va a pantalla Export)

#### Qué NO Debe Aparecer
- ❌ Preview procesado en tiempo real (no es posible en MVP)
- ❌ Editor adicional
- ❌ Opciones de tratamiento (ya se configuraron en Paso 2)

#### Estados a Diseñar
- Con imagen y operaciones configuradas
- (Opcional) Sin operaciones activas (mostrar mensaje informativo)

---

### 2.5 Pantalla Export

#### Objetivo Principal
Configurar opciones finales de exportación y ejecutar el procesamiento real de la imagen.

#### Decisiones del Usuario
- Elegir formato y calidad
- Configurar opciones de privacidad (metadatos)
- Configurar watermarks (opcional)
- Confirmar exportación

#### Componentes Requeridos

**2.5.1 Preview de Imagen Procesada**
- Muestra la imagen después del procesamiento real
- Estado inicial: Loading (mientras procesa)
- Estados: Loading / Imagen procesada / Error

**2.5.2 Sección: Formato y Calidad**
- **Selector de formato:** Dropdown con opciones:
  - JPG
  - PNG
  - WebP
- **Slider de calidad:** 50-100
  - Etiqueta mostrando valor actual (ej: "Calidad: 85")
  - (Nota: Solo aplica a JPG y WebP, PNG siempre es sin pérdida)

**2.5.3 Sección: Privacidad**
- **Toggle:** "Limpiar Metadatos (EXIF)"
  - Estado por defecto: ON
  - Subtítulo: "Recomendado: elimina información personal"
  - Debe ser claro qué información se elimina

**2.5.4 Sección: Watermarks**
- **Toggle:** "Watermark Visible"
  - Cuando está ON:
    - Campo de texto para ingresar texto del watermark
    - Placeholder: "Ej: @mi_usuario"
- **Toggle:** "Watermark Invisible (básico)"
  - Subtítulo: "Token HMAC embebido en imagen (LSB)"
  - Cuando está ON:
    - (Opcional) Toggle adicional: "Exportar Comprobante"
    - Subtítulo: "Guardar manifest.json para verificación"

**2.5.5 Botón de Exportación**
- **Texto:** "Exportar"
- **Estados:**
  - Enabled (cuando hay imagen procesada)
  - Disabled (durante procesamiento o exportación)
  - Loading (durante exportación: "Exportando...")
- **Comportamiento:** Al presionar, procesa y guarda la imagen, luego muestra confirmación

#### Qué NO Debe Aparecer
- ❌ Opciones de compartir en redes sociales
- ❌ Opciones de subir a cloud
- ❌ Historial de exportaciones
- ❌ Galería de imágenes procesadas

#### Estados a Diseñar
- Loading (procesando imagen)
- Con imagen procesada (listo para exportar)
- Exportando (durante guardado)
- Error (si falla el procesamiento o exportación)
- Éxito (confirmación después de exportar)

#### Notas de Interacción
- El procesamiento real ocurre automáticamente al entrar a esta pantalla
- El usuario puede ajustar opciones de exportación mientras ve el preview
- Después de exportar, se muestra confirmación y se vuelve a Home (o se cierra el wizard)

---

### 2.6 (Opcional) Pantalla de Ajustes de Protección por Sesión

#### Objetivo Principal
Permitir configurar opciones de protección que se aplicarán por defecto en futuras sesiones.

#### Decisiones del Usuario
- Activar/desactivar limpieza automática de metadatos por defecto
- Configurar watermarks por defecto
- (Futuro) Otras opciones de privacidad

#### Componentes Requeridos
- Toggles similares a los de Export, pero marcados como "por defecto"
- Botón "Guardar" o aplicar automáticamente
- Botón "Atrás" o "Cerrar"

#### Qué NO Debe Aparecer
- ❌ Configuración de cuenta o perfil
- ❌ Sincronización con cloud
- ❌ Historial de uso

---

## 3. COMPONENTES CLAVE (Definición Conceptual)

### 3.1 Botones

**Botón Primario:**
- Uso: Acción principal de la pantalla
- Estados: Default / Pressed / Disabled
- Características: Alto contraste, tamaño prominente, icono opcional
- Ejemplos: "Tratar Imagen", "Exportar"

**Botón Secundario:**
- Uso: Acciones secundarias o navegación
- Estados: Default / Pressed / Disabled
- Características: Menos prominente que primario, puede ser outlined
- Ejemplos: "Atrás", "Siguiente", "Cancelar"

**Botón Deshabilitado:**
- Uso: Funcionalidad no disponible
- Estado visual: Claramente deshabilitado (opacidad reducida, sin interacción)
- Ejemplo: "Tratar Video (próximamente)"

### 3.2 Toggles (Switches)

**Toggle Estándar:**
- Uso: Activar/desactivar operaciones o opciones
- Estados: OFF / ON
- Comportamiento: Cambio inmediato al tocar
- Cuando está ON: Puede mostrar controles adicionales (sliders, campos de texto)

**Toggle con Subtítulo:**
- Uso: Opciones que requieren explicación
- Incluye: Título + Subtítulo descriptivo
- Ejemplo: "Limpiar Metadatos (EXIF)" + "Recomendado: elimina información personal"

### 3.3 Sliders

**Slider de Intensidad:**
- Rango: 1-10 (discreto, con 9 divisiones)
- Muestra: Valor actual como número
- Comportamiento: Solo visible cuando su toggle asociado está ON
- Feedback: Actualización inmediata del valor mostrado

**Slider de Calidad:**
- Rango: 50-100 (discreto, con 10 divisiones)
- Muestra: Valor actual como número
- Aplicación: Solo para JPG y WebP

### 3.4 Selectores

**Dropdown de Aspect Ratio:**
- Uso: Seleccionar ratio de crop
- Opciones: 1:1, 16:9, 4:3, 9:16
- Etiquetas: Incluir nombre descriptivo (ej: "1:1 (Cuadrado)")
- Comportamiento: Solo visible cuando toggle de Crop está ON

**Dropdown de Formato:**
- Uso: Seleccionar formato de exportación
- Opciones: JPG, PNG, WebP
- Comportamiento: Cambio inmediato (puede afectar disponibilidad de slider de calidad)

### 3.5 Preview Antes/Después

**Preview de Imagen:**
- Uso: Mostrar imagen original o procesada
- Estados: 
  - Sin imagen (placeholder)
  - Con imagen (mostrar imagen)
  - Loading (indicador de carga)
  - Error (mensaje de error)
- Comportamiento: Ajustar tamaño manteniendo aspect ratio, permitir scroll si es necesario

**Nota importante:** En el Wizard Paso 3, el preview muestra la imagen original (no procesada). El procesamiento real ocurre en Export.

### 3.6 Indicadores de Estado

**Indicador de Procesamiento:**
- Uso: Mostrar que se está procesando la imagen
- Componente: Spinner/CircularProgressIndicator
- Texto opcional: "Procesando..." o similar

**Indicador de Protección Activa:**
- Uso: Mostrar qué opciones de protección están activas
- Formato: Lista simple o badges discretos
- Ejemplo: "✓ Metadatos limpiados" / "✓ Watermark visible activo"

**Indicador de Paso (Stepper):**
- Uso: Mostrar progreso en el wizard
- Formato: "Paso X de 3" o stepper visual
- Estados: Completado / Actual / Pendiente

### 3.7 Campos de Texto

**Campo de Watermark Visible:**
- Uso: Ingresar texto para watermark visible
- Placeholder: "Ej: @mi_usuario"
- Comportamiento: Solo visible cuando toggle de Watermark Visible está ON
- Validación: (Opcional) Mostrar advertencia si está vacío al exportar

---

## 4. COPY PRINCIPLES (Principios de Redacción)

### 4.1 Lenguaje Claro y Directo
- **Usar:** Verbos de acción claros ("Tratar", "Exportar", "Limpiar")
- **Evitar:** Jerga técnica innecesaria, términos ambiguos
- **Ejemplo bueno:** "Limpiar Metadatos (EXIF)"
- **Ejemplo malo:** "Sanitización de datos EXIF mediante algoritmo de eliminación"

### 4.2 Transparencia
- **Usar:** Etiquetas que expliquen qué hace cada opción
- **Incluir:** Subtítulos cuando sea necesario aclarar
- **Marcar claramente:** Qué es opcional, qué es recomendado, qué es básico
- **Ejemplos:**
  - "Recomendado: elimina información personal"
  - "(próximamente)" para features no disponibles
  - "básico" para funcionalidades limitadas

### 4.3 Sin Promesas Exageradas
- **Evitar:** "Protección total", "100% seguro", "Nunca se filtrará"
- **Usar:** Descripciones realistas de lo que hace la app
- **Ejemplo bueno:** "Elimina información EXIF que puede revelar ubicación"
- **Ejemplo malo:** "Protección total de tu privacidad"

### 4.4 Sin Tecnicismos Innecesarios
- **Usar términos técnicos solo cuando sea necesario:**
  - "EXIF" (necesario para explicar metadatos)
  - "HMAC" (opcional, puede simplificarse a "token de verificación")
  - "LSB" (puede omitirse en la UI, solo en tooltips si es necesario)
- **Simplificar:** "Watermark invisible" en lugar de "Esteganografía LSB con token HMAC"

### 4.5 Mensajes de Error y Confirmación
- **Errores:** Explicar qué salió mal de forma clara, sin jerga técnica
- **Confirmaciones:** Mensajes breves y específicos
- **Ejemplo de confirmación:** "Imagen exportada: imagenarte_export_1234567890.jpg"
- **Ejemplo de error:** "Error al procesar la imagen. Intenta con otra imagen."

---

## 5. UX CONSTRAINTS (Restricciones de Experiencia)

### 5.1 Regla de 3 Acciones Visibles
- **Aplicación:** Cada pantalla debe tener máximo 3 acciones principales visibles simultáneamente
- **Excepciones:** Listas de toggles (Paso 2) pueden tener más, pero agrupadas lógicamente
- **Justificación:** Reducir carga cognitiva, decisiones más rápidas

### 5.2 Una Decisión Crítica por Vista
- **Aplicación:** No combinar múltiples decisiones importantes en una sola pantalla
- **Ejemplo:** En Export, las decisiones están agrupadas por sección, pero cada sección es independiente
- **Justificación:** Evitar parálisis por análisis

### 5.3 Siempre Mostrar "Qué Va a Pasar"
- **Aplicación:** Antes de cualquier acción irreversible, mostrar claramente qué se va a hacer
- **Ejemplos:**
  - En Preview (Paso 3): Mostrar qué operaciones están activas
  - En Export: Mostrar preview procesada antes de exportar
  - En botón Exportar: El usuario ya vio el preview, sabe qué va a obtener

### 5.4 Feedback Inmediato
- **Aplicación:** Cada acción del usuario debe tener feedback visual inmediato
- **Ejemplos:**
  - Toggle cambia de estado al tocar
  - Slider muestra valor actualizado
  - Loading spinner durante procesamiento
  - Confirmación después de exportar

### 5.5 Navegación Clara
- **Aplicación:** Siempre debe ser claro cómo volver atrás o cancelar
- **Componentes:** Botón "Atrás" visible, o gesto de swipe (según plataforma)
- **Comportamiento:** Volver atrás no debe perder datos (las selecciones se mantienen)

### 5.6 Estados de Carga
- **Aplicación:** Siempre mostrar indicador durante operaciones que toman tiempo
- **Casos:**
  - Selección de imagen (puede ser rápido, pero mostrar si tarda)
  - Procesamiento en Export (siempre mostrar spinner)
  - Exportación final (mostrar "Exportando...")

---

## 6. HANDOFF A DESARROLLO

### 6.1 Nombres de Pantallas (Identificadores)

Usar estos nombres exactos para referencias en código:

- `home_screen`
- `wizard_screen` (con pasos: `wizard_step_1`, `wizard_step_2`, `wizard_step_3`)
- `export_screen`
- `protection_settings_screen` (opcional)

### 6.2 Estados de Componentes

Para cada componente interactivo, definir:

**Botones:**
- `default` (estado normal)
- `pressed` (estado al presionar)
- `disabled` (estado deshabilitado)
- `loading` (estado de carga, si aplica)

**Toggles:**
- `off` (desactivado)
- `on` (activado)

**Sliders:**
- `default` (estado normal)
- `dragging` (estado al arrastrar, opcional)

**Preview de Imagen:**
- `empty` (sin imagen)
- `loading` (cargando)
- `loaded` (imagen cargada)
- `error` (error al cargar)

**Dropdowns:**
- `closed` (cerrado)
- `open` (abierto)
- `selected` (con opción seleccionada)

### 6.3 Comportamiento Esperado de Controles

**Toggle:**
- Al cambiar a ON: Mostrar controles asociados (sliders, campos de texto)
- Al cambiar a OFF: Ocultar controles asociados
- Cambio inmediato, sin confirmación

**Slider:**
- Actualizar valor mostrado en tiempo real
- Rango: Definir min, max, divisions
- Valor: Mostrar como número entero

**Dropdown:**
- Al abrir: Mostrar lista de opciones
- Al seleccionar: Cerrar y actualizar valor mostrado
- Valor por defecto: Especificar para cada dropdown

**Botón de Navegación:**
- "Atrás": Volver a pantalla anterior (manteniendo estado)
- "Siguiente": Avanzar a siguiente paso (validar si es necesario)
- "Exportar": Ejecutar procesamiento y guardado

**Botón de Acción Principal:**
- Al presionar: Ejecutar acción principal
- Durante ejecución: Mostrar estado loading/disabled
- Después de ejecución: Mostrar confirmación o navegar

### 6.4 Notas de Interacción (Sin Animaciones Complejas)

**Transiciones:**
- Cambios de pantalla: Transición simple (fade o slide básico)
- Mostrar/ocultar controles: Aparecer/desaparecer sin animación compleja
- Cambios de estado: Feedback inmediato, sin delays

**Gestos:**
- Swipe para volver atrás: (Opcional, según plataforma)
- Scroll: Permitir scroll en pantallas con contenido largo (Export)
- Zoom en preview: (Opcional, solo si es necesario)

**Feedback Táctil:**
- Vibración ligera al presionar botones principales (opcional)
- Sin feedback táctil en toggles o sliders (puede ser molesto)

### 6.5 Especificaciones Técnicas para Figma

**Para cada componente, incluir en Figma:**
- Nombre del componente (usar nombres de sección 6.1 y 6.2)
- Estados (crear variantes en Figma)
- Dimensiones (ancho, alto, padding, margin)
- Tipografía (fuente, tamaño, peso, color)
- Colores (usar variables de color si es posible)
- Espaciado (usar sistema de espaciado consistente)

**Layout:**
- Definir breakpoints si aplica (aunque es mobile-first)
- Definir grid system (opcional, pero recomendado)
- Definir sistema de espaciado (ej: 4px, 8px, 16px, 24px, 32px)

**Assets:**
- Exportar iconos como SVG cuando sea posible
- Exportar imágenes de ejemplo para previews
- Definir estados de loading (spinners, placeholders)

### 6.6 Checklist de Handoff

Antes de entregar el diseño a desarrollo, verificar:

- [ ] Todas las pantallas están diseñadas
- [ ] Todos los estados de componentes están definidos
- [ ] Nombres de componentes son consistentes con sección 6.1
- [ ] Comportamientos esperados están documentados
- [ ] Copy está definido para todos los textos
- [ ] Colores y tipografía están especificados
- [ ] Espaciado y dimensiones están claros
- [ ] No hay features que no estén en el PRD
- [ ] No hay referencias a backend, login, o cloud
- [ ] Las restricciones de UX (sección 5) están respetadas

---

## 7. RESTRICCIONES ABSOLUTAS (Recordatorio)

### 7.1 NO Inventar Features Nuevas
- Solo diseñar lo que está especificado en el PRD
- Si hay dudas sobre una feature, consultar antes de diseñar

### 7.2 NO Mencionar Tecnologías Específicas
- ❌ NO mencionar "Elixir" en ningún lugar
- ❌ NO mencionar "backend" o "servidor"
- ❌ NO mencionar "Firebase" o servicios cloud

### 7.3 NO Asumir Analytics o Tracking
- ❌ NO diseñar pantallas de "estadísticas de uso"
- ❌ NO incluir elementos que sugieran recolección de datos
- ❌ NO diseñar flujos de "mejora de experiencia basada en datos"

### 7.4 NO Proponer Flows Complejos
- ❌ NO diseñar flujos con más de 3 pasos consecutivos
- ❌ NO diseñar workflows con múltiples ramificaciones
- ❌ Mantener el flujo: Home → Wizard (3 pasos) → Export

### 7.5 NO Proponer Timeline de Video
- ❌ NO diseñar UI para edición de video en timeline
- ❌ La funcionalidad de video está planificada para el futuro, pero NO es parte del MVP

---

## 8. ESTRUCTURA DEL DOCUMENTO EN FIGMA

### 8.1 Organización Recomendada

**Páginas:**
1. `00_Principios` (colores, tipografía, espaciado)
2. `01_Componentes` (botones, toggles, sliders, etc.)
3. `02_Pantallas` (Home, Wizard, Export)
4. `03_Estados` (variantes de componentes)
5. `04_Flujos` (user flows visuales, opcional)

**Frames por Pantalla:**
- Crear un frame para cada pantalla
- Dentro de cada frame, crear variantes para cada estado
- Nombrar frames siguiendo convención: `pantalla_estado` (ej: `home_default`, `wizard_step2_operaciones_activas`)

### 8.2 Componentes Reutilizables

Crear componentes en Figma para:
- Botón primario (con variantes: default, pressed, disabled, loading)
- Botón secundario (con variantes)
- Toggle (con variantes: off, on)
- Slider (con variantes: default, dragging)
- Preview de imagen (con variantes: empty, loading, loaded, error)
- Dropdown (con variantes: closed, open)
- Indicador de paso (stepper)

### 8.3 Auto-Layout y Constraints

- Usar Auto-Layout en Figma para facilitar responsive design
- Definir constraints claros para elementos que deben adaptarse
- Probar en diferentes tamaños de pantalla (mínimo: iPhone SE y iPhone Pro Max equivalentes)

---

## 9. PREGUNTAS FRECUENTES PARA EL DISEÑADOR

### 9.1 ¿Qué hacer si una decisión de diseño no está clara?
- Consultar este documento primero
- Si no está especificado, seguir el principio de "minimalismo funcional"
- En caso de duda, elegir la opción más simple

### 9.2 ¿Puedo agregar animaciones?
- Animaciones simples están permitidas (fade, slide básico)
- NO agregar animaciones complejas o decorativas
- Priorizar claridad sobre estética

### 9.3 ¿Qué paleta de colores usar?
- No está especificada en este brief (dejar a criterio del diseñador)
- Debe ser sobria, profesional, no infantil
- Debe tener buen contraste para accesibilidad
- Sugerencia: Colores neutros con acentos discretos

### 9.4 ¿Debo diseñar modo oscuro?
- No es parte del MVP
- Puede diseñarse como futuro, pero no es prioridad

### 9.5 ¿Cómo manejar errores?
- Diseñar estados de error para cada componente que pueda fallar
- Mensajes de error deben ser claros y accionables
- NO usar jerga técnica en mensajes de error

---

## 10. CONCLUSIÓN

Este documento sirve como:
1. **Guía de diseño** para crear las pantallas en Figma
2. **Contrato de diseño** entre diseño y desarrollo
3. **Referencia** durante la implementación en Flutter

**Principio rector:** Si algo no está especificado, seguir el principio de minimalismo funcional y simplicidad extrema.

**Última actualización:** Revisar este documento antes de comenzar el diseño y actualizarlo si surgen nuevas decisiones durante el proceso.

---

**Fin del Brief de Diseño UX/UI**
