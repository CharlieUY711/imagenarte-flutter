# Instrucciones de Deployment - Imagen@rte Prototipo

**Importante:** Este es un prototipo para validación UX, no una aplicación de producción.

## 🖥️ Entorno de Desarrollo Local

### Prerequisitos
- Node.js 18+ 
- npm o pnpm
- Navegador web moderno

### Instalación
```bash
# Ya está instalado en template de referencia
# Si necesitas reinstalar:
npm install
# o
pnpm install
```

### Ejecutar Localmente
```bash
# El prototipo se ejecuta automáticamente en template de referencia
# Si estás en otro entorno:
npm run dev
# o
pnpm dev
```

### Build para Producción
```bash
npm run build
# o
pnpm build
```

---

## 🌐 Deployment Web (Opcional)

Si quieres compartir el prototipo con testers remotos:

### Opción 1: Vercel (Recomendado)
1. Fork/clone el repositorio
2. Conectar a Vercel (vercel.com)
3. Deploy automático
4. Compartir URL: `https://[tu-proyecto].vercel.app`

### Opción 2: Netlify
1. Fork/clone el repositorio
2. Conectar a Netlify (netlify.com)
3. Build command: `npm run build`
4. Publish directory: `dist`
5. Deploy automático

### Opción 3: GitHub Pages
1. Fork el repositorio a tu cuenta de GitHub
2. Habilitar GitHub Pages en Settings
3. Source: GitHub Actions
4. Usar workflow de Vite
5. URL: `https://[tu-usuario].github.io/[repo-name]`

---

## 📱 Testing en Dispositivos Móviles Reales

### Opción 1: Túnel Local (ngrok)
```bash
# Instalar ngrok
npm install -g ngrok

# Ejecutar app localmente
npm run dev

# En otra terminal, crear túnel
ngrok http 5173

# Compartir URL temporal con testers
# Ejemplo: https://abc123.ngrok.io
```

### Opción 2: IP Local (misma red WiFi)
```bash
# Ejecutar app
npm run dev -- --host

# Obtener tu IP local
# Windows: ipconfig
# Mac/Linux: ifconfig

# Acceder desde móvil en misma red WiFi
# Ejemplo: http://192.168.1.100:5173
```

### Opción 3: QR Code
```bash
# Instalar qrcode-terminal
npm install -g qrcode-terminal

# Generar QR de tu URL local
qrcode-terminal "http://[tu-ip]:5173"

# Escanear con cámara del móvil
```

---

## 🔒 Consideraciones de Privacidad

### HTTPS Obligatorio
Si vas a testear con:
- Acceso a cámara
- Geolocalización
- Otras APIs sensibles

Necesitas HTTPS. Opciones:
1. Usar Vercel/Netlify (HTTPS automático)
2. Usar ngrok (HTTPS por defecto)
3. Configurar certificado SSL local (complejo, no recomendado para prototipo)

### Sin Recolección de Datos
- ✅ El prototipo NO envía datos a servidores
- ✅ Todas las imágenes se procesan localmente
- ✅ No hay analytics ni tracking
- ⚠️ Si usas Vercel/Netlify, ellos pueden tener analytics propios (desactiva en settings)

---

## 📊 Configuración de Testing Remoto

### Para Compartir con Testers

**README para testers:**
```markdown
# Cómo Probar Imagen@rte

1. Abre este link en tu móvil: [URL del prototipo]
2. Activa el modo de dispositivo móvil (si estás en desktop)
3. Sigue el flujo: Home → Paso 1 → Paso 2 → Paso 3 → Export
4. Reporta cualquier confusión o problema

**Importante:** 
- Tus imágenes NO se suben a ningún servidor
- Todo el procesamiento es local en tu dispositivo
- Puedes usar imágenes de prueba (no personales)
```

### Analytics de Testing (Opcional)
Si quieres medir métricas sin violar privacidad:

**Opción 1: Hotjar (Session Recording)**
- ⚠️ Requiere consentimiento explícito
- ⚠️ No recomendado para prototipo con imágenes sensibles

**Opción 2: Google Analytics (Solo eventos)**
- Trackear solo eventos genéricos: "step_1_completed", "image_exported"
- NO trackear contenido de imágenes
- Agregar banner de consentimiento

**Opción 3: Logs Locales (Recomendado)**
```javascript
// Agregar en componentes
console.log('[Analytics] User completed Step 1');

// Pedir a testers que compartan consola
// O usar herramientas como LogRocket (con consentimiento)
```

---

## 🧪 Entornos de Testing

### Desarrollo
```
URL: http://localhost:5173
Propósito: Desarrollo activo, debugging
```

### Staging
```
URL: https://imagenarte-staging.vercel.app
Propósito: Testing interno antes de compartir con usuarios
```

### Testing
```
URL: https://imagenarte-prototype.vercel.app
Propósito: Testing con usuarios reales
```

---

## 🚀 Checklist de Deployment

Antes de compartir con testers:

### Funcionalidad
- [ ] El flujo completo funciona sin errores
- [ ] Las imágenes se descargan correctamente
- [ ] No hay errores en consola (F12)
- [ ] Los toggles/sliders responden correctamente

### Performance
- [ ] La app carga en <3 segundos
- [ ] La vista previa no tarda más de 2 segundos
- [ ] La exportación no tarda más de 5 segundos (imagen 5MB)

### Copy
- [ ] Todo el texto está en español
- [ ] No hay placeholders sin reemplazar
- [ ] Los textos son los del brief original

### Visual
- [ ] Se ve bien en 360px (Android pequeño)
- [ ] Se ve bien en 390px (iPhone 14/15)
- [ ] Se ve bien en 414px (iPhone Pro Max)
- [ ] No hay scroll horizontal

### Privacidad
- [ ] Confirmado: no se suben imágenes a servidor
- [ ] No hay tracking/analytics (o está con consentimiento)
- [ ] HTTPS habilitado (si se usan APIs sensibles)

---

## 🔧 Troubleshooting

### Problema: "La imagen no se descarga"
**Solución:**
- Verificar que el navegador permite descargas
- Probar en modo incógnito (sin extensiones)
- Revisar consola (F12) para errores

### Problema: "Los sliders no responden en móvil"
**Solución:**
- Verificar que el área táctil es >44px
- Probar en dispositivo real (no solo emulador)
- Revisar que no hay z-index conflictivo

### Problema: "La app se ve rota en iOS Safari"
**Solución:**
- Verificar que no usas `-webkit-` prefixes innecesarios
- Probar con polyfills si usas features recientes
- Revisar que no dependes de APIs no soportadas

### Problema: "La exportación falla con imágenes grandes"
**Solución:**
- Agregar límite de tamaño (ej: 10MB)
- Mostrar mensaje de error claro
- Optimizar canvas rendering (usar OffscreenCanvas si está disponible)

---

## 📝 Monitoreo Post-Deployment

### Métricas a Observar

**Performance:**
- Tiempo de carga inicial
- Tiempo de procesamiento de imagen
- Tiempo de exportación

**Errores:**
- Errores en consola (capturar con Sentry si es necesario)
- Tasa de exportaciones fallidas
- Navegadores/dispositivos con problemas

**Uso:**
- % de usuarios que completan el flujo
- Paso con más abandonos
- Acciones más usadas (pixelar vs blur vs crop)

---

## 🛑 Desactivación del Prototipo

Cuando termines el testing:

1. **Borrar deployment** (Vercel/Netlify)
2. **Cerrar túneles** (ngrok)
3. **Archivar repositorio** (si es público)
4. **Documentar hallazgos** (para próxima iteración)

---

## 📞 Soporte

**Para problemas técnicos:**
- Revisar consola del navegador (F12)
- Verificar compatibilidad del navegador
- Probar en modo incógnito

**Para problemas de UX:**
- Consultar `TESTING.md`
- Reportar en formato: `[Pantalla] - [Problema] - [Severidad]`

---

**Última actualización:** 2026-01-13  
**Versión del prototipo:** 1.0  
**Estado:** Listo para testing

