# Pasos para reconstruir Flutter Web

## 1. Cerrar el servidor de desarrollo
Si tienes un servidor corriendo (localhost), ciérralo primero.

## 2. Limpiar el build
```bash
cd apps/mobile
flutter clean
```

## 3. Obtener dependencias
```bash
flutter pub get
```

## 4. Reconstruir para web
```bash
flutter build web
```

## Nota importante
El export condicional en `platform_image.dart` debería funcionar automáticamente:
- En web: usa `platform_image_web.dart` (sin `dart:io`)
- En mobile/desktop: usa `platform_image_io.dart` (con `dart:io`)

Si el error persiste después de limpiar, verifica que:
1. No haya imports directos de `dart:io` en archivos que se usan en web
2. Todos los usos de `Image.file` hayan sido reemplazados por `PlatformImage`
