# Sistema de Gating Estricto para Pantallas Debug

## Objetivo

Garantizar que **NINGUNA** pantalla o funcionalidad debug sea accesible en builds release. Cumple con D0 estricto: cero contaminación de código debug en release.

## Componentes

### `DebugGate` (`lib/utils/debug_gate.dart`)

Utilidad central que proporciona:

- **`isDebugModeEnabled()`**: Detecta si el build está en modo debug usando `kDebugMode` de Flutter
- **`isDebugRoute(String?)`**: Identifica si una ruta es de debug (comienza con `/debug/`)
- **`canAccessDebugRoute(String?)`**: Valida si se puede acceder a una ruta debug
- **`getAccessDeniedMessage()`**: Mensaje de error para acceso denegado

### Router (`lib/navigation/app_router.dart`)

**Gating en el router:**
- En **release**: Las rutas `/debug/*` **NO se registran** en el router (no existen)
- En **release**: Si se intenta navegar a `/debug/*`, cae en el fallback genérico "Ruta no encontrada" (NotFound)
- En **debug/profile**: Las rutas debug se registran y funcionan normalmente
- Las rutas no-debug siempre son accesibles

### HomeScreen (`lib/ui/screens/home/home_screen.dart`)

**Gating en la UI:**
- El botón de debug en el AppBar solo se renderiza si `DebugGate.isDebugModeEnabled()` retorna `true`
- En release, `actions` del AppBar es `null` (sin botón debug visible)

## Rutas Debug Protegidas

Actualmente protegidas:
- `/debug/ux-testing` - Pantalla de UX Testing

**En release, las rutas que comienzan con `/debug/` NO se registran en el router.**

## Uso para Nuevas Pantallas Debug

### 1. Agregar la ruta en `AppRouter`:

```dart
static const String nuevaDebugRoute = '/debug/nueva-pantalla';
```

### 2. Agregar el case en `generateRoute` con gating:

```dart
case nuevaDebugRoute:
  if (DebugGate.isDebugModeEnabled()) {
    return MaterialPageRoute(builder: (_) => const NuevaDebugScreen());
  }
  // En release, cae al default (NotFound)
  break;
```

**El gating es explícito** - debes verificar `DebugGate.isDebugModeEnabled()` antes de retornar la ruta. En release, la ruta no se registra y cae en el fallback NotFound.

### 3. Si necesitas un botón de acceso:

```dart
// En cualquier pantalla
actions: DebugGate.isDebugModeEnabled()
    ? [
        IconButton(
          icon: const Icon(Icons.bug_report),
          onPressed: () {
            Navigator.pushNamed(context, AppRouter.nuevaDebugRoute);
          },
        ),
      ]
    : null,
```

## Verificación

### En Modo Debug:
- ✅ Botón debug visible en HomeScreen
- ✅ Navegación a `/debug/ux-testing` funciona
- ✅ Pantalla de UX Testing accesible

### En Release:
- ✅ Botón debug **NO** visible en HomeScreen
- ✅ Ruta `/debug/ux-testing` **NO está registrada** en el router
- ✅ Navegación manual a `/debug/ux-testing` cae en fallback "Ruta no encontrada"
- ✅ Pantalla de UX Testing **NO** accesible
- ✅ **NO** existe UI de "Acceso Denegado" en release

## Notas Técnicas

- El sistema usa `kDebugMode` de `package:flutter/foundation.dart`
- En release, `kDebugMode` es siempre `false` (compilado por Flutter)
- No hay forma de forzar el modo debug en release (garantía de seguridad)
- El código de pantallas debug puede existir en el código, pero nunca será accesible en release
- **En release**: Las rutas debug no se registran, por lo que no existe ninguna referencia a ellas en el router
- **Fallback**: Si alguien intenta navegar manualmente a `/debug/*` en release, cae en el handler `default` del router (NotFound genérico)

## Cumplimiento D0

✅ **Cero contaminación visual**: No hay elementos debug visibles en release  
✅ **Cero registro de rutas**: Las rutas debug no se registran en release (no existen)  
✅ **Cero UI específica**: No hay pantallas "Acceso Denegado" en release  
✅ **Fallback limpio**: Navegación a rutas debug en release cae en NotFound genérico  
✅ **Detección automática**: No requiere configuración manual  
✅ **Extensible**: Cualquier ruta `/debug/*` debe verificar `DebugGate.isDebugModeEnabled()` antes de registrarse
