# Auditoría de Estructura - imagenarte

Este directorio contiene archivos generados para auditoría de la estructura del proyecto imagenarte.

## Ubicación Canónica

**Regla canónica:** Toda la documentación de auditoría vive en `docs\AUDIT\<app-name>\`  
**Workspace raíz:** `C:\Users\cvara\Imagen@rte`  
**Ubicación actual:** `docs\AUDIT\imagenarte\`

Las apps NO contienen documentación de auditoría en `apps/<app>/docs`.

## Generar Árbol de Estructura

Para generar un árbol completo de la estructura de `lib/`, ejecutar desde el workspace raíz:

```powershell
tree apps\imagenarte\lib /F /A > docs\AUDIT\imagenarte\lib_tree.txt
```

O desde el directorio de la app:

```powershell
cd apps\imagenarte
tree lib /F /A > ..\..\docs\AUDIT\imagenarte\lib_tree.txt
```

## Archivos Generados

- `lib_tree.txt`: Árbol completo de la estructura de `lib/`
