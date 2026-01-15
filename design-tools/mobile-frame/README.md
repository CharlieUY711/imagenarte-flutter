# Mobile Frame — Herramienta de Diseño

## ¿Qué es?

Herramienta de diseño clínica para visualizar la app Imagen@rte dentro de un viewport fijo de 390×844px (iPhone-ish) en pantalla desktop. Permite ajustar spacing, jerarquía visual y revisar la experiencia móvil sin usar DevTools.

## ¿Qué NO es?

- **NO es parte del producto en producción**
- **NO modifica la lógica de negocio ni la arquitectura**
- **NO es un mockup de marketing** (es una maqueta clínica, sobria y funcional)

## Cómo usar

### Opción 1: Con DevTools (Referencia canónica)
Abrir la app en el navegador y usar las DevTools del navegador para simular dispositivos móviles. Esta es la referencia canónica para testing real.

### Opción 2: Con Mobile Frame (Comparación rápida)
1. Asegúrate de que la app esté corriendo en localhost (puerto configurable)
   - **Ver guía completa**: `../dev-server/README.md`
   - **Resumen rápido**: Compila con `flutter build web`, luego levanta un servidor desde `apps/mobile/build/web`
2. Abre `mobile-frame.html` con doble click o arrástralo al navegador
3. El frame mostrará la app dentro de un "dispositivo" centrado de 390×844px

## Configuración

### Cambiar URL del iframe

1. Abre `mobile-frame.html`
2. Busca la constante `APP_URL` en el script (línea ~23)
3. Cambia el valor, por ejemplo:
   ```javascript
   const APP_URL = 'http://localhost:5173';  // Vite default
   const APP_URL = 'http://localhost:3000';  // React/Next.js
   const APP_URL = 'http://localhost:8080';  // Otros servidores
   ```

### Ajustar escala del frame

Si el dispositivo no entra en pantalla, ajusta la variable `--frame-scale` en `mobile-frame.css`:

1. Abre `mobile-frame.css`
2. Busca `:root { --frame-scale: 1; }` (línea ~5)
3. Cambia el valor, por ejemplo:
   ```css
   :root {
       --frame-scale: 0.9;  /* 90% del tamaño original */
   }
   ```

## Checklist Visual (Mobile)

Al revisar la app en el frame, verificar:

1. ✅ **Imagen protagonista**: Ocupa el espacio central sin recortes
2. ✅ **Barra superior**: Altura de 25px, no compite con contenido
3. ✅ **DialButtons**: Tamaño de 30px, espaciado adecuado
4. ✅ **Panel inferior**: No aplasta la imagen, mantiene jerarquía
5. ✅ **Un dial activo**: Se entiende claramente qué dial está seleccionado

---

**Nota**: Esta herramienta es solo para diseño/UX. No incluir en builds de producción.
