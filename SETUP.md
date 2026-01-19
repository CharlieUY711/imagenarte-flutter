# Guía de Configuración: Imagen@rte

## Root Canónico

**Workspace raíz:** `C:\Users\cvara\Imagen@rte`  
**App Flutter:** `apps\imagenarte`

### Comandos Oficiales

Todos los comandos Flutter deben ejecutarse desde `apps\imagenarte`:

```bash
cd apps\imagenarte
flutter pub get
flutter analyze
flutter test
flutter run
```

## Requisitos Previos

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android Studio / Xcode (para desarrollo móvil)
- Git (opcional)

## Instalación

### 1. Verificar Flutter

```bash
flutter doctor
```

### 2. Instalar Dependencias

Navegar al directorio de la app Flutter:

```bash
cd apps\imagenarte
flutter pub get
```

### 3. Configurar Android

- Asegurarse de tener Android SDK instalado
- Configurar `local.properties` en `apps\imagenarte\android\` con la ruta del SDK:
  ```
  sdk.dir=C:\\Users\\TU_USUARIO\\AppData\\Local\\Android\\Sdk
  ```

### 4. Configurar iOS (solo macOS)

```bash
cd apps\imagenarte\ios
pod install
```

## Ejecutar la Aplicación

### Android

```bash
cd apps\imagenarte
flutter run
```

O desde Android Studio:
1. Abrir `apps\imagenarte` como proyecto
2. Seleccionar dispositivo/emulador
3. Ejecutar

### iOS

```bash
cd apps\imagenarte
flutter run
```

O desde Xcode:
1. Abrir `apps\imagenarte\ios\Runner.xcworkspace`
2. Seleccionar dispositivo/simulador
3. Ejecutar

## Estructura del Workspace

```
C:\Users\cvara\Imagen@rte\
  apps\
    imagenarte\          # App Flutter principal
  docs\                  # Documentación común
    AUDIT\               # Documentación de auditoría (canónica)
      imagenarte\        # Auditoría específica de imagenarte
  packages\              # Packages locales (si existen)
  design-tools\          # Herramientas de diseño (si existen)
  figma_extracted\       # Assets extraídos de Figma (si existen)
```

### Regla Canónica: Documentación de Auditoría

**Toda la documentación de auditoría vive en:** `docs\AUDIT\<app-name>\`

- ✅ **Canónico:** `docs\AUDIT\imagenarte\`
- ❌ **Legacy (no usar):** `apps\imagenarte\docs\AUDIT_*`

Las apps NO contienen documentación de auditoría. Esta regla es estructural y no afecta código, tests ni build.

Nota: La app Flutter actual (`apps\imagenarte`) no tiene dependencias de packages locales en `pubspec.yaml`.

## Solución de Problemas

### Error: "Package not found"

Ejecutar:
```bash
cd apps\imagenarte
flutter pub get
```

### Error: "Android SDK not found"

Crear `apps\imagenarte\android\local.properties` con:
```
sdk.dir=RUTA_A_TU_ANDROID_SDK
```

### Error de compilación en iOS

```bash
cd apps\imagenarte\ios
pod deintegrate
pod install
```

## Desarrollo

Trabajar desde `apps\imagenarte`:

```bash
cd apps\imagenarte
```

## Testing

```bash
cd apps\imagenarte
flutter test
```

## Build para Producción

### Android APK

```bash
cd apps\imagenarte
flutter build apk --release
```

### Android App Bundle

```bash
cd apps\imagenarte
flutter build appbundle --release
```

### iOS

```bash
cd apps\imagenarte
flutter build ios --release
```

## Notas

- La app funciona completamente offline
- No requiere configuración de backend
- Todos los procesamientos son locales
- Los archivos temporales se limpian automáticamente
