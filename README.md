# Imagen@rte

Aplicación **offline-first** para tratamiento, protección y preparación de imágenes, orientada a creators, modelos y artistas que necesitan controlar su identidad visual antes de publicar contenido.

## Características Principales

- 🔒 **Privacidad D0 Estricta**: Ninguna imagen se persiste fuera del dispositivo
- 📱 **Offline-First**: Todo el procesamiento es local, sin dependencias de red
- 🎨 **Tratamiento de Imágenes**: Pixelado de rostros, blur selectivo, quitar fondo, crop inteligente
- 🛡️ **Protección**: Limpieza automática de metadatos EXIF, watermarks visibles e invisibles
- 🚀 **Simplicidad**: UX clara con toggles y sliders, no es un editor complejo

## Estructura del Proyecto

```
imagenarte/
  apps/
    mobile/              # Aplicación Flutter
  packages/
    core/                # Lógica de negocio y dominio
    processing/          # Pipeline de procesamiento
    watermark/           # Sistema de watermarks
  docs/                  # Documentación completa
```

## Documentación

- [PRD.md](docs/PRD.md) - Product Requirements Document
- [ARCHITECTURE.md](docs/ARCHITECTURE.md) - Arquitectura del sistema
- [PRIVACY_MODEL.md](docs/PRIVACY_MODEL.md) - Modelo de privacidad
- [THREAT_MODEL.md](docs/THREAT_MODEL.md) - Modelo de amenazas
- [ROADMAP.md](docs/ROADMAP.md) - Roadmap del proyecto

## Requisitos

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android Studio / Xcode (para desarrollo móvil)

## Instalación

1. Clonar el repositorio
2. Navegar a `apps/mobile`
3. Ejecutar `flutter pub get`
4. Ejecutar `flutter run`

## Principios Fundamentales

1. **D0 Estricto**: Ninguna imagen original se persiste fuera del dispositivo
2. **Offline-First Real**: Todo procesamiento local, sin backend
3. **Simplicidad Extrema**: UX clara, acciones obvias
4. **Privacidad Defensiva**: Limpieza de metadatos por defecto

## Estado Actual

MVP funcional con:
- ✅ Navegación básica (Home → Wizard → Export)
- ✅ Operaciones básicas (pixelado, blur, crop)
- ✅ Sanitización EXIF
- ✅ Watermark visible
- ✅ Limpieza de temporales

Ver [ROADMAP.md](docs/ROADMAP.md) para features futuras.

## Licencia

[Definir licencia según necesidades del proyecto]
