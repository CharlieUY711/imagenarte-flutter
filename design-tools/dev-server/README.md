# Servidor Local de Diseño — Imagen@rte

## ¿Qué es?

Herramienta simple para levantar la app en **localhost** y visualizarla dentro del **Mobile Frame** para revisiones UI/UX.

## ¿Qué NO es?

- ❌ **NO es un servidor de producción**
- ❌ **NO hace build ni compilación**
- ❌ **NO modifica código productivo**
- ❌ **NO introduce dependencias pesadas**
- ❌ **NO es parte de la arquitectura del proyecto**

---

## Uso Rápido

### Paso 1: Compilar la app Flutter para web

Primero, compila la app para web (solo la primera vez o cuando cambies código):

```bash
cd apps/mobile
flutter build web
```

### Paso 2: Levantar el servidor

Navega a la carpeta que contiene el entry point de la app y levanta el servidor:

```bash
cd apps/mobile/build/web
```

**Opción Python** (Recomendado - Viene preinstalado en la mayoría de sistemas):
```bash
python -m http.server 8080
```

**Opción Node** (Si tienes Node.js instalado):
```bash
npx serve -p 8080
```

### Paso 3: Verificar la URL

El servidor estará disponible en: **http://localhost:8080**

Puedes abrir esta URL directamente en tu navegador para verificar que funciona.

### Paso 4: Conectar con el Mobile Frame

1. Abre `design-tools/mobile-frame/mobile-frame.html` en tu navegador
2. Si el servidor está en un puerto diferente a `5173`, ajusta la URL:
   - Abre `design-tools/mobile-frame/mobile-frame.html` en un editor de texto
   - Busca la constante `APP_URL` (línea ~24)
   - Cambia el valor:
     ```javascript
     const APP_URL = 'http://localhost:8080';
     ```
3. Guarda el archivo y recarga `mobile-frame.html` en el navegador
4. La app aparecerá dentro del frame móvil

---

## Script Opcional (Windows)

Para facilitar el proceso en Windows, puedes usar el script incluido:

```bash
design-tools/dev-server/start-server.cmd
```

Este script:
- Verifica que la app esté compilada
- Cambia automáticamente al directorio correcto
- Levanta el servidor en `http://localhost:8080`
- Muestra mensajes claros en consola

---

## Resumen de Comandos

**Desde la raíz del proyecto:**

1. Compilar (si es necesario):
   ```bash
   cd apps/mobile
   flutter build web
   ```

2. Levantar servidor:
   ```bash
   cd apps/mobile/build/web
   python -m http.server 8080
   ```

3. URL obtenida: **http://localhost:8080**

4. Conectar Mobile Frame:
   - Ajustar `APP_URL` en `design-tools/mobile-frame/mobile-frame.html`
   - Abrir `mobile-frame.html` en navegador

---

## Troubleshooting

### "Puerto ya en uso"
- Usa otro puerto: `python -m http.server 8081`
- O cierra el proceso que está usando ese puerto

### "No se ve la app en el iframe"
- Verifica que el servidor esté corriendo
- Verifica que la URL en `mobile-frame.html` coincida con el puerto del servidor
- Abre `http://localhost:8080` directamente en el navegador para verificar que funciona

### "Cambios no se reflejan"
- Recompila la app: `cd apps/mobile && flutter build web`
- Refresca el navegador (Ctrl+F5 o Cmd+Shift+R)

### "No tengo Python"
- Usa `npx serve -p 8080` (requiere Node.js)
- O instala Python desde python.org

---

## Notas Importantes

- ⚠️ **Este servidor es solo para desarrollo/design**
- ⚠️ **NO usar en producción**
- ⚠️ **NO modifica la arquitectura del proyecto**
- ⚠️ **Es una herramienta de diseño, no parte del producto**
