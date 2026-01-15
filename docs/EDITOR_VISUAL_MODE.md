# Editor Visual - Modo Solo UI

**Estado:** ✅ Implementado  
**Propósito:** Corregir la parte gráfica sin funcionalidades complejas

---

## 📋 Descripción

Se creó una versión simplificada del editor (`EditorScreenVisual`) que solo muestra la interfaz gráfica sin dependencias complejas. Esto permite:

- ✅ Corregir el diseño visual sin errores de compilación
- ✅ Verificar que los componentes se vean correctamente
- ✅ Ajustar colores, tamaños y espaciados
- ✅ Integrar funcionalidades después

---

## 🎨 Componentes Visuales Incluidos

### 1. Toolbar Naranja (25px)
- Barra superior naranja con botón de cerrar
- Título "Editor" centrado

### 2. Área de Preview (2/3 de pantalla)
- Fondo negro para que la imagen destaque
- Placeholder de imagen con texto "Luna"
- Badge "CONECTADA" en esquina superior derecha (naranja)

### 3. Panel de Control Inferior (1/3 de pantalla)
- **Barra de herramientas naranja** con 6 iconos:
  - Crop (crop_free)
  - Mover (open_with)
  - Aspecto (aspect_ratio)
  - Rotar (rotate_right)
  - Mano (pan_tool)
  - Deshacer (undo)

- **Botones de opciones** (gris oscuro):
  - Pixelar rostro
  - Blur selectivo
  - Intensidad de crop

- **Controles de relación de aspecto** (4 iconos):
  - Vertical (seleccionado - naranja)
  - Horizontal
  - Cuadrado
  - Círculo

- **Iconos de ajuste** (2 filas de 4 iconos):
  - Primera fila: Paleta (seleccionado), Tune, Café, Bombilla
  - Segunda fila: Círculo, Gota, Sol, Flash

- **Botones de navegación** (naranja):
  - Volver (izquierda)
  - Grabar (derecha)

---

## 🚀 Cómo Usar

### 1. Compilar la app

```bash
cd apps/mobile
flutter build web
```

### 2. Iniciar servidor

```bash
cd apps/mobile/build/web
python -m http.server 8080
```

### 3. Acceder

- **URL directa:** http://localhost:8080
- **Desde Home:** Click en "Editor Visual (UI)"

---

## 📁 Archivos Creados/Modificados

### Nuevos Archivos
- `apps/mobile/lib/presentation/screens/editor_screen_visual.dart` - Versión visual simplificada
- `apps/mobile/lib/presentation/widgets/bottom_control_panel.dart` - Panel de control inferior

### Archivos Modificados
- `apps/mobile/lib/navigation/app_router.dart` - Usa EditorScreenVisual en lugar de EditorScreen
- `apps/mobile/lib/ui/screens/home/home_screen.dart` - Botón para acceder al editor visual

---

## 🔄 Próximos Pasos

### Para Corregir UI:
1. Abrir `editor_screen_visual.dart`
2. Ajustar colores, tamaños, espaciados
3. Verificar en navegador
4. Iterar hasta que coincida con el diseño

### Para Integrar Funcionalidades:
1. Una vez la UI esté correcta, cambiar en `app_router.dart`:
   ```dart
   // Cambiar de:
   EditorScreenVisual()
   // A:
   EditorScreen(imagePath: args?['imagePath'])
   ```

2. Integrar callbacks del `BottomControlPanel` con la lógica real

---

## 🎨 Tokens de Diseño Usados

- `AppTokens.editorBackground` - Fondo negro (#000000)
- `AppTokens.neutralDark` - Panel oscuro (#1C1C1E)
- `AppTokens.accentOrange` - Color naranja (#F97316)
- `AppTokens.neutralMedium` - Elementos secundarios (#737373)

---

## ⚠️ Notas

- **Sin funcionalidades:** Los botones solo muestran feedback visual (haptic feedback, snackbar)
- **Sin dependencias complejas:** No usa ViewModel, Controller, ni packages de procesamiento
- **Fácil de modificar:** Todo el código está en un solo archivo (`editor_screen_visual.dart`)

---

**Última actualización:** 2026-01-13  
**Estado:** ✅ Listo para corregir UI
