# Script para instalar Android SDK Command-line Tools
$ErrorActionPreference = "Stop"

$sdkPath = "$env:LOCALAPPDATA\Android\Sdk"
$cmdlineToolsPath = "$sdkPath\cmdline-tools\latest"
$zipPath = "$env:TEMP\android-commandlinetools.zip"
$url = "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip"

Write-Host "=== Instalacion de Android SDK Command-line Tools ===" -ForegroundColor Cyan
Write-Host ""

# Crear directorios necesarios
Write-Host "Creando directorios..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path $cmdlineToolsPath | Out-Null

# Descargar command-line tools
if (-not (Test-Path $zipPath)) {
    Write-Host "Descargando Android SDK Command-line Tools..." -ForegroundColor Yellow
    Write-Host "Esto puede tardar varios minutos dependiendo de tu conexion..." -ForegroundColor Gray
    try {
        Invoke-WebRequest -Uri $url -OutFile $zipPath -UseBasicParsing
        Write-Host "[OK] Descarga completada" -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] Error en la descarga: $_" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "[OK] Archivo ya descargado, usando el existente" -ForegroundColor Green
}

# Extraer
Write-Host "Extrayendo archivos..." -ForegroundColor Yellow
try {
    $tempExtract = "$env:TEMP\android-tools-temp"
    Remove-Item $tempExtract -Recurse -Force -ErrorAction SilentlyContinue
    Expand-Archive -Path $zipPath -DestinationPath $tempExtract -Force
    
    # La estructura puede ser cmdline-tools\* o directamente los archivos
    if (Test-Path "$tempExtract\cmdline-tools") {
        $sourcePath = Join-Path "$tempExtract\cmdline-tools" "*"
    } else {
        $sourcePath = Join-Path $tempExtract "*"
    }
    
    Move-Item -Path $sourcePath -Destination $cmdlineToolsPath -Force -ErrorAction Stop
    Remove-Item -Path $tempExtract -Recurse -Force
    Write-Host "[OK] Extraccion completada" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Error al extraer: $_" -ForegroundColor Red
    Write-Host "Intentando estructura alternativa..." -ForegroundColor Yellow
    # Intentar estructura alternativa: los archivos están directamente en la raíz
    try {
        $tempExtract = "$env:TEMP\android-tools-temp"
        Get-ChildItem $tempExtract -Recurse | Where-Object { -not $_.PSIsContainer } | ForEach-Object {
            $relativePath = $_.FullName.Substring($tempExtract.Length + 1)
            $destPath = Join-Path $cmdlineToolsPath $relativePath
            $destDir = Split-Path $destPath -Parent
            New-Item -ItemType Directory -Force -Path $destDir | Out-Null
            Copy-Item $_.FullName -Destination $destPath -Force
        }
        Remove-Item -Path $tempExtract -Recurse -Force
        Write-Host "[OK] Extraccion completada (estructura alternativa)" -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] No se pudo extraer el archivo" -ForegroundColor Red
        exit 1
    }
}

# Configurar variables de entorno
Write-Host "Configurando variables de entorno..." -ForegroundColor Yellow
$env:ANDROID_HOME = $sdkPath
$binPath = Join-Path $cmdlineToolsPath "bin"
$platformToolsPath = Join-Path $sdkPath "platform-tools"
$env:PATH = "$binPath;$platformToolsPath;$env:PATH"

# Aceptar licencias y instalar componentes basicos
Write-Host "Instalando componentes del SDK..." -ForegroundColor Yellow
Write-Host "Esto puede tardar varios minutos..." -ForegroundColor Gray

$components = @(
    "platform-tools",
    "build-tools;34.0.0",
    "platforms;android-34"
)

$sdkmanagerPath = Join-Path $binPath "sdkmanager.bat"

foreach ($component in $components) {
    Write-Host "Instalando $component..." -ForegroundColor Gray
    & $sdkmanagerPath $component --sdk_root=$sdkPath 2>&1 | Out-Null
}

# Aceptar todas las licencias
Write-Host "Aceptando licencias..." -ForegroundColor Yellow
echo y | & $sdkmanagerPath --licenses --sdk_root=$sdkPath 2>&1 | Out-Null
echo y | & $sdkmanagerPath --licenses --sdk_root=$sdkPath 2>&1 | Out-Null
echo y | & $sdkmanagerPath --licenses --sdk_root=$sdkPath 2>&1 | Out-Null

Write-Host ""
Write-Host "=== Instalacion completada ===" -ForegroundColor Green
Write-Host "SDK instalado en: $sdkPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "Ejecuta 'flutter doctor' para verificar la instalacion" -ForegroundColor Yellow
