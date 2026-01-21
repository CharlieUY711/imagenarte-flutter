# UI_CONTRACT.md
## Imagen@rte — Contrato Canónico de Barras y Layout

Este documento define las reglas **inamovibles** de la UI del sistema Imagen@rte.
Todo lo aquí descrito es **preestablecido por defecto** y NO debe redefinirse en cada desarrollo,
salvo que se indique explícitamente una excepción.

---

## 1. Principios Generales

- Todas las barras:
  - son **horizontales**
  - ocupan **el ancho máximo de la pantalla**
  - son **inamovibles**
  - tienen **un solo renglón** (NUNCA dos)
  - el contenido va **siempre centrado verticalmente**
- TopBar / InfoBar / MainBar son inamovibles ante cualquier circunstancia (teclado, insets, safe area, rotación u overlays). Nunca se desplazan ni cambian su altura o posición. Cualquier elemento del sistema debe superponerse o afectar solo áreas NO fijas.
- Nunca:
  - hacen wrap
  - cambian su altura
  - se desplazan
  - se superponen con el área de previsualización

---

## 2. Estructura Vertical Global

De arriba hacia abajo:

1. **TopBar**
   - Comienza inmediatamente después del área de información del sistema del celular
     (status bar / notch / sistema operativo).
2. **InfoBar**
   - Comienza inmediatamente después de la TopBar (ambas contiguas).
3. **Área de Previsualización**
   - Ocupa el espacio entre InfoBar y MainBar.
4. **MainBar**
   - Su borde superior se posiciona exactamente al **75% de la altura total de la pantalla**,
     medida desde el borde superior del dispositivo.

---

## 3. Área de Previsualización

- Queda siempre definida **entre las barras**.
- Ocupa:
  - **100% del ancho** de la pantalla
  - altura dinámica según el dispositivo
- No mueve ni modifica las barras.

---

## 4. TopBar (Barra Superior Global)

### Iconos extremos
- **Home**:
  - el borde izquierdo del icono termina a **15px** del borde izquierdo.
- **Save (disco)**:
  - el borde derecho del icono termina a **15px** del borde derecho.

### Divisores verticales (invisibles)
Los divisores son siempre del **mismo color que la barra**.

- Divisor 1: **40px** desde la izquierda
- Divisor 2: **50%** del ancho total
- Divisor 3: **75%** del ancho total
- Divisor 4: **40px** desde la derecha

### Campos
- **Campo 1**: entre Divisor 1 y Divisor 2
- **Campo 2**: entre Divisor 2 y Divisor 3
- **Campo 3**: entre Divisor 3 y Divisor 4

Convención de desarrollo:
> "Colocar X en Campo 2 de TopBar".

---

## 5. InfoBar (Barra Contextual)

La InfoBar tiene dos configuraciones excluyentes.

### 5.1 InfoBarData
- Usa exactamente la **misma grilla** que TopBar:
  - mismos divisores
  - mismos Campos 1 / 2 / 3
- Uso: información contextual, datos, estado.

Convención:
> "Mostrar X en Campo 1 de InfoBarData".

### 5.2 InfoBarHelp
- Barra de mensajes, tips y soporte.
- Mensajes:
  - circulan **de derecha a izquierda**
  - dentro del área delimitada por:
    - **40px desde la izquierda**
    - **40px desde la derecha**
- InfoBarHelp implementa un ticker horizontal continuo de derecha a izquierda, acotado entre 40px del borde izquierdo y 40px del borde derecho.
- No utiliza Campos como layout principal.
- Un solo renglón, centrado verticalmente.

---

## 6. MainBar (Barra Inferior de Controles)

### Posición
- Fija.
- El borde superior se ubica al **75% de la altura total de la pantalla**.

### Iconos extremos
- Primer icono:
  - comienza a **15px** del borde izquierdo.
- Último icono:
  - termina a **15px** del borde derecho.

### Uso
- Controles de la herramienta activa.
- Puede tener divisores:
  - si existen → siempre del **mismo color que la barra**.

---

## 7. Colores Canónicos de Barras

Las barras solo pueden usar estas combinaciones:

- **Barra Naranja** → texto **Blanco**
- **Barra Blanca** → texto **Naranja**
- **Barra Negra** → texto **Naranja**

### Regla implícita
- El color del texto y de los divisores se asigna automáticamente
  según el color de la barra.
- No se especifica manualmente en cada uso.

Solo se rompe esta regla si se indica explícitamente lo contrario.

---

## 8. Regla de Oro

- Cambiar el color de una barra **NO requiere** redefinir texto ni divisores.
- Ninguna barra cambia de tamaño, posición ni cantidad de renglones.
- Las barras son infraestructura de UI, no contenido libre.

---
