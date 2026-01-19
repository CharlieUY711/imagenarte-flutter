# Instrucciones de Instalación PWA - Imagen@rte

Esta guía explica cómo instalar la aplicación web Imagen@rte como PWA (Progressive Web App) en dispositivos Android e iOS.

## Requisitos Previos

- La aplicación debe estar desplegada y accesible vía HTTPS (requerido para PWA)
- Navegador compatible:
  - **Android**: Chrome, Edge, Samsung Internet
  - **iOS**: Safari 11.3+ (iOS 11.3+)

---

## 📱 Instalación en Android

### Método 1: Banner de Instalación Automático

1. Abre la aplicación en **Chrome** o **Edge** en tu dispositivo Android
2. Si la PWA es instalable, verás un banner en la parte inferior de la pantalla que dice "Agregar a la pantalla de inicio" o "Instalar app"
3. Toca **"Agregar"** o **"Instalar"**
4. La aplicación se instalará y aparecerá un icono en la pantalla de inicio

### Método 2: Menú del Navegador

1. Abre la aplicación en **Chrome** o **Edge**
2. Toca el menú (tres puntos) en la esquina superior derecha
3. Busca la opción **"Agregar a la pantalla de inicio"** o **"Instalar app"**
4. Toca la opción
5. Confirma la instalación en el diálogo que aparece
6. La aplicación se instalará y aparecerá un icono en la pantalla de inicio

### Método 3: Ajustes del Navegador

1. Abre la aplicación en **Chrome**
2. Toca el menú (tres puntos) → **"Configuración"**
3. Busca **"Agregar a la pantalla de inicio"** en la lista
4. Toca la opción y confirma

---

## 🍎 Instalación en iOS (Safari)

### Pasos para Instalar

1. Abre **Safari** en tu iPhone o iPad (no funciona en Chrome u otros navegadores en iOS)
2. Navega a la URL de la aplicación
3. Toca el botón **"Compartir"** (cuadrado con flecha hacia arriba) en la barra inferior
4. Desplázate hacia abajo en el menú de compartir
5. Toca **"Agregar a pantalla de inicio"** (icono con un "+" en un cuadrado)
6. Personaliza el nombre si lo deseas (por defecto será "Imagen@rte")
7. Toca **"Agregar"** en la esquina superior derecha
8. La aplicación se instalará y aparecerá un icono en la pantalla de inicio

### Notas Importantes para iOS

- **Solo funciona en Safari**: Chrome, Firefox y otros navegadores en iOS no soportan la instalación de PWA
- **iOS 11.3+ requerido**: Asegúrate de tener una versión reciente de iOS
- **HTTPS obligatorio**: La aplicación debe estar servida vía HTTPS

---

## ✅ Verificar la Instalación

Una vez instalada, deberías poder:

- Ver el icono de la aplicación en la pantalla de inicio
- Abrir la aplicación como una app independiente (sin barra de direcciones del navegador)
- Usar la aplicación en modo offline básico (funcionalidad limitada según la configuración)

---

## 🔧 Solución de Problemas

### Android: No aparece la opción de instalación

- Verifica que estés usando Chrome o Edge (no Firefox)
- Asegúrate de que la aplicación esté servida vía HTTPS
- Limpia la caché del navegador y vuelve a intentar
- Verifica que el manifest esté correctamente configurado

### iOS: No aparece "Agregar a pantalla de inicio"

- Asegúrate de estar usando **Safari** (no Chrome u otros navegadores)
- Verifica que tengas iOS 11.3 o superior
- Asegúrate de que la aplicación esté servida vía HTTPS
- Intenta cerrar y volver a abrir Safari

### La aplicación no funciona offline

- El modo offline básico está habilitado, pero algunas funcionalidades pueden requerir conexión
- Verifica que el Service Worker esté correctamente registrado (consulta las herramientas de desarrollador)

---

## 📝 Notas Técnicas

- **Service Worker**: Se registra automáticamente con `registerType: 'autoUpdate'`
- **Actualizaciones**: La aplicación se actualizará automáticamente cuando haya nuevas versiones
- **Iconos**: Se usan iconos placeholder de 192x192 y 512x512 píxeles
- **Tema**: Color de tema naranja (#f97316) para coincidir con el diseño del prototipo

---

## 🚀 Desarrollo Local

Para probar la PWA localmente:

1. Ejecuta `npm run dev` (puerto 5173)
2. Accede desde tu dispositivo móvil usando la IP local de tu máquina
3. Sigue las instrucciones de instalación según tu plataforma

**Nota**: Para que funcione correctamente, es recomendable usar un túnel HTTPS (como ngrok) o desplegar en un servidor con HTTPS habilitado.
