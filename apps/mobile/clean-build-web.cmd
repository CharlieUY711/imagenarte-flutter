@echo off
echo Limpiando build de Flutter Web...
cd /d "%~dp0"

echo Eliminando directorio build/web...
if exist build\web rmdir /s /q build\web

echo Eliminando .dart_tool...
if exist .dart_tool rmdir /s /q .dart_tool

echo Limpiando cache de Flutter...
flutter clean

echo Obteniendo dependencias...
flutter pub get

echo Build limpio completado. Ahora ejecuta: flutter build web
