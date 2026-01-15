# Modelo de Amenazas: Imagen@rte

## Alcance

Este documento identifica los riesgos de privacidad y técnicos asociados con Imagen@rte y las mitigaciones implementadas o planificadas.

## Riesgos de Privacidad

### 1. Fuga de Metadatos EXIF

**Descripción**: Las imágenes pueden contener metadatos EXIF que revelan:
- Ubicación GPS
- Fecha y hora de captura
- Modelo de dispositivo
- Configuración de cámara
- Información del software que editó la imagen

**Probabilidad**: Alta (si no se sanitiza)
**Impacto**: Alto (puede revelar ubicación, hábitos, dispositivo)

**Mitigación**:
- ✅ Sanitización EXIF por defecto (`sanitizeMetadata = true`)
- ✅ Re-codificación de imagen sin metadatos
- ✅ Usuario puede verificar antes de exportar

**Estado**: ✅ Implementado

---

### 2. Archivos Temporales Persistentes

**Descripción**: Archivos temporales pueden quedar en el dispositivo después de procesar imágenes, exponiendo imágenes originales o procesadas.

**Probabilidad**: Media
**Impacto**: Medio (depende de acceso físico al dispositivo)

**Mitigación**:
- ✅ Limpieza automática al exportar (`TempCleanup`)
- ✅ Archivos en directorio temporal (se limpian por el sistema)
- ⚠️ Mejora futura: Limpieza al cerrar app

**Estado**: ✅ Implementado (básico)

---

### 2.1. Frames Temporales de Video (Nuevo)

**Descripción**: Durante el procesamiento de video, se extraen frames temporales que pueden contener información sensible (rostros, contenido original).

**Probabilidad**: Media
**Impacto**: Alto (frames pueden contener PII)

**Mitigación**:
- ✅ Frames en directorio temporal del sistema
- ✅ Plan de procesamiento (JSON) no contiene PII, solo metadata
- ✅ Limpieza de frames al cerrar sesión (V0)
- ⚠️ V1: Limpieza inmediata después de procesar cada frame
- ⚠️ V1: Encriptación opcional de frames temporales

**Estado**: ✅ Mitigado en V0 (estructura), ⚠️ Mejoras en V1

---

### 3. Acceso No Autorizado a Imágenes

**Descripción**: Otras apps o usuarios con acceso físico pueden acceder a imágenes almacenadas en la app.

**Probabilidad**: Baja (sandbox del sistema)
**Impacto**: Alto (si ocurre)

**Mitigación**:
- ✅ Sandbox del sistema operativo
- ✅ Permisos explícitos del usuario
- ✅ Archivos en directorio privado de la app
- ⚠️ Mejora futura: Encriptación de temporales (opcional)

**Estado**: ✅ Mitigado por el sistema

---

### 4. Procesamiento en Servidor (No Aplicable)

**Descripción**: Si se enviaran imágenes a servidores para procesamiento, se expondrían datos.

**Probabilidad**: N/A (arquitectura offline-first)
**Impacto**: N/A

**Mitigación**:
- ✅ Arquitectura offline-first
- ✅ Sin dependencias de red
- ✅ Procesamiento 100% local

**Estado**: ✅ No aplicable

---

### 5. Tracking y Analytics

**Descripción**: Recolección de datos de uso, identificadores, etc.

**Probabilidad**: N/A (no implementado)
**Impacto**: Medio

**Mitigación**:
- ✅ No hay analytics
- ✅ No hay tracking
- ✅ No hay telemetría
- ✅ Código auditable

**Estado**: ✅ No implementado (por diseño)

---

## Riesgos Técnicos

### 1. Pérdida de Datos por Fallo en Procesamiento

**Descripción**: Si el procesamiento falla, el usuario puede perder su trabajo o la imagen original.

**Probabilidad**: Media
**Impacto**: Medio

**Mitigación**:
- ✅ Imagen original nunca se modifica (solo se copia)
- ✅ Archivos temporales intermedios permiten recuperación
- ⚠️ Mejora futura: Guardado automático de sesión

**Estado**: ✅ Mitigado (no se modifica original)

---

### 2. Rendimiento en Dispositivos de Baja Gama

**Descripción**: Procesamiento de imágenes puede ser lento en dispositivos antiguos o de baja gama.

**Probabilidad**: Alta
**Impacto**: Medio (mala experiencia de usuario)

**Mitigación**:
- ⚠️ Optimización de operaciones (futuro)
- ⚠️ Preview de baja resolución (futuro)
- ⚠️ Procesamiento en background (futuro)
- ✅ Feedback visual durante procesamiento

**Estado**: ⚠️ Mejora futura

---

### 3. Consumo de Memoria

**Descripción**: Procesar imágenes grandes puede consumir mucha memoria RAM.

**Probabilidad**: Media
**Impacto**: Medio (puede causar crashes)

**Mitigación**:
- ✅ Procesamiento por chunks (futuro)
- ✅ Reducción de resolución para preview
- ⚠️ Límites de tamaño de imagen (futuro)

**Estado**: ⚠️ Mejora futura

---

### 3.1. Consumo de Memoria en Video (Nuevo)

**Descripción**: Procesar videos puede consumir mucha memoria RAM, especialmente al cargar múltiples frames simultáneamente.

**Probabilidad**: Alta (videos largos)
**Impacto**: Alto (puede causar crashes o degradación de rendimiento)

**Mitigación**:
- ✅ V0: Procesamiento frame a frame (no carga todos los frames)
- ✅ Plan de procesamiento permite procesamiento incremental
- ⚠️ V1: Límites de duración de video
- ⚠️ V1: Procesamiento en chunks de frames
- ⚠️ V1: Reducción de resolución para videos grandes

**Estado**: ✅ Mitigado en V0 (diseño), ⚠️ Optimizaciones en V1

---

### 4. Compatibilidad de Formatos

**Descripción**: Algunos formatos de imagen pueden no ser soportados o procesarse incorrectamente.

**Probabilidad**: Baja
**Impacto**: Bajo (solo afecta a formatos raros)

**Mitigación**:
- ✅ Soporte para formatos comunes (JPG, PNG, WebP)
- ✅ Validación de formato antes de procesar
- ⚠️ Mensajes de error claros

**Estado**: ✅ Básico implementado

---

### 5. Fallos en Operaciones de ML (Futuro)

**Descripción**: Cuando se integren MediaPipe/MLKit, pueden fallar o dar resultados incorrectos.

**Probabilidad**: Media
**Impacto**: Medio (operación no funciona como esperado)

**Mitigación**:
- ⚠️ Validación de resultados
- ⚠️ Fallback a operación manual
- ⚠️ Mensajes de error claros
- ⚠️ Testing exhaustivo

**Estado**: ⚠️ Planificado para futuro

---

## Riesgos de Seguridad

### 1. Inyección de Código a través de Imágenes

**Descripción**: Imágenes maliciosas podrían explotar vulnerabilidades en decodificadores.

**Probabilidad**: Baja
**Impacto**: Alto (si ocurre)

**Mitigación**:
- ✅ Uso de librerías confiables (`image` package)
- ✅ Validación de formato antes de procesar
- ✅ Sandbox del sistema operativo

**Estado**: ✅ Mitigado por librerías

---

### 2. Acceso a Archivos del Sistema

**Descripción**: La app podría acceder a archivos fuera de su sandbox.

**Probabilidad**: Muy Baja
**Impacto**: Alto

**Mitigación**:
- ✅ Permisos explícitos del sistema
- ✅ Uso de `path_provider` (API segura)
- ✅ Sin acceso directo a sistema de archivos

**Estado**: ✅ Mitigado por Flutter/OS

---

## Matriz de Riesgos

| Riesgo | Probabilidad | Impacto | Prioridad | Estado |
|--------|--------------|---------|-----------|--------|
| Fuga de metadatos EXIF | Alta | Alto | 🔴 Crítica | ✅ Mitigado |
| Archivos temporales persistentes | Media | Medio | 🟡 Media | ✅ Básico |
| Acceso no autorizado | Baja | Alto | 🟡 Media | ✅ Mitigado |
| Pérdida de datos | Media | Medio | 🟡 Media | ✅ Mitigado |
| Rendimiento bajo | Alta | Medio | 🟡 Media | ⚠️ Futuro |
| Consumo de memoria | Media | Medio | 🟡 Media | ⚠️ Futuro |
| Inyección de código | Baja | Alto | 🟢 Baja | ✅ Mitigado |
| Ataques al watermark invisible | Media | Medio | 🟡 Media | ✅ Básico (límites documentados) |

## Plan de Mitigación Continuo

### Corto Plazo
1. ✅ Sanitización EXIF por defecto
2. ✅ Limpieza de temporales
3. ⚠️ Mejorar manejo de errores

### Mediano Plazo
1. ⚠️ Optimización de rendimiento
2. ⚠️ Procesamiento en background
3. ⚠️ Validación de resultados ML

### Largo Plazo
1. ⚠️ Encriptación opcional de temporales
2. ⚠️ Guardado automático de sesión
3. ⚠️ Auditoría de seguridad externa

---

### 6. Ataques al Watermark Invisible

**Descripción**: El watermark invisible básico (LSB) puede ser vulnerable a:
- Recodificación de imagen (JPEG re-compresión)
- Rescale/redimensionamiento
- Aplicación de filtros
- Screenshot (captura de pantalla)
- Re-encode a otro formato

**Probabilidad**: Media (depende del atacante)
**Impacto**: Medio (pérdida de capacidad de verificación)

**Mitigaciones**:
- ✅ Dispersión pseudoaleatoria de píxeles (reduce visibilidad)
- ✅ Token hash en manifest (permite verificación incluso si se pierde parte del watermark)
- ✅ Documentación clara de límites (básico/no forense)
- ⚠️ Mejora futura: DCT/frecuencia para mayor robustez

**Estado**: ✅ Implementado (básico, con límites documentados)

---

## Conclusión

Los riesgos principales de privacidad están mitigados en el MVP. Los riesgos técnicos de rendimiento y memoria se abordarán en iteraciones futuras. La arquitectura offline-first elimina muchos riesgos relacionados con transmisión de datos. El watermark invisible está implementado como básico/no forense, con límites claramente documentados.
