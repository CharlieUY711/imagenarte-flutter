# PRD: Imagen@rte

## ¿Qué es Imagen@rte?

Imagen@rte es una aplicación **offline-first** para **tratamiento, protección y preparación** de imágenes (y posteriormente videos), orientada a creators, modelos y artistas que necesitan controlar su identidad visual antes de publicar contenido.

## ¿Qué problemas resuelve?

1. **Privacidad de identidad visual**: Permite pixelar rostros, aplicar blur selectivo y quitar fondos antes de compartir imágenes.
2. **Control de metadatos**: Elimina automáticamente información EXIF que puede revelar ubicación, fecha, dispositivo, etc.
3. **Protección de autoría**: Ofrece watermarks visibles e invisibles para proteger el contenido.
4. **Independencia tecnológica**: Funciona completamente offline, sin depender de servicios cloud ni backends.
5. **Simplicidad**: UX clara con toggles y sliders, no es un editor complejo como Photoshop.

## ¿Qué NO es?

- ❌ **NO es Photoshop**: No es un editor de imágenes generalista
- ❌ **NO es una app cloud**: No sube imágenes a servidores
- ❌ **NO requiere login**: Funciona sin autenticación
- ❌ **NO es parte de Elixir Platform**: Es completamente independiente
- ❌ **NO recolecta datos**: No hay tracking ni analytics invasivos
- ❌ **NO es un editor de video** (aún): La funcionalidad de video está planificada para el futuro

## Features MVP (Exactas)

### Pantalla Home
- Botón principal: "Tratar imagen"
- Botón secundario (disabled): "Tratar video (próximamente)"
- Acceso a "Protección" (configuración por sesión)

### Wizard de Tratamiento
**Paso 1: Selección de imagen**
- Selección desde galería
- Captura desde cámara

**Paso 2: Acciones**
- **Pixelar rostro**: Toggle ON/OFF + slider de intensidad (1-10)
- **Blur selectivo**: Toggle ON/OFF + slider de intensidad (1-10)
- **Quitar fondo**: Toggle ON/OFF (stub inicial, no implementado)
- **Crop inteligente**: Toggle ON/OFF + selector de aspect ratio (1:1, 16:9, 4:3, 9:16)

**Paso 3: Preview**
- Vista previa antes/después (procesamiento real en export)

### Pantalla Export
- **Formato y calidad**: Selector de formato (JPG, PNG, WebP) + slider de calidad (50-100)
- **Limpieza de metadatos**: Toggle ON por defecto (elimina EXIF)
- **Watermark visible**: Toggle opcional + campo de texto
- **Watermark invisible**: Toggle opcional (hash local básico)
- **Botón Exportar**: Procesa y exporta la imagen
- **Limpieza automática**: Borra archivos temporales al finalizar

## Principios Fundamentales

1. **D0 Estricto**: Ninguna imagen original se persiste fuera del dispositivo
2. **Offline-First Real**: Todo procesamiento local, sin backend
3. **Simplicidad Extrema**: UX clara, acciones obvias
4. **Privacidad Defensiva**: Limpieza de metadatos por defecto, watermarks opcionales

## Tecnología

- **Framework**: Flutter (mobile-first)
- **Procesamiento**: OpenCV (bindings nativos), MediaPipe/MLKit on-device (futuro)
- **NO usar**: Firebase, Auth, Analytics, Cloud Storage, APIs remotas
