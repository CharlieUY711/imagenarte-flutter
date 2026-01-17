# FASE 1 - Build Android Release Baseline (SIN R8)

**Fecha:** 2026-01-15  
**Objetivo:** Lograr `flutter build appbundle --release` sin errores (baseline sin R8)  
**Estado:** ⚠️ **BLOQUEADO - Android SDK no instalado**

---

## Cambios Realizados

### 1. Configuración Android SDK
**Archivo modificado:** `apps/mobile/android/local.properties`

**Cambio:**
```properties
flutter.sdk=C:\\Users\\cvara\\flutter\\flutter
sdk.dir=C:\\Users\\cvara\\AppData\\Local\\Android\\Sdk
```

**Razón:** Configurar ruta del Android SDK para que Gradle pueda encontrarlo.

**Nota:** El SDK no está instalado en esta ruta. Requiere:
- Instalar Android Studio o Android SDK Command Line Tools
- O ajustar `sdk.dir` en `local.properties` si el SDK está en otra ubicación

### 2. Desactivar R8/ProGuard (Baseline)
**Archivo modificado:** `apps/mobile/android/app/build.gradle`

**Cambio:**
```gradle
buildTypes {
    release {
        signingConfig signingConfigs.debug
        minifyEnabled false      // Cambiado de true a false
        shrinkResources false    // Cambiado de true a false
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
    }
}
```

**Razón:** Crear build baseline sin optimizaciones R8 para identificar problemas de código vs problemas de minify.

---

## Comandos Ejecutados

### 1. Flutter Clean
```bash
cd apps/mobile
flutter clean
```
**Resultado:** ✅ Completado
```
Deleting build...
Deleting .dart_tool...
Deleting ephemeral...
```

### 2. Flutter Pub Get
```bash
flutter pub get
```
**Resultado:** ✅ Completado
```
Resolving dependencies...
Got dependencies!
13 packages have newer versions incompatible with dependency constraints.
```

### 3. Flutter Build AppBundle Release
```bash
flutter build appbundle --release -v
```
**Resultado:** ❌ **FALLO**
```
[!] No Android SDK found. Try setting the ANDROID_HOME environment variable.
```

**Error completo:**
```
[ +310 ms] Unable to locate an Android SDK.
...
[!] No Android SDK found. Try setting the ANDROID_HOME environment variable.
```

---

## Lista de Archivos Modificados

| Archivo | Tipo | Cambio |
|---------|------|--------|
| `apps/mobile/android/local.properties` | ✅ Modificado | Agregado `sdk.dir=C:\\Users\\cvara\\AppData\\Local\\Android\\Sdk` |
| `apps/mobile/android/app/build.gradle` | ✅ Modificado | `minifyEnabled false`, `shrinkResources false` |

**Total:** 2 archivos modificados

---

## Estado Actual

### Bloqueador Principal
**Android SDK no instalado**

La ruta configurada en `local.properties` (`C:\Users\cvara\AppData\Local\Android\Sdk`) no existe.

**Verificación:**
```powershell
Test-Path "C:\Users\cvara\AppData\Local\Android\Sdk"
# Resultado: False
```

### Solución Requerida

**Opción 1: Instalar Android SDK**
1. Instalar Android Studio desde: https://developer.android.com/studio
2. O instalar solo Android SDK Command Line Tools
3. El SDK se instalará típicamente en: `%LOCALAPPDATA%\Android\Sdk`

**Opción 2: Si SDK está en otra ubicación**
1. Localizar la ruta del Android SDK
2. Actualizar `sdk.dir` en `apps/mobile/android/local.properties` con la ruta correcta

**Opción 3: Usar Flutter Config**
```bash
flutter config --android-sdk <ruta-del-sdk>
```

---

## Próximos Pasos

Una vez que el Android SDK esté instalado/configurado:

1. **Verificar SDK:**
   ```bash
   flutter doctor -v
   # Debe mostrar: [√] Android toolchain
   ```

2. **Reintentar Build:**
   ```bash
   cd apps/mobile
   flutter clean
   flutter pub get
   flutter build appbundle --release -v
   ```

3. **Si Build Exitoso:**
   - Verificar que el archivo `.aab` se generó en `build/app/outputs/bundle/release/`
   - Log final debe mostrar: `✓ Built build/app/outputs/bundle/release/app-release.aab`

4. **Si Build Falla:**
   - Revisar logs de Gradle para identificar error específico
   - Aplicar fix mínimo según el error

---

## Log Final del Build

**Estado:** ❌ **NO COMPLETADO** - Bloqueado por falta de Android SDK

**Log esperado (cuando SDK esté disponible):**
```
Running Gradle task 'bundleRelease'...
...
✓ Built build/app/outputs/bundle/release/app-release.aab (XX.XMB)
```

---

## Notas

- **Configuración Baseline:** R8/ProGuard desactivado para build baseline
- **Archivo ProGuard:** Se mantiene `proguard-rules.pro` pero no se usa (minifyEnabled false)
- **iOS Safety:** ✅ Cambios solo afectan Android, no iOS
- **Cambios Mínimos:** Solo 2 archivos modificados, sin features ni refactors

---

**Generado por:** Auto (AI Assistant)  
**Fecha:** 2026-01-15
