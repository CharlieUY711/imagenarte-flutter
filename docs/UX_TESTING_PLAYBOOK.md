# UX Testing Playbook — Imagen@rte

## Objetivos de Investigación

Este playbook guía sesiones de UX testing con creators, modelos y artistas para validar:

1. **Confianza**: ¿Se sienten seguros usando la app? ¿Entienden que sus imágenes no salen del dispositivo?
2. **Claridad**: ¿Es obvio qué hace cada operación? ¿El flujo es intuitivo?
3. **Tiempo**: ¿Cuánto tarda completar tareas comunes?
4. **Tasa de éxito**: ¿Pueden completar las tareas sin ayuda? ¿Dónde se atascan?

---

## Perfil de Testers

### Personas objetivo
- **Creators**: YouTubers, TikTokers, influencers que necesitan proteger rostros o fondos
- **Modelos**: Profesionales que quieren controlar su identidad visual antes de compartir
- **Artistas**: Fotógrafos, diseñadores que necesitan preparar imágenes para publicación

### Criterios de selección
- Usuarios que ya editan imágenes (aunque sea básico)
- Dispuestos a probar una app en desarrollo (20-30 min)
- Conectados a la comunidad de creators/artistas

---

## Setup de Sesión

### Dispositivo
- **Preferido**: Android/iOS real (no emulador)
- **Modo avión**: Activado para enfatizar offline-first
- **Iluminación**: Buena para observar expresiones faciales
- **Grabación**: Solo con consentimiento explícito (opcional, manual)

### Preparación
1. Instalar build de testing en el dispositivo
2. Activar "Modo Testing" en Config/Debug (si está disponible)
3. Tener imágenes de prueba listas (rostros, fondos variados)
4. Cronómetro para medir tiempos
5. Notas para observaciones cualitativas

### Consentimiento (texto breve)
> "Estamos probando la usabilidad de Imagen@rte. Tu participación es voluntaria. No grabamos pantalla automáticamente. Los datos que recopilemos son solo métricas locales (tiempos, errores) y tu feedback. No se capturan imágenes ni datos personales. ¿Aceptas participar?"

---

## Guión Moderado

### Introducción (2-3 min)
1. Presentar la app: "Imagen@rte es una app offline-first para proteger y tratar imágenes antes de publicarlas."
2. Explicar el objetivo: "Queremos saber si es fácil de usar y si te da confianza."
3. Pedir que piensen en voz alta: "Mientras usas la app, comparte lo que piensas, lo que te confunde o lo que te gusta."

### Preguntas de contexto (opcional, 2 min)
- "¿Has usado apps para editar imágenes antes? ¿Cuáles?"
- "¿Qué te preocupa más al compartir imágenes online?"

### Tareas principales (15-20 min)
Ver sección "Tareas" más abajo.

### Preguntas de cierre (5 min)
1. **NPS cualitativo**: "En una escala del 1 al 10, ¿qué tan probable es que recomiendes esta app a otro creator/modelo? ¿Por qué?"
2. **Confianza**: "¿Te sientes seguro de que tus imágenes no salen del dispositivo? ¿Qué te da o quita confianza?"
3. **Qué faltó**: "¿Qué funcionalidad esperabas encontrar y no está?"
4. **Claridad**: "¿Algo te resultó confuso? ¿Qué cambiarías?"

---

## Tareas

### Tarea 1: Importar imagen (2-3 min)
**Instrucción**: "Quiero que importes una imagen desde tu galería."

**Observar**:
- ¿Encuentra el botón de importar fácilmente?
- ¿Sabe qué hacer después de seleccionar?
- ¿Tiempo hasta ver la imagen cargada?

**Criterios de éxito**:
- ✅ Importa en < 30 segundos
- ✅ No necesita ayuda
- ✅ Muestra confianza en el proceso

**Señales de fricción**:
- ❌ Busca el botón más de 10 segundos
- ❌ Pregunta "¿dónde está...?"
- ❌ Selecciona imagen incorrecta

---

### Tarea 2: Activar pixelado de rostro (3-4 min)
**Instrucción**: "Ahora quiero que actives el pixelado automático de rostros en esta imagen."

**Observar**:
- ¿Entiende qué es "pixelado de rostro"?
- ¿Encuentra el toggle/control?
- ¿Ve el resultado inmediatamente?
- ¿Puede ajustar intensidad si existe?

**Criterios de éxito**:
- ✅ Activa en < 1 minuto
- ✅ Comprende el resultado visual
- ✅ Puede desactivar/reactivar

**Señales de fricción**:
- ❌ No encuentra el control
- ❌ No entiende qué hace
- ❌ Espera más tiempo del necesario

---

### Tarea 3: Aplicar blur selectivo a una zona (4-5 min)
**Instrucción**: "Quiero que apliques un blur a una zona específica de la imagen, por ejemplo, un texto o un objeto."

**Observar**:
- ¿Entiende "blur selectivo"?
- ¿Puede seleccionar la zona?
- ¿El control es intuitivo (arrastrar, tocar)?
- ¿Puede ajustar intensidad?

**Criterios de éxito**:
- ✅ Selecciona zona en < 2 min
- ✅ Aplica blur visible
- ✅ Puede ajustar o quitar

**Señales de fricción**:
- ❌ No sabe cómo seleccionar
- ❌ Confusión con otros controles
- ❌ Resultado no es el esperado

---

### Tarea 4: Quitar fondo (3-4 min)
**Instrucción**: "Ahora quiero que quites el fondo de la imagen, dejando solo el sujeto principal."

**Observar**:
- ¿Encuentra la opción "quitar fondo"?
- ¿Es claro qué hace?
- ¿El resultado es satisfactorio?
- ¿Puede revertir si no le gusta?

**Criterios de éxito**:
- ✅ Activa en < 1 min
- ✅ Resultado es aceptable (aunque no perfecto)
- ✅ Puede desactivar

**Señales de fricción**:
- ❌ No encuentra la opción
- ❌ Resultado muy malo (expectativa vs realidad)
- ❌ No sabe cómo revertir

---

### Tarea 5: Exportar con EXIF wipe ON (2-3 min)
**Instrucción**: "Quiero que exportes la imagen con la limpieza de metadatos activada."

**Observar**:
- ¿Ve la opción de "limpiar EXIF" o similar?
- ¿Entiende qué significa?
- ¿Confía en que funciona?
- ¿El proceso de exportación es claro?

**Criterios de éxito**:
- ✅ Encuentra la opción
- ✅ Exporta exitosamente
- ✅ Sabe dónde quedó guardada

**Señales de fricción**:
- ❌ No encuentra dónde exportar
- ❌ No entiende "EXIF" o "metadatos"
- ❌ No sabe si se exportó correctamente

---

### Tarea 6: Exportar con watermark visible (2-3 min)
**Instrucción**: "Ahora exporta otra versión, pero esta vez con un watermark visible."

**Observar**:
- ¿Encuentra la opción de watermark?
- ¿Puede personalizar texto/posición?
- ¿Ve el preview antes de exportar?

**Criterios de éxito**:
- ✅ Activa watermark
- ✅ Exporta con watermark visible
- ✅ Puede verificar el resultado

**Señales de fricción**:
- ❌ No encuentra la opción
- ❌ No sabe qué es un watermark
- ❌ No puede personalizar

---

### Tarea 7 (Opcional): Exportar comprobante (2-3 min)
**Instrucción**: "Si existe la opción, exporta un comprobante o certificado de que la imagen fue tratada."

**Observar**:
- ¿Existe esta funcionalidad?
- ¿Es útil?
- ¿Aumenta la confianza?

**Criterios de éxito**:
- ✅ Encuentra la opción (si existe)
- ✅ Genera comprobante
- ✅ Lo considera útil

---

## Criterios de Éxito Global

### Tasa de completitud
- **Objetivo**: > 80% de tareas completadas sin ayuda
- **Aceptable**: > 60% completadas con ayuda mínima

### Tiempo promedio
- **Objetivo**: < 15 min para todas las tareas
- **Aceptable**: < 20 min

### Confianza percibida
- **Objetivo**: > 7/10 en escala de confianza
- **Señal de alerta**: < 5/10

### Claridad
- **Objetivo**: < 2 momentos de confusión por sesión
- **Señal de alerta**: > 5 momentos de confusión

---

## Señales de Fricción Comunes

### Navegación
- Buscar botones/opciones > 10 segundos
- Preguntar "¿dónde está...?" repetidamente
- Clics/taps sin resultado esperado

### Comprensión
- "No entiendo qué hace esto"
- "¿Esto es seguro?"
- "¿Dónde quedó mi imagen?"

### Técnica
- Crashes o errores
- Procesamiento muy lento (> 10 segundos por operación)
- Resultados inesperados

### Confianza
- Dudas sobre privacidad
- Miedo a perder la imagen original
- Desconfianza en el proceso offline

---

## Notas Post-Sesión

### Métricas a registrar
- Tiempo por tarea (manual o desde exportación si está disponible)
- Tareas completadas vs fallidas
- Número de intentos por tarea
- Rating de claridad (1-5) por tarea
- NPS cualitativo
- Crashes o errores técnicos

### Observaciones cualitativas
- Frases exactas del tester (citas)
- Expresiones faciales (confusión, satisfacción)
- Patrones de uso (qué toca primero, qué ignora)
- Sugerencias espontáneas

### Síntesis
- Top 3 problemas más frecuentes
- Top 3 cosas que funcionan bien
- Recomendaciones prioritarias

---

## Consentimiento Recomendado (Texto Breve)

> **Participación en UX Testing — Imagen@rte**
>
> Estamos probando la usabilidad de Imagen@rte con usuarios reales. Tu participación es completamente voluntaria.
>
> **Qué recopilamos:**
> - Métricas locales (tiempos, errores, completitud de tareas)
> - Tu feedback verbal y observaciones
>
> **Qué NO recopilamos:**
> - Imágenes que uses en la app
> - Datos personales
> - Información de tu dispositivo
> - Grabaciones automáticas de pantalla
>
> **Cómo usamos los datos:**
> - Solo para mejorar la app
> - Los datos se exportan manualmente (si activas el modo testing)
> - Puedes pedir que se eliminen en cualquier momento
>
> ¿Aceptas participar? Puedes detenerte en cualquier momento.

---

## Próximos Pasos

1. Realizar 5-8 sesiones con diferentes perfiles
2. Consolidar métricas y observaciones
3. Priorizar mejoras basadas en fricciones más frecuentes
4. Iterar y volver a probar

---

**Versión**: 1.0  
**Última actualización**: 2024
