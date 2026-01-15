@echo off
REM Script opcional para levantar servidor local de diseño
REM Windows - PowerShell/CMD

echo ========================================
echo Servidor Local de Diseño - Imagen@rte
echo ========================================
echo.

REM Verificar que estamos en el directorio correcto
if not exist "apps\mobile\build\web" (
    echo [ERROR] No se encuentra apps\mobile\build\web
    echo.
    echo Por favor, primero compila la app Flutter para web:
    echo   cd apps\mobile
    echo   flutter build web
    echo.
    pause
    exit /b 1
)

echo [INFO] Cambiando a directorio de build...
cd apps\mobile\build\web

echo.
echo ========================================
echo Servidor iniciado correctamente
echo ========================================
echo.
echo [INFO] URL del servidor: http://localhost:8080
echo.
echo [INFO] Para ver la app en el Mobile Frame:
echo       1. Abre design-tools\mobile-frame\mobile-frame.html
echo       2. Ajusta APP_URL a http://localhost:8080 si es necesario
echo.
echo [INFO] Presiona Ctrl+C para detener el servidor
echo.
echo ========================================
echo.

REM Intentar usar Python primero
python -m http.server 8080 2>nul
if %errorlevel% neq 0 (
    echo [INFO] Python no encontrado. Intentando con npx serve...
    echo.
    npx serve -p 8080
    if %errorlevel% neq 0 (
        echo.
        echo [ERROR] No se encontró Python ni npx
        echo Por favor instala Python o Node.js
        echo.
        pause
        exit /b 1
    )
)
