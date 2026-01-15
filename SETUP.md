# Guía de Configuración: Imagen@rte

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

Navegar al directorio de la app móvil:

```bash
cd apps/mobile
flutter pub get
```

Esto instalará automáticamente las dependencias de los packages locales (core, processing, watermark).

### 3. Configurar Android

- Asegurarse de tener Android SDK instalado
- Configurar `local.properties` en `apps/mobile/android/` con la ruta del SDK:
  ```
  sdk.dir=C:\\Users\\TU_USUARIO\\AppData\\Local\\Android\\Sdk
  ```

### 4. Configurar iOS (solo macOS)

```bash
cd apps/mobile/ios
pod install
```

## Ejecutar la Aplicación

### Android

```bash
cd apps/mobile
flutter run
```

O desde Android Studio:
1. Abrir `apps/mobile` como proyecto
2. Seleccionar dispositivo/emulador
3. Ejecutar

### iOS

```bash
cd apps/mobile
flutter run
```

O desde Xcode:
1. Abrir `apps/mobile/ios/Runner.xcworkspace`
2. Seleccionar dispositivo/simulador
3. Ejecutar

## Estructura de Packages

El proyecto usa packages locales:

- `packages/core`: Dominio y casos de uso
- `packages/processing`: Pipeline de procesamiento
- `packages/watermark`: Sistema de watermarks

Estos se configuran automáticamente en `apps/mobile/pubspec.yaml`.

## Solución de Problemas

### Error: "Package not found"

Ejecutar:
```bash
cd apps/mobile
flutter pub get
```

### Error: "Android SDK not found"

Crear `apps/mobile/android/local.properties` con:
```
sdk.dir=RUTA_A_TU_ANDROID_SDK
```

### Error de compilación en iOS

```bash
cd apps/mobile/ios
pod deintegrate
pod install
```

## Desarrollo

### Agregar Nueva Operación

1. Crear archivo en `packages/processing/lib/ops/nueva_op/`
2. Implementar clase con método `apply(String imagePath, OperationParams params)`
3. Agregar `OperationType` en `packages/core/lib/domain/operation.dart`
4. Registrar en `packages/processing/lib/pipeline/image_pipeline.dart`
5. Agregar UI en `apps/mobile/lib/ui/screens/wizard/wizard_screen.dart`

### Agregar Nuevo Package

1. Crear directorio `packages/nuevo_package/`
2. Crear `pubspec.yaml` con nombre del package
3. Crear estructura `lib/`
4. Agregar dependencia en `apps/mobile/pubspec.yaml`:
   ```yaml
   nuevo_package:
     path: ../../packages/nuevo_package
   ```

## Testing

```bash
cd apps/mobile
flutter test
```

## Build para Producción

### Android APK

```bash
cd apps/mobile
flutter build apk --release
```

### Android App Bundle

```bash
cd apps/mobile
flutter build appbundle --release
```

### iOS

```bash
cd apps/mobile
flutter build ios --release
```

## Notas

- La app funciona completamente offline
- No requiere configuración de backend
- Todos los procesamientos son locales
- Los archivos temporales se limpian automáticamente
