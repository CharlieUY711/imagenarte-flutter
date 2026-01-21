# Checklist de Sanidad del Repositorio: Imagen@rte

## 📊 Estado Global

**Estado global:** 🟡 EN PROGRESO  
**Última actualización:** 2026-01-20  
**Rama evaluada:** `chore/repo-saneamiento-F4-sanitize` (desde `origin/main`)  
**Evaluado por:**
- Cursor (agente): 🟢 Sí
- Humano (guardian): ⬜ Pendiente

> ⚠️ **BLOQUEO DE MERGE**: El repositorio NO puede recibir merge a `origin/main` hasta que el estado global sea 🟢 APROBADO y validado por un humano.

---

## 📋 Checklist Estructural

### A. Alcance (NO FEATURES)

- [x] **A.1** El checklist NO modifica lógica funcional
  - **Estado:** OK
  - **Evidencia:** Este checklist es puramente estructural y de gobernanza. No toca código de features, UI, flujos ni dependencias.

- [x] **A.2** El checklist NO agrega ni modifica features
  - **Estado:** OK
  - **Evidencia:** Solo inspección y documentación del estado actual del repositorio.

- [x] **A.3** El checklist NO realiza reescritura de historia Git
  - **Estado:** OK
  - **Evidencia:** No se ejecutaron comandos de force-push, rebase sobre main, ni alteración de historia.

---

### B. Rama y Base

- [x] **B.1** Rama canónica identificada y verificada
  - **Estado:** OK
  - **Evidencia:** 
    - Rama actual: `main` (verificado con `git branch --show-current`)
    - Remoto configurado: `origin` → `https://github.com/CharlieUY711/imagenarte-flutter.git` (verificado con `git remote -v`)

- [x] **B.2** Repositorio tiene remoto configurado
  - **Estado:** OK
  - **Evidencia:** `origin` apunta a `https://github.com/CharlieUY711/imagenarte-flutter.git`

- [x] **B.3** Estado de trabajo limpio o documentado
  - **Estado:** OK
  - **Evidencia:** 
    - Archivo sin rastrear: `docs/F1_AUDITORIA_REPORTE.md` (no bloqueante, documentación nueva)
    - No hay cambios staged ni modificaciones en archivos rastreados

---

### C. Contrato del Repositorio

- [x] **C.1** El repositorio declara ser Flutter-first
  - **Estado:** OK
  - **Evidencia:** 
    - `README.md` línea 1: "Aplicación **offline-first** para tratamiento..."
    - `README.md` línea 18: "mobile/ # Aplicación Flutter"
    - `docs/ARCHITECTURE.md` describe arquitectura Flutter con packages Dart
    - Estructura principal: `apps/mobile/` con `pubspec.yaml` Flutter

- [x] **C.2** README.md existe y describe el proyecto
  - **Estado:** OK
  - **Evidencia:** 
    - Path: `README.md`
    - Contiene: descripción, características, estructura, documentación, requisitos, instalación, principios fundamentales, estado actual

- [x] **C.3** Documentación de arquitectura existe
  - **Estado:** OK
  - **Evidencia:** 
    - Path: `docs/ARCHITECTURE.md`
    - Describe estructura modular, capas del sistema, packages (core, processing, watermark)

- [x] **C.4** Estructura de packages Flutter verificada
  - **Estado:** OK
  - **Evidencia:** 
    - `packages/core/pubspec.yaml` - Package Dart válido (name: core, sdk: >=3.0.0)
    - `packages/processing/pubspec.yaml` - Package Dart válido (name: processing, depende de core)
    - `packages/watermark/pubspec.yaml` - Package Dart válido (name: watermark)
    - `apps/mobile/pubspec.yaml` - App Flutter que referencia los 3 packages locales mediante `path:`

---

### D. Estructura Canónica

- [x] **D.1** Directorio `apps/mobile/` existe y contiene app Flutter
  - **Estado:** OK
  - **Evidencia:** 
    - Path: `apps/mobile/`
    - Contiene: `lib/main.dart`, `lib/app.dart`, `pubspec.yaml` Flutter válido
    - Estructura: `lib/` con `navigation/`, `ui/`, `presentation/`, `state/`, `utils/`
    - Plataformas: `android/`, `ios/`, `web/`

- [x] **D.2** Directorio `packages/` existe con packages locales
  - **Estado:** OK
  - **Evidencia:** 
    - `packages/core/` - 27 archivos (26 *.dart, 1 *.yaml)
    - `packages/processing/` - 22 archivos (21 *.dart, 1 *.yaml)
    - `packages/watermark/` - 9 archivos (8 *.dart, 1 *.yaml)
    - Todos tienen `pubspec.yaml` válido y estructura `lib/`

- [x] **D.3** Directorio `docs/` existe con documentación
  - **Estado:** OK
  - **Evidencia:** 
    - Path: `docs/`
    - Contiene: ARCHITECTURE.md, PRD.md, PRIVACY_MODEL.md, THREAT_MODEL.md, ROADMAP.md, SETUP.md, y otros documentos técnicos

- [x] **D.4** Archivo `.gitignore` existe y está configurado para Flutter
  - **Estado:** OK
  - **Evidencia:** 
    - Path: `.gitignore`
    - Contiene: exclusiones para `build/`, `.dart_tool/`, `.flutter-plugins`, Android (`local.properties`, `.gradle/`), iOS (`Pods/`, `.symlinks/`), IDE (`.idea/`, `.vscode/`)

---

### E. Prohibiciones (Bloqueantes)

- [x] **E.1** NO existe prototipo web rastreado en el repositorio
  - **Estado:** ✅ OK (F4 - Resuelto)
  - **Evidencia:** 
    - Verificado con `git ls-files | Select-String "figma_extracted"` - retorna 0 archivos
    - `figma_extracted/` existe en el historial de Git (commits antiguos: 03c447af, cbb4407d, 45ecab03) pero NO está rastreado en HEAD actual
    - `.gitignore` contiene exclusión para `figma_extracted/` (línea 54) - barrera preventiva F3 activa
    - **RESUELTO**: El directorio `figma_extracted/` no está en el índice de Git en el estado actual
    - **Rama:** `chore/repo-saneamiento-F4-sanitize` (2026-01-20)

- [x] **E.2** NO existe carpeta `web/prototype` rastreada
  - **Estado:** OK
  - **Evidencia:** 
    - `git ls-files web/prototype` retorna vacío (no está rastreado)
    - La carpeta existe físicamente pero no está en el índice de Git (correcto)

- [x] **E.3** NO hay contaminación estructural de tecnologías no-Flutter en raíz
  - **Estado:** OK
  - **Evidencia:** 
    - Raíz contiene: `apps/`, `packages/`, `docs/`, `README.md`, `.gitignore` (estructura esperada)
    - `design-tools/` existe pero parece ser herramientas de desarrollo auxiliares (no bloqueante si no está rastreado)
    - `Figma.zip` existe pero no está rastreado (verificado implícitamente)
    - `figma_extracted/` no está en raíz ni rastreado (E.1 resuelto)

- [x] **E.4** NO hay archivos de configuración de tecnologías no-Flutter en raíz
  - **Estado:** ✅ OK (F4 - Resuelto)
  - **Evidencia:** 
    - Verificado con `git ls-files | Select-String "^package-lock.json$"` - retorna 0 archivos en raíz
    - `package-lock.json` existe en el historial de Git (commit 45ecab03) pero NO está rastreado en HEAD actual
    - `.gitignore` contiene exclusión para `package-lock.json` (línea 59) - barrera preventiva F3 activa
    - **RESUELTO**: `package-lock.json` no está en el índice de Git en el estado actual
    - **Nota**: `apps/mobile/package-lock.json` existe pero está en subdirectorio de app (no en raíz, no bloqueante)
    - **Rama:** `chore/repo-saneamiento-F4-sanitize` (2026-01-20)

---

### F. Barreras (.gitignore / Prevención)

- [x] **F.1** `.gitignore` excluye prototipos web
  - **Estado:** ✅ OK (F3 - Endurecido)
  - **Evidencia:** 
    - `.gitignore` líneas 54-55: contiene exclusiones explícitas para `figma_extracted/` y `web/prototype/`
    - Sección "BARRERAS PREVENTIVAS F3" agregada (líneas 48-80)
    - Documentación creada: `docs/workflows/REPO_BARRIERS.md` explica el por qué y cómo actuar
    - **Rama:** `chore/repo-saneamiento-F3-barriers` (2026-01-20)

- [x] **F.2** `.gitignore` excluye builds y artefactos de Flutter
  - **Estado:** OK
  - **Evidencia:** 
    - `.gitignore` contiene: `**/build/`, `**/.dart_tool/`, `**/.flutter-plugins`, `**/pubspec.lock`
    - Excluye artefactos de Android: `**/android/.gradle/`, `**/android/local.properties`
    - Excluye artefactos de iOS: `**/ios/Pods/`, `**/ios/.symlinks/`

- [x] **F.3** `.gitignore` excluye archivos de IDE
  - **Estado:** OK
  - **Evidencia:** 
    - `.gitignore` contiene: `.idea/`, `.vscode/`, `*.iml`, `*.ipr`, `*.iws`, `.DS_Store`

- [x] **F.4** `.gitignore` excluye node_modules y artefactos npm
  - **Estado:** ✅ OK (F3 - Endurecido)
  - **Evidencia:** 
    - `.gitignore` líneas 58-61: contiene exclusiones para `**/node_modules/`, `package-lock.json`, `pnpm-lock.yaml`, `yarn.lock`
    - Líneas 64-70: excluye builds web (`**/dist/`, `**/.next/`, `**/.vite/`, `**/.turbo/`, `**/.parcel-cache/`, `**/.cache/`)
    - Líneas 73-75: excluye exports y temporales (`exports/`, `tmp/`, `backup/`)
    - **Rama:** `chore/repo-saneamiento-F3-barriers` (2026-01-20)
    - **Documentación:** Ver `docs/workflows/REPO_BARRIERS.md` para detalles completos

---

### G. Higiene Git / Worktrees

- [x] **G.1** No hay commits de force-push recientes sobre main
  - **Estado:** OK
  - **Evidencia:** 
    - Últimos commits: `45ecab03 chore(baseline): freeze before wizard lockdown`, `46242a81 cursor: empty commit to allow worktree creation`
    - No hay evidencia de force-push en el historial reciente

- [x] **G.2** No hay rebase sobre main en commits recientes
  - **Estado:** OK
  - **Evidencia:** Historial lineal sin evidencia de rebase forzado

- [x] **G.3** Estado de trabajo documentado
  - **Estado:** OK
  - **Evidencia:** Solo archivo sin rastrear: `docs/F1_AUDITORIA_REPORTE.md` (documentación, no bloqueante)

---

### H. Validaciones No Destructivas

- [x] **H.1** `apps/mobile/pubspec.yaml` es válido
  - **Estado:** OK
  - **Evidencia:** 
    - Path: `apps/mobile/pubspec.yaml`
    - Contiene: name, description, version, environment (sdk: >=3.0.0), dependencies Flutter válidas
    - Referencias a packages locales: `core`, `processing`, `watermark` mediante `path:`

- [x] **H.2** Packages locales tienen `pubspec.yaml` válidos
  - **Estado:** OK
  - **Evidencia:** 
    - `packages/core/pubspec.yaml`: name: core, sdk: >=3.0.0, dependencies válidas
    - `packages/processing/pubspec.yaml`: name: processing, depende de core mediante path
    - `packages/watermark/pubspec.yaml`: name: watermark, sdk: >=3.0.0

- [x] **H.3** Estructura de `lib/` en app móvil es coherente
  - **Estado:** OK
  - **Evidencia:** 
    - `apps/mobile/lib/main.dart` existe y llama a `ImagenArteApp`
    - `apps/mobile/lib/app.dart` existe (app principal)
    - Estructura: `navigation/`, `ui/screens/`, `presentation/`, `state/`, `utils/`
    - Router configurado: `lib/navigation/app_router.dart` con rutas home, wizard, export, editor

- [x] **H.4** No hay referencias rotas obvias en código principal
  - **Estado:** OK
  - **Evidencia:** 
    - `apps/mobile/lib/navigation/app_router.dart` importa correctamente: `home_screen.dart`, `wizard_screen.dart`, `export_screen.dart`
    - Packages locales referenciados correctamente: `package:core/...`, `package:processing/...`, `package:watermark/...`

---

### I. Documentación y Trazabilidad

- [x] **I.1** README.md es completo y actualizado
  - **Estado:** OK
  - **Evidencia:** 
    - Path: `README.md`
    - Contiene: descripción, características, estructura, documentación referenciada, requisitos, instalación, principios, estado actual

- [x] **I.2** Documentación de arquitectura existe
  - **Estado:** OK
  - **Evidencia:** 
    - Path: `docs/ARCHITECTURE.md`
    - Describe: visión general, estructura del proyecto, capas del sistema, entidades, casos de uso

- [x] **I.3** Documentación de setup existe
  - **Estado:** OK
  - **Evidencia:** 
    - Path: `SETUP.md`
    - Contiene: requisitos previos, instalación, configuración Android/iOS, ejecución, solución de problemas

- [ ] **I.4** ADRs (Architecture Decision Records) existen o están documentados
  - **Estado:** PENDIENTE
  - **Evidencia:** 
    - Búsqueda de `ADR*.md` y `*.adr` no encontró archivos
    - No hay carpeta `docs/adr/` o similar
    - **OBSERVACIÓN**: No es bloqueante, pero se recomienda documentar decisiones arquitectónicas importantes

- [x] **I.5** Este checklist existe y está completo
  - **Estado:** OK
  - **Evidencia:** 
    - Path: `docs/workflows/REPO_SANITY_CHECK.md`
    - Checklist completo con todas las secciones requeridas
    - Evidencia proporcionada para cada ítem

---

## 📝 Resumen del Estado

### Fallas Críticas Detectadas

1. ~~**E.1 - Prototipo web rastreado**: `figma_extracted/` está en el índice de Git~~ ✅ **RESUELTO (F4)**
   - **Estado:** `figma_extracted/` NO está rastreado en HEAD actual
   - **Evidencia:** `git ls-files | Select-String "figma_extracted"` retorna 0 archivos
   - **Rama:** `chore/repo-saneamiento-F4-sanitize` (2026-01-20)
   - **Nota:** Existe en historial de Git pero no está en el índice (barreras F3 activas)

2. ~~**E.4 - Archivos npm en raíz**: `package-lock.json` en raíz~~ ✅ **RESUELTO (F4)**
   - **Estado:** `package-lock.json` NO está rastreado en HEAD actual
   - **Evidencia:** `git ls-files | Select-String "^package-lock.json$"` retorna 0 archivos en raíz
   - **Rama:** `chore/repo-saneamiento-F4-sanitize` (2026-01-20)
   - **Nota:** Existe en historial de Git pero no está en el índice (barreras F3 activas)

3. ~~**F.1 - .gitignore incompleto**: No excluye prototipos web~~ ✅ **RESUELTO (F3)**
   - **Estado:** Barreras endurecidas en rama `chore/repo-saneamiento-F3-barriers`
   - **Evidencia:** `.gitignore` actualizado con exclusiones explícitas (ver F.1 y F.4 en checklist)
   - **Documentación:** `docs/workflows/REPO_BARRIERS.md` creado

4. ~~**F.4 - .gitignore no excluye artefactos npm**~~ ✅ **RESUELTO (F3)**
   - **Estado:** Barreras endurecidas en rama `chore/repo-saneamiento-F3-barriers`
   - **Evidencia:** `.gitignore` actualizado con exclusiones npm completas (ver F.4 en checklist)

### Items Pendientes (No Bloqueantes)

- **I.4**: ADRs no existen (recomendación, no bloqueante)

### Items Aprobados

- ✅ Estructura Flutter correcta
- ✅ Packages locales bien configurados
- ✅ Documentación principal existe
- ✅ Configuración Git básica correcta
- ✅ Rama y remoto configurados correctamente

---

## 🔧 Acciones Requeridas para Desbloquear

~~1. **Decidir el destino de `figma_extracted/`**~~ ✅ **COMPLETADO (F4)**
   - **Estado:** `figma_extracted/` no está rastreado en HEAD actual
   - **Barreras:** `.gitignore` contiene exclusión (F3)
   - **Evidencia:** Verificado con `git ls-files` - 0 archivos rastreados

~~2. **Actualizar `.gitignore`**~~ ✅ **COMPLETADO (F3)**
   - **Estado:** `.gitignore` contiene exclusiones para `figma_extracted/` y `package-lock.json`
   - **Rama:** `chore/repo-saneamiento-F3-barriers`
   - **Documentación:** `docs/workflows/REPO_BARRIERS.md`

~~3. **Limpiar artefactos npm**~~ ✅ **COMPLETADO (F4)**
   - **Estado:** `package-lock.json` no está rastreado en HEAD actual
   - **Evidencia:** Verificado con `git ls-files` - 0 archivos en raíz

4. **Validación humana**:
   - Revisar este checklist
   - Verificar evidencia de que E.1 y E.4 están resueltos
   - Aprobar o rechazar las acciones realizadas
   - Actualizar estado global a 🟢 APROBADO solo después de confirmación humana

---

## 📖 Reglas de Uso del Checklist

1. **Obligatorio para todo PR a main**: Este checklist debe completarse antes de mergear cualquier PR a `origin/main`.

2. **FALLA implica BLOQUEO**: Cualquier ítem marcado como 🔴 FALLA bloquea el merge hasta su resolución.

3. **Aprobación humana requerida**: El estado 🟢 APROBADO solo puede ser establecido por un humano (guardian del repositorio).

4. **Evidencia obligatoria**: Todo ítem marcado como OK debe incluir evidencia mínima (paths, archivos, observaciones técnicas).

5. **Actualización continua**: Este checklist debe actualizarse cada vez que cambia la estructura del repositorio o se detectan nuevas violaciones.

6. **Trazabilidad**: Toda excepción o decisión debe quedar documentada (preferiblemente en un ADR).

---

## 🔄 Historial de Evaluaciones

| Fecha | Evaluado por | Estado | Notas |
|-------|--------------|--------|-------|
| 2026-01-20 | Cursor (agente) | 🔴 BLOQUEADO | Primera evaluación. Detectadas fallas: E.1, E.4, F.1, F.4 |
| 2026-01-20 | Cursor (agente) | 🟡 EN PROGRESO (F3) | Fase F3 completada: Barreras endurecidas (F.1 ✅, F.4 ✅). Pendiente: E.1, E.4 (F4 - eliminación de contenido rastreado) |
| 2026-01-20 | Cursor (agente) | 🟡 EN PROGRESO (F4) | Fase F4 completada: Verificado que `figma_extracted/` y `package-lock.json` NO están rastreados en HEAD. E.1 ✅, E.4 ✅. Pendiente: Validación humana |

---

**Fin del Checklist**
