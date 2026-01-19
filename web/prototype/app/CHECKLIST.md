# Checklist de Validación - Imagen@rte Prototipo v1.0

## ✅ Pre-Testing (Antes de dar acceso a testers)

### Funcionalidad Básica
- [ ] La app carga correctamente en el navegador
- [ ] No hay errores en la consola del navegador (F12)
- [ ] El flujo completo se puede completar sin crashes
- [ ] La imagen se descarga correctamente al exportar

### Pantallas
- [ ] Home se muestra correctamente
- [ ] Wizard Step 1 permite seleccionar imagen
- [ ] Wizard Step 2 muestra todos los toggles/sliders
- [ ] Wizard Step 3 muestra resumen de acciones
- [ ] Export muestra todas las opciones
- [ ] Success muestra confirmación y botón de reset

### Copy
- [ ] Todo el texto está en español
- [ ] No hay textos en inglés no traducidos
- [ ] No hay "Lorem ipsum" o placeholders
- [ ] Los textos coinciden con el brief

---

## 🧪 Durante Testing (Observar)

### Navegación
- [ ] Los testers encuentran el botón "Tratar imagen" sin ayuda
- [ ] Los testers entienden que deben elegir una imagen en Step 1
- [ ] Los testers encuentran el botón "Siguiente" sin buscar
- [ ] Los testers ven el botón "Atrás" cuando lo necesitan
- [ ] Los testers completan el flujo sin quedarse bloqueados

### Acciones (Step 2)
- [ ] Los testers entienden qué hace "Pixelar rostro"
- [ ] Los testers encuentran el slider de intensidad al activar toggle
- [ ] Los testers entienden que "Quitar fondo" está deshabilitado
- [ ] Los testers entienden el selector de aspect ratio (crop)
- [ ] Los testers pueden avanzar sin activar ninguna acción

### Export
- [ ] Los testers entienden la diferencia entre JPG/PNG/WebP
- [ ] Los testers ven el slider de calidad cuando corresponde
- [ ] Los testers entienden qué son los "metadatos EXIF"
- [ ] Los testers entienden la diferencia entre watermark visible/invisible
- [ ] Los testers encuentran el botón "Exportar"

### Privacidad
- [ ] Los testers confían en que la imagen no se sube a un servidor
- [ ] Los testers entienden que todo es local
- [ ] Los testers notan que no hay login/registro
- [ ] Los testers no buscan botones de compartir/redes sociales

---

## 📱 Compatibilidad (Testar en múltiples dispositivos)

### Navegadores Desktop
- [ ] Chrome (última versión)
- [ ] Firefox (última versión)
- [ ] Safari (última versión)
- [ ] Edge (última versión)

### Navegadores Mobile
- [ ] Chrome Android
- [ ] Safari iOS
- [ ] Firefox Android
- [ ] Samsung Internet

### Tamaños de Pantalla
- [ ] 360x640 (Android pequeño)
- [ ] 390x844 (iPhone 14/15)
- [ ] 414x896 (iPhone Pro Max)
- [ ] 768x1024 (iPad portrait)

### Orientación
- [ ] Portrait (vertical) - funciona correctamente
- [ ] Landscape (horizontal) - funciona o muestra mensaje de orientación

---

## 🎨 Visual QA (Calidad Visual)

### Tipografía
- [ ] Los textos son legibles en pantallas pequeñas
- [ ] No hay textos cortados o desbordados
- [ ] El tamaño de fuente es consistente
- [ ] Los títulos se distinguen del body text

### Espaciado
- [ ] Hay espacio suficiente entre elementos
- [ ] Los botones no están muy juntos
- [ ] Las secciones tienen separación clara
- [ ] El padding es consistente

### Colores
- [ ] Los colores son neutros y profesionales
- [ ] Hay suficiente contraste (textos legibles)
- [ ] Los estados disabled se ven claramente
- [ ] Los botones primarios se distinguen de los secundarios

### Interactividad
- [ ] Los botones responden al tap/click (feedback visual)
- [ ] Los toggles cambian de estado visiblemente
- [ ] Los sliders se pueden arrastrar fácilmente
- [ ] Los dropdowns se abren correctamente

---

## 🚨 Casos Edge (Testar límites)

### Selección de Imagen
- [ ] ¿Qué pasa si selecciono una imagen muy grande (>10MB)?
- [ ] ¿Qué pasa si selecciono un archivo que no es imagen?
- [ ] ¿Qué pasa si cancelo el file picker sin seleccionar nada?
- [ ] ¿Qué pasa si selecciono una imagen y luego elijo otra?

### Acciones (Step 2)
- [ ] ¿Qué pasa si activo todos los toggles a la vez?
- [ ] ¿Qué pasa si pongo intensidad al mínimo (1)?
- [ ] ¿Qué pasa si pongo intensidad al máximo (10)?
- [ ] ¿Qué pasa si cambio de aspect ratio varias veces?

### Export
- [ ] ¿Qué pasa si cambio de formato varias veces?
- [ ] ¿Qué pasa si activo watermark visible sin escribir texto?
- [ ] ¿Qué pasa si el texto del watermark es muy largo?
- [ ] ¿Qué pasa si exporto varias veces seguidas?

### Navegación hacia Atrás
- [ ] ¿Los cambios se mantienen al volver atrás?
- [ ] ¿Puedo volver desde Export hasta Step 1?
- [ ] ¿Qué pasa si vuelvo atrás y cambio la imagen?
- [ ] ¿Qué pasa si vuelvo atrás y cambio las acciones?

---

## 🐛 Bugs Conocidos (Documentar durante testing)

### Ejemplo de formato:
```
[Pantalla] - [Descripción del bug] - [Severidad]

Severidades:
1 - Crítico (bloquea el flujo)
2 - Alto (afecta funcionalidad principal)
3 - Medio (afecta usabilidad)
4 - Bajo (cosmético)
5 - Trivial (nice to have)
```

### Bugs reportados:
1. [ ] *(Espacio para agregar bugs durante testing)*
2. [ ] 
3. [ ] 
4. [ ] 
5. [ ] 

---

## 💬 Feedback Cualitativo (Recopilar)

### Preguntas Abiertas para Testers

**Claridad:**
- ¿Hubo algún momento en que no supiste qué hacer?
- ¿Algún texto te pareció confuso o técnico?
- ¿Esperabas encontrar algo que no estaba?

**Confianza:**
- ¿Te sentís seguro de que tus imágenes no se suben a internet?
- ¿Confiarías en usar esta app con fotos personales?
- ¿Algo te generó desconfianza o dudas?

**Simplicidad:**
- ¿Algo te pareció innecesariamente complejo?
- ¿Hay opciones que sobran?
- ¿Falta algo esencial?

**Velocidad:**
- ¿El flujo se sintió rápido o lento?
- ¿Hay algún paso que podrías saltear?
- ¿Algo tomó más tiempo del esperado?

---

## 📊 Métricas Cuantitativas (Medir)

### Tiempo de Completado
- [ ] Flujo mínimo (sin activar acciones): ____ segundos
- [ ] Flujo completo (con todas las acciones): ____ segundos
- [ ] Promedio de todos los testers: ____ segundos

### Tasa de Completado
- [ ] % de testers que completaron el flujo sin ayuda: ____%
- [ ] % de testers que necesitaron ayuda: ____%
- [ ] % de testers que abandonaron: ____%

### Comprensión
- [ ] % de testers que entendieron el flujo a la primera: ____%
- [ ] % de testers que preguntaron "¿dónde está...?": ____%
- [ ] % de testers que buscaron features no implementadas: ____%

### Satisfacción
- [ ] % de testers que califican el flujo como "simple": ____%
- [ ] % de testers que confían en la privacidad: ____%
- [ ] % de testers que usarían la app en producción: ____%

---

## 🎯 Criterios de Éxito (Umbrales)

### Flujo
- ✅ **90%+** de testers completan flujo mínimo sin ayuda
- ✅ **80%+** completan flujo completo sin ayuda
- ✅ **<120 segundos** promedio para flujo mínimo

### Comprensión
- ✅ **95%+** entienden que no hay backend/cloud
- ✅ **90%+** entienden que pueden avanzar sin activar acciones
- ✅ **85%+** entienden diferencia entre watermarks

### Fricción
- ✅ **<10%** abandonan por confusión
- ✅ **<5%** reportan "no sé qué hacer"
- ✅ **0** testers buscan login/compartir/historial

### Satisfacción
- ✅ **80%+** califican como "simple" o "muy simple"
- ✅ **75%+** confían en privacidad
- ✅ **70%+** lo usarían con imágenes reales

---

## 📝 Post-Testing (Después del testing)

### Análisis
- [ ] Consolidar todos los bugs reportados
- [ ] Priorizar por severidad (1-5)
- [ ] Analizar patrones en feedback cualitativo
- [ ] Calcular métricas cuantitativas

### Reporte
- [ ] Crear documento de hallazgos
- [ ] Listar cambios críticos (severidad 1-2)
- [ ] Listar mejoras sugeridas (severidad 3-5)
- [ ] Proponer iteraciones al flujo

### Decisiones
- [ ] ¿El flujo es suficientemente simple?
- [ ] ¿El copy es claro?
- [ ] ¿Hay que agregar/quitar features?
- [ ] ¿Está listo para diseñar en herramienta de dise�o?

---

## 🚀 Siguientes Pasos

### Si el testing es exitoso (>80% métricas verdes):
1. [ ] Documentar decisiones finales
2. [ ] Crear brief para diseño en herramienta de dise�o
3. [ ] Definir sistema de componentes
4. [ ] Planificar implementación Flutter

### Si el testing revela problemas (>20% métricas rojas):
1. [ ] Iterar el prototipo con cambios críticos
2. [ ] Re-testear con nuevos usuarios
3. [ ] Validar que los problemas se resolvieron
4. [ ] Repetir hasta alcanzar métricas verdes

---

## 📞 Contacto

**Para reportar bugs:**
- Formato: `[Pantalla] - [Bug] - [Severidad 1-5]`
- Ejemplo: `[Export] - Watermark no se aplica si el texto tiene emojis - 3`

**Para sugerir mejoras:**
- Formato: `[Área] - [Sugerencia] - [Justificación]`
- Ejemplo: `[Step2] - Agregar tooltip explicando qué es EXIF - Muchos usuarios no lo entienden`

**Para preguntas:**
- Consultar `README.md`, `TESTING.md`, `TECHNICAL.md` primero
- Luego preguntar con contexto específico

---

**Última actualización:** 2026-01-13  
**Versión del prototipo:** 1.0  
**Estado:** Listo para testing

