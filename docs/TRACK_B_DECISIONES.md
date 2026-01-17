# Track B - Decisiones de Arquitectura

## Principio Fundamental

**Web (localhost:5173) = SPEC canónica. Flutter = implementación.**

El Track A (web) es la fuente de verdad para UX/UI. El Track B (Flutter) implementa la misma experiencia, sin inventar nuevas interacciones.

## Reglas de Separación

- **Track A (web)** y **Track B (flutter)** NO se mezclan.
- Track B va en carpeta nueva (`C:\Imagen@rte\track-b-flutter\imagenarte`) y repo nuevo.
- No reutilizar código legacy.
- No copiar React a Dart directamente (reenventar en Flutter, pero siguiendo la SPEC).

## Alcance Prohibido en B0

### NO se hace en B0:
- ❌ Plugins nativos
- ❌ State management extra (Provider, Riverpod, Bloc, etc.)
- ❌ Machine Learning / AI
- ❌ Filesystem / persistencia local
- ❌ Navegación compleja
- ❌ Editor de imágenes / canvas
- ❌ Gestos complejos

### Qué SÍ se hace en B0:
- ✅ Arquitectura base (carpetas: app, presentation, application, domain, infrastructure)
- ✅ Theme tokens (colores, spacing, radius)
- ✅ Home placeholder (pantalla neutra con botón sin funcionalidad)
- ✅ Documentación de decisiones

## Regla iOS-Safe

Siempre considerar compatibilidad iOS desde el inicio:
- No usar APIs que no estén disponibles en iOS
- Probar en iOS cuando sea posible
- Documentar cualquier limitación conocida

## Cambios Incrementales

- Cambios verificables en cada commit
- Cero refactors grandes
- Cada fase debe compilar y pasar `flutter analyze`

## Estructura de Carpetas

```
lib/
 ├─ app/
 │   ├─ app.dart
 │   ├─ routes.dart
 │   └─ theme/
 │       ├─ app_colors.dart
 │       ├─ app_spacing.dart
 │       ├─ app_radius.dart
 │       └─ app_theme.dart
 ├─ presentation/
 │   ├─ screens/
 │   │   └─ home_screen.dart
 │   └─ widgets/
 ├─ application/
 ├─ domain/
 ├─ infrastructure/
 └─ main.dart
```

## Próximos Pasos (B1)

- UI parity skeleton (implementar componentes básicos que coincidan con la web)
- Navegación básica
- Componentes reutilizables
