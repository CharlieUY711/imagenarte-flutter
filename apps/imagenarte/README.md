# imagenarte

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Regla Canónica: Reset Total de Herramientas

**Tool sessions are stateless across activations.**

Cuando el usuario sale de una herramienta (cambiar a otra, ESC, click fuera, navegación), la herramienta se resetea completamente:
- Estado transitorio se vacía (selecciones temporales, máscaras, buffers, previews)
- Parámetros no confirmados vuelven a default (sliders, dials)
- Cache/buffers internos se limpian
- Timers/listeners se cancelan

La próxima vez que se active la herramienta, entra como nueva (estado default). Esto NO afecta cambios ya aplicados al documento ni el historial/undo global.