# Herramienta "Metadatos" - Eliminación de Metadatos

## Descripción

La herramienta "Metadatos" permite eliminar todos los metadatos (EXIF, XMP, IPTC) de las imágenes antes de exportarlas. Esta funcionalidad es útil para proteger la privacidad y reducir el tamaño de los archivos.

## Funcionalidad

### Características

- **Eliminación completa de metadatos**: Elimina EXIF, XMP e IPTC
- **Procesamiento local**: Todo el procesamiento se realiza en el dispositivo, sin conexión a internet
- **Preservación de apariencia**: La imagen exportada se ve idéntica a la original, pero sin metadatos
- **Orientación correcta**: Si la imagen original tiene orientación EXIF, se "hornea" (bake) en los píxeles para mantener la orientación visual correcta

### Formatos soportados

- **JPEG/JPEG**: Elimina segmentos APP1 (EXIF) y APP13 (IPTC), y datos XMP
- **PNG**: Elimina chunks textuales (tEXt, zTXt, iTXt) y perfiles no esenciales
- **WebP**: Elimina chunks de metadatos XMP/EXIF

## Uso

### Interfaz de usuario

1. **Acceder a la herramienta**: Toca el icono "Metadatos" en la barra de herramientas
2. **Ver estado actual**: El overlay muestra:
   - Toggle ON/OFF para "Eliminar metadatos" (por defecto ON)
   - Resumen de metadatos detectados (EXIF, XMP, IPTC)
3. **Configurar**: Toca el toggle para activar/desactivar la eliminación
4. **Exportar**: Al guardar/exportar la imagen, se aplicará la configuración seleccionada

### Comportamiento por defecto

- **Por defecto**: La eliminación de metadatos está **activada** (ON)
- **Al exportar con ON**: La imagen se guarda sin metadatos
- **Al exportar con OFF**: La imagen se guarda con los metadatos originales (si existían)

## Implementación técnica

### Arquitectura

La implementación sigue la arquitectura por capas del proyecto:

```
domain/services/metadata_stripper.dart       # Interfaz abstracta
application/usecases/export_image_usecase.dart  # Caso de uso
infrastructure/imaging/
  ├── metadata_stripper_impl.dart          # Implementación
  └── image_export_helper.dart              # Helper para exportación
```

### Flujo de procesamiento

1. **Decodificación**: La imagen se decodifica usando el codec de Flutter (respeta orientación EXIF)
2. **Normalización**: Se convierte a formato de píxeles (img.Image)
3. **Re-encodificación**: Se codifica de nuevo sin copiar metadatos
4. **Guardado**: Se guarda el archivo limpio

### Detección de metadatos

La detección busca:

- **EXIF**: Segmentos APP1 (0xFFE1) que contienen "Exif" o "EXIF"
- **XMP**: Strings que contienen "http://ns.adobe.com/xap/1.0/" o "xpacket"
- **IPTC**: 
  - En JPEG: Segmentos APP13 (0xFFED) con "Photoshop", "8BIM" o "IPTC"
  - En PNG: Chunks tEXt/zTXt/iTXt que contienen "IPTC"

### Verificación

Los tests verifican:

1. **Eliminación efectiva**: El output no contiene marcadores de metadatos
2. **Preservación de apariencia**: Las dimensiones y el contenido visual se mantienen
3. **Orientación correcta**: Las imágenes rotadas se muestran correctamente tras el procesamiento

## Limitaciones conocidas

- **Calidad**: La re-encodificación puede causar una ligera pérdida de calidad en JPEG (depende del nivel de compresión)
- **Performance**: El procesamiento puede tomar unos segundos en imágenes muy grandes
- **Fallback**: Si el stripping falla, se guarda la imagen original con un warning en el log (no se bloquea el export)

## Tests

Los tests se encuentran en `test/metadata_stripper_test.dart` y verifican:

- Detección de metadatos
- Eliminación de metadatos en JPEG y PNG
- Preservación de dimensiones

## Referencias

- [EXIF Specification](https://www.exif.org/Exif2-2.PDF)
- [XMP Specification](https://www.adobe.com/devnet/xmp.html)
- [IPTC Standard](https://iptc.org/standards/photo-metadata/)
