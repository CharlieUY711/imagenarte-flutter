import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Icono de ajustes (icon-adjustments)
/// Tres sliders horizontales con perillas desfasadas
class AdjustmentsIcon extends StatelessWidget {
  final bool isActive;
  final bool isPressed;
  final Color? color;

  const AdjustmentsIcon({
    super.key,
    this.isActive = false,
    this.isPressed = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(20, 20),
      painter: _AdjustmentsIconPainter(
        isActive: isActive,
        isPressed: isPressed,
        color: color,
      ),
    );
  }
}

class _AdjustmentsIconPainter extends CustomPainter {
  final bool isActive;
  final bool isPressed;
  final Color? color;

  _AdjustmentsIconPainter({
    required this.isActive,
    required this.isPressed,
    this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Si se proporciona un color, usarlo para todo (para barra naranja)
    // Si no, usar los colores según estado
    final sliderColor = color ?? AppTokens.neutralMedium;
    final knobColor = color ?? (isActive ? AppTokens.accentOrange : AppTokens.neutralMedium);

    // Aplicar opacidad si está presionado
    final opacity = isPressed ? 0.85 : 1.0;

    // Espaciado vertical entre sliders: 4px
    // Tamaño base: 20x20px
    // Radio de perilla: 2.5px
    // Stroke: 1.5px

    final sliderLength = 16.0; // Longitud del slider
    final sliderStartX = (size.width - sliderLength) / 2;
    final knobRadius = 2.5;

    // Slider 1 (arriba) - perilla a la izquierda
    final slider1Y = 4.0;
    final knob1X = sliderStartX + 3.0; // Desfasado a la izquierda

    paint.color = sliderColor.withOpacity(opacity);
    canvas.drawLine(
      Offset(sliderStartX, slider1Y),
      Offset(sliderStartX + sliderLength, slider1Y),
      paint,
    );

    paint.color = knobColor.withOpacity(opacity);
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(knob1X, slider1Y), knobRadius, paint);

    // Slider 2 (centro) - perilla al centro
    final slider2Y = size.height / 2;
    final knob2X = sliderStartX + sliderLength / 2; // Centrado

    paint.color = sliderColor.withOpacity(opacity);
    paint.style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(sliderStartX, slider2Y),
      Offset(sliderStartX + sliderLength, slider2Y),
      paint,
    );

    paint.color = knobColor.withOpacity(opacity);
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(knob2X, slider2Y), knobRadius, paint);

    // Slider 3 (abajo) - perilla a la derecha
    final slider3Y = size.height - 4.0;
    final knob3X = sliderStartX + sliderLength - 3.0; // Desfasado a la derecha

    paint.color = sliderColor.withOpacity(opacity);
    paint.style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(sliderStartX, slider3Y),
      Offset(sliderStartX + sliderLength, slider3Y),
      paint,
    );

    paint.color = knobColor.withOpacity(opacity);
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(knob3X, slider3Y), knobRadius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is _AdjustmentsIconPainter) {
      return oldDelegate.isActive != isActive ||
          oldDelegate.isPressed != isPressed ||
          oldDelegate.color != color;
    }
    return true;
  }
}

/// Icono de presets de color (icon-color-presets)
/// Círculo dividido en dos mitades verticales
class ColorPresetsIcon extends StatelessWidget {
  final bool isActive;
  final bool isSelected;
  final Color? color;

  const ColorPresetsIcon({
    super.key,
    this.isActive = false,
    this.isSelected = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(20, 20),
      painter: _ColorPresetsIconPainter(
        isActive: isActive,
        isSelected: isSelected,
        color: color,
      ),
    );
  }
}

class _ColorPresetsIconPainter extends CustomPainter {
  final bool isActive;
  final bool isSelected;
  final Color? color;

  _ColorPresetsIconPainter({
    required this.isActive,
    required this.isSelected,
    this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1.0; // Dejar espacio para el stroke

    // Si se proporciona un color, usarlo para todo (para barra naranja)
    // Si no, usar los colores según estado
    final baseColor = color ?? AppTokens.neutralMedium;
    final inactiveColor = color ?? AppTokens.neutralMedium;
    final activeColor = color ?? AppTokens.accentOrange;

    // Mitad izquierda (color)
    final leftColor = color != null ? color! : (isActive ? activeColor : inactiveColor);
    // Mitad derecha (gris)
    final rightColor = color != null ? color! : inactiveColor;

    // Dibujar círculo completo con stroke
    paint.color = baseColor;
    paint.style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, paint);

    // Dibujar línea divisoria central
    paint.color = baseColor;
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );

    // Rellenar mitad izquierda
    paint.color = leftColor;
    paint.style = PaintingStyle.fill;
    final leftPath = Path()
      ..moveTo(center.dx, 0)
      ..lineTo(0, 0)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        -3.14159, // -180 grados
        3.14159, // 180 grados
        false,
      )
      ..lineTo(center.dx, size.height)
      ..close();
    canvas.drawPath(leftPath, paint);

    // Rellenar mitad derecha
    paint.color = rightColor;
    final rightPath = Path()
      ..moveTo(center.dx, 0)
      ..lineTo(size.width, 0)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        0, // 0 grados
        3.14159, // 180 grados
        false,
      )
      ..lineTo(center.dx, size.height)
      ..close();
    canvas.drawPath(rightPath, paint);

    // Si está seleccionado, dibujar anillo exterior fino (1px) en naranja
    if (isSelected && color == null) {
      paint.color = AppTokens.accentOrange;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 1.0;
      canvas.drawCircle(center, radius + 1.0, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is _ColorPresetsIconPainter) {
      return oldDelegate.isActive != isActive ||
          oldDelegate.isSelected != isSelected ||
          oldDelegate.color != color;
    }
    return true;
  }
}
