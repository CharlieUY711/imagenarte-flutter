#!/bin/bash
# Script opcional para levantar servidor local de diseño
# Unix/Mac/Linux

echo "========================================"
echo "Servidor Local de Diseño - Imagen@rte"
echo "========================================"
echo ""

# Verificar que estamos en el directorio correcto
if [ ! -d "apps/mobile/build/web" ]; then
    echo "[ERROR] No se encuentra apps/mobile/build/web"
    echo ""
    echo "Por favor, primero compila la app Flutter para web:"
    echo "  cd apps/mobile"
    echo "  flutter build web"
    echo ""
    exit 1
fi

echo "[INFO] Cambiando a directorio de build..."
cd apps/mobile/build/web

echo "[INFO] Levantando servidor en http://localhost:8080"
echo "[INFO] Presiona Ctrl+C para detener el servidor"
echo ""

# Intentar usar Python primero, luego npx serve
if command -v python3 &> /dev/null; then
    python3 -m http.server 8080
elif command -v python &> /dev/null; then
    python -m http.server 8080
elif command -v npx &> /dev/null; then
    npx serve -p 8080
else
    echo "[ERROR] No se encontró Python ni npx"
    echo "Por favor instala Python o Node.js"
    exit 1
fi
