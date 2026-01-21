# Barreras Preventivas del Repositorio: Imagen@rte

**Última actualización:** 2026-01-20  
**Fase:** F3 - Endurecimiento de Barreras Preventivas  
**Rama:** `chore/repo-saneamiento-F3-barriers`

---

## 🎯 Objetivo

Este documento define las **barreras preventivas** que impiden que prototipos web, artefactos npm y exports no deseados entren al repositorio. Estas barreras se implementan mediante `.gitignore` y políticas de trabajo documentadas.

---

## 🚫 ¿Por Qué Se Bloquean Prototipos Web?

El repositorio **Imagen@rte** es **Flutter-first**. Esto significa:

1. **Enfoque principal:** La aplicación móvil Flutter es el producto principal.
2. **Arquitectura:** El repositorio está estructurado para soportar desarrollo Flutter con packages Dart locales.
3. **Contrato del repositorio:** El README y la documentación declaran explícitamente que este es un proyecto Flutter.

**Problemas de incluir prototipos web:**

- **Contaminación estructural:** Introduce dependencias npm, configuraciones de bundlers (Vite, Webpack, etc.) y estructuras de carpetas que no pertenecen a un proyecto Flutter.
- **Confusión de alcance:** Los desarrolladores pueden confundirse sobre qué tecnologías usar.
- **Mantenimiento innecesario:** Requiere mantener dos ecosistemas (Flutter/Dart y npm/JavaScript) en el mismo repositorio.
- **Tamaño del repositorio:** Los `node_modules/` y artefactos de build web pueden inflar significativamente el tamaño del repo.

---

## 📁 Carpetas y Archivos Prohibidos

Las siguientes carpetas y archivos están **explícitamente excluidos** del repositorio mediante `.gitignore`:

### Prototipos Web

- `figma_extracted/` - Prototipo web extraído de Figma (React/TypeScript/Vite)
- `web/prototype/` - Cualquier prototipo web en la carpeta `web/`

### Artefactos npm/yarn/pnpm

- `**/node_modules/` - Dependencias npm (en cualquier nivel del árbol)
- `package-lock.json` - Lockfile de npm
- `pnpm-lock.yaml` - Lockfile de pnpm
- `yarn.lock` - Lockfile de yarn

### Builds y Artefactos de Herramientas Web

- `**/dist/` - Directorios de distribución (Vite, Webpack, etc.)
- `**/build_artifacts/` - Artefactos de build genéricos
- `**/.next/` - Builds de Next.js
- `**/.turbo/` - Cache de Turborepo
- `**/.vite/` - Cache de Vite
- `**/.parcel-cache/` - Cache de Parcel
- `**/.cache/` - Cache genérico

### Exports y Temporales

- `exports/` - Directorio de exports (si existe)
- `tmp/` - Directorios temporales
- `backup/` - Backups
- `*.log` - Archivos de log (ya cubierto por regla existente)

### Coverage

- `**/coverage/` - Reportes de cobertura de tests (ya existía, reforzado)

---

## ✅ Cómo Actuar Si Se Necesita un Asset del Prototipo

Si necesitas usar un asset (imagen, icono, etc.) que está en el prototipo web:

### Opción 1: Copiar Selectivo a `docs/assets/` (Recomendado)

1. **Identifica el asset necesario:**
   ```bash
   # Ejemplo: necesitas un icono del prototipo
   figma_extracted/src/assets/icons/logo.svg
   ```

2. **Copia el asset a documentación:**
   ```bash
   # Crear directorio si no existe
   mkdir -p docs/assets/icons
   
   # Copiar el asset
   cp figma_extracted/src/assets/icons/logo.svg docs/assets/icons/
   ```

3. **Agrega el asset a Git:**
   ```bash
   git add docs/assets/icons/logo.svg
   ```

4. **Documenta el origen:**
   - Agrega un comentario en el archivo o en `docs/assets/README.md` indicando que el asset proviene del prototipo.

### Opción 2: Copiar a `apps/mobile/assets/` (Si es para la app)

1. **Copia el asset directamente a la app Flutter:**
   ```bash
   # Ejemplo: copiar imagen a assets de la app
   cp figma_extracted/src/assets/images/hero.png apps/mobile/assets/images/
   ```

2. **Actualiza `pubspec.yaml`:**
   ```yaml
   flutter:
     assets:
       - assets/images/hero.png
   ```

3. **Agrega el asset a Git:**
   ```bash
   git add apps/mobile/assets/images/hero.png
   git add apps/mobile/pubspec.yaml
   ```

### ⚠️ Regla de Oro

**NUNCA agregues el prototipo completo al repositorio.** Solo copia los assets individuales que necesites y documenta su origen.

---

## 🔍 Verificación de Barreras

Para verificar que las barreras están funcionando:

### 1. Verificar que `.gitignore` está actualizado

```bash
# Ver contenido de .gitignore
cat .gitignore | grep -A 20 "BARRERAS PREVENTIVAS"
```

### 2. Verificar que archivos prohibidos no están rastreados

```bash
# Verificar figma_extracted
git ls-files figma_extracted/ | head -5
# Debe retornar vacío si está correctamente ignorado

# Verificar node_modules
git ls-files | grep node_modules
# Debe retornar vacío

# Verificar package-lock.json
git ls-files package-lock.json
# Debe retornar vacío
```

### 3. Verificar que nuevos archivos se ignoran

```bash
# Intentar agregar un archivo prohibido (debe fallar silenciosamente)
git add figma_extracted/package.json
git status
# No debe aparecer en "Changes to be committed"
```

---

## 📋 Checklist de Validación

Antes de hacer commit, verifica:

- [ ] `.gitignore` contiene todas las exclusiones listadas en este documento
- [ ] No hay archivos prohibidos en el índice de Git (`git ls-files` no retorna nada de las carpetas prohibidas)
- [ ] Si copiaste assets del prototipo, están documentados
- [ ] Los assets copiados están en ubicaciones permitidas (`docs/assets/` o `apps/mobile/assets/`)

---

## 🔄 Mantenimiento

Este documento debe actualizarse cuando:

1. Se agregan nuevas exclusiones a `.gitignore`
2. Se cambia la política sobre qué está permitido/prohibido
3. Se documentan nuevas excepciones o casos de uso

**Responsable:** El equipo debe revisar este documento periódicamente (al menos en cada fase de saneamiento del repositorio).

---

## 📚 Referencias

- `.gitignore` - Implementación de las barreras
- `docs/workflows/REPO_SANITY_CHECK.md` - Checklist de sanidad que valida estas barreras
- `docs/ARCHITECTURE.md` - Arquitectura del proyecto (declara enfoque Flutter-first)

---

**Fin del Documento**
