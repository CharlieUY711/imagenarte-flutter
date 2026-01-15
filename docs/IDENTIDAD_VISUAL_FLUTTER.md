# Identidad Visual - Imagen@rte (Flutter)

**Fuente:** `figma_extracted/IDENTIDAD_VISUAL.md`  
**Adaptado para:** Flutter/Dart  
**Fecha:** 2026-01-13

---

## 🎯 Concepto del Motivo

El motivo de identidad se basa en:
- **Arcos parciales** (nunca círculos completos)
- **Eje diagonal dominante** (~45° desde vertical, equivalente a 14:45 en reloj)
- **Sutil y no intrusivo** (opacidad 3-8%)
- **Progresión incompleta** (máximo 240° de 360°)

**Significado:**
- **Incompleto:** Refleja la naturaleza continua del tratamiento de imágenes
- **Diagonal:** Movimiento, dinamismo sin agresividad
- **"@":** Centro de identidad digital, sin representarlo literalmente

---

## ✅ Implementación en Flutter

### 1. Componente RadialMotif

**Ubicación sugerida:** `apps/mobile/lib/presentation/widgets/radial_motif.dart`

**Tres variantes:**

#### a) Background (`variant="background"`)
- **Uso:** Fondos sutiles en Home
- **Opacidad:** 3%
- **Forma:** Dos arcos parciales diagonales (superior derecha + inferior izquierda)
- **Efecto:** Enmarca el contenido sin distraer

```dart
RadialMotif(
  variant: RadialMotifVariant.background,
  color: Theme.of(context).colorScheme.onBackground,
)
```

#### b) Loading (`variant="loading"`)
- **Uso:** Estados de carga (ImagePreview, Button)
- **Forma:** Arco parcial de ~120° que rota
- **Efecto:** Indica procesamiento sin spinner circular completo

```dart
RadialMotif(
  variant: RadialMotifVariant.loading,
  color: Theme.of(context).colorScheme.primary,
)
```

#### c) Progress (`variant="progress"`)
- **Uso:** Stepper del Wizard (Paso X de 3)
- **Forma:** Arco que progresa de 0° a 240° (nunca completo)
- **Inicio:** Diagonal superior izquierda (-135°)
- **Efecto:** Visualiza progreso del flujo

```dart
RadialMotif(
  variant: RadialMotifVariant.progress,
  progress: 33, // 0-100
  color: Theme.of(context).colorScheme.primary,
)
```

---

## 📍 Ubicaciones de Uso Recomendadas

### ✅ Implementar

| Pantalla/Componente | Variante | Propósito |
|---------------------|----------|-----------|
| **Home** | `background` | Fondo sutil con arcos diagonales |
| **Stepper** | `progress` | Indicador visual de progreso del wizard |
| **ImagePreview** (loading) | `loading` | Indicador de carga de imagen |
| **Button** (isLoading) | `loading` | Indicador de procesamiento |

### ❌ NO Implementar (por diseño)

- ~~Estados de error~~ → No usar motivo en contextos negativos
- ~~Toggles/Sliders~~ → No aplicar a UI funcional
- ~~Branding repetitivo~~ → No convertir en logo omnipresente
- ~~Decoraciones constantes~~ → No agregar por "llenar espacio"

---

## 🎨 Parámetros Técnicos

### Opacidad
```dart
background: 0.03 (3%)
loading: 1.0 (100% del color primario)
progress: 1.0 (100% del color primario)
```

### Ángulos
```
Inicio del arco de progreso: -135° (diagonal superior izquierda)
Máximo completado: 240° (2/3 del círculo)
Rotación del loading: continua (AnimationController)
```

### Colores
```dart
// Siempre usa el color del contexto
color: Theme.of(context).colorScheme.onBackground  // Para background
color: Theme.of(context).colorScheme.primary       // Para loading/progress
```

### Tamaños
```dart
loading: 32.0 (puede escalarse)
progress: 32.0
background: 100% del contenedor (responsive)
```

---

## 📐 Geometría del Motivo

### Arco Parcial de Progreso

```
     ╱
    ●    ← Inicio (-135°)
   ╱ ╲
  ╱   ╲
 ╱     ╲
╱       ╲   ← Progreso 33% (80°)
         ╲
          ●

Progreso 100% alcanza ~105° (240° de arco)
```

### Background Diagonal

```
Pantalla (390x844)

    ╱
   ╱  (arco superior)
  ╱
 ╱
╱

        ╲
         ╲  (arco inferior, reflejo diagonal)
          ╲
           ╲
```

---

## 🚫 Reglas Estrictas

### NO HACER

1. **NO dibujar relojes literales**
   - ❌ No agregar números (12, 3, 6, 9)
   - ❌ No dibujar agujas
   - ❌ No usar marcas horarias

2. **NO usar círculos completos**
   - ❌ Spinners circulares completos
   - ❌ Loaders con 360° de rotación
   - ❌ Anillos cerrados

3. **NO convertir en logo**
   - ❌ No poner en header/footer constantemente
   - ❌ No usar como ícono de la app
   - ❌ No hacer branding explícito

4. **NO aplicar a UI funcional**
   - ❌ Botones (excepto loading state)
   - ❌ Toggles/Switches
   - ❌ Sliders
   - ❌ Dropdowns

5. **NO usar en contextos negativos**
   - ❌ Estados de error
   - ❌ Alertas
   - ❌ Validaciones fallidas

### SÍ HACER

1. **Usar para feedback sutil**
   - ✅ Indicar progreso del wizard
   - ✅ Mostrar carga/procesamiento
   - ✅ Enmarcar contenido importante

2. **Mantener opacidad baja en backgrounds**
   - ✅ 3-8% en fondos estáticos
   - ✅ 100% en indicadores activos (loading/progress)

3. **Respetar el eje diagonal**
   - ✅ Inicio a -135° (diagonal superior izquierda)
   - ✅ Movimiento en sentido horario
   - ✅ Nunca vertical (0°) ni horizontal (90°)

4. **Aplicar criterio de distracción**
   - ✅ Si distrae → eliminar
   - ✅ Si no aporta → eliminar
   - ✅ Si confunde → eliminar

---

## 💻 Implementación en Flutter

### Ejemplo de Widget RadialMotif

```dart
enum RadialMotifVariant { background, loading, progress }

class RadialMotif extends StatefulWidget {
  final RadialMotifVariant variant;
  final double? progress; // 0-100 para variant 'progress'
  final Color color;
  final double? size; // Para loading y progress

  const RadialMotif({
    Key? key,
    required this.variant,
    this.progress,
    required this.color,
    this.size,
  }) : super(key: key);

  @override
  State<RadialMotif> createState() => _RadialMotifState();
}

class _RadialMotifState extends State<RadialMotif>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    if (widget.variant == RadialMotifVariant.loading) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 1),
      )..repeat();
    }
  }

  @override
  void dispose() {
    if (widget.variant == RadialMotifVariant.loading) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.variant) {
      case RadialMotifVariant.background:
        return _buildBackground();
      case RadialMotifVariant.loading:
        return _buildLoading();
      case RadialMotifVariant.progress:
        return _buildProgress();
    }
  }

  Widget _buildBackground() {
    return CustomPaint(
      painter: RadialBackgroundPainter(color: widget.color),
      size: Size.infinite,
    );
  }

  Widget _buildLoading() {
    final size = widget.size ?? 32.0;
    return RotationTransition(
      turns: _controller,
      child: CustomPaint(
        painter: RadialLoadingPainter(color: widget.color),
        size: Size.square(size),
      ),
    );
  }

  Widget _buildProgress() {
    final size = widget.size ?? 32.0;
    final progress = widget.progress ?? 0.0;
    return CustomPaint(
      painter: RadialProgressPainter(
        color: widget.color,
        progress: progress,
      ),
      size: Size.square(size),
    );
  }
}
```

### CustomPaint para Background

```dart
class RadialBackgroundPainter extends CustomPainter {
  final Color color;

  RadialBackgroundPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Arco superior derecha
    final rect1 = Rect.fromLTWH(-200, -200, size.width + 400, size.height + 400);
    canvas.drawArc(rect1, 0, 1.5, false, paint);

    // Arco inferior izquierda
    final rect2 = Rect.fromLTWH(-200, size.height - 200, size.width + 400, size.height + 400);
    canvas.drawArc(rect2, 3.14, 1.5, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

### CustomPaint para Loading

```dart
class RadialLoadingPainter extends CustomPainter {
  final Color color;

  RadialLoadingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    // Arco parcial de ~120° alineado diagonalmente
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -2.36, // -135° en radianes
      2.09,  // 120° en radianes
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

### CustomPaint para Progress

```dart
class RadialProgressPainter extends CustomPainter {
  final Color color;
  final double progress; // 0-100

  RadialProgressPainter({
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    // Arco de fondo (completo al 100%)
    final backgroundPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Arco de progreso
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

      final angle = (progress / 100) * 240; // Máximo 240°
      final startAngle = -2.36; // -135° en radianes
      final sweepAngle = (angle * pi) / 180;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant RadialProgressPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
```

---

## 🧪 Testing del Motivo

### Validar que:

- [ ] El background en Home NO distrae del contenido
- [ ] El stepper se entiende como indicador de progreso
- [ ] El loading NO se confunde con un error
- [ ] El motivo NO se interpreta como un reloj
- [ ] El motivo NO se siente como "decoración innecesaria"

### Preguntas para testers:

1. ¿Notaste el diseño del indicador de progreso?
2. ¿Te pareció útil o decorativo?
3. ¿Lo asociaste con algún concepto (reloj, carga, otro)?
4. ¿El background en Home te distrajo?
5. ¿Preferirías que no estuviera?

**Criterio de decisión:**
- Si >30% de testers lo encuentran distractivo → eliminar background
- Si >50% no entienden el progreso visual → volver a texto simple
- Si >20% lo asocian con "reloj" → rediseñar ángulos

---

## 🎯 Filosofía del Motivo

### Principios

**Minimalismo:**
> "El motivo debe ser descubrible, no evidente."

**Funcionalidad:**
> "Si no cumple una función, no debe existir."

**Sutileza:**
> "Debe aportar coherencia, no identidad ostentosa."

**Honestidad:**
> "No es un logo. Es un lenguaje visual interno."

---

## 📊 Casos de Uso Futuros

### Pueden agregarse:

1. **Splash screen**
   - Arco que completa 240° al cargar
   - Transición diagonal de opacidad

2. **Procesamiento de imagen**
   - Arco de progreso durante detección de rostros
   - Indicador de procesamiento ML

3. **Exportación**
   - Arco de progreso durante compresión/exportación
   - Feedback visual de completado

4. **Onboarding (si se agrega)**
   - Stepper con arcos para pasos del tutorial
   - Transiciones diagonales entre pantallas

### NO deben agregarse:

- ❌ Animaciones de celebración con confetti radial
- ❌ Transiciones circulares completas entre pantallas
- ❌ Elementos decorativos en pantallas de error
- ❌ Branding en cada pantalla

---

## ✅ Checklist de Implementación

Al agregar el motivo a nuevas pantallas:

- [ ] ¿Cumple una función (indicar progreso/carga)?
- [ ] ¿Es sutil y no distrae?
- [ ] ¿Respeta el eje diagonal?
- [ ] ¿NO es un círculo completo?
- [ ] ¿NO se parece a un reloj literal?
- [ ] ¿NO se usa como logo/branding?
- [ ] ¿Mejora la experiencia o es decorativo?

**Si respondiste "solo decorativo" → NO agregarlo.**

---

**Última actualización:** 2026-01-13  
**Estado:** 📋 Documentación lista para implementación  
**Próximo paso:** Crear widget `RadialMotif` en Flutter
