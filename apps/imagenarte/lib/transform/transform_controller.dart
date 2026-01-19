import 'package:flutter/material.dart';
import 'package:imagenarte/transform/transform_model.dart';

/// Controlador para gestionar transformaciones de items
/// 
/// Maneja selección, transformaciones y callbacks para undo/historial.
class TransformController extends ChangeNotifier {
  final List<TransformableItem> _items = [];
  String? _selectedItemId;
  TransformHandlesConfig _handlesConfig = const TransformHandlesConfig();

  /// Callback cuando cambia una transformación (durante drag, sin commit undo)
  final ValueChanged<TransformableItem>? onTransformChanged;
  
  /// Callback cuando se commitea una transformación (al soltar, con commit undo)
  final ValueChanged<TransformableItem>? onTransformCommitted;

  TransformController({
    this.onTransformChanged,
    this.onTransformCommitted,
  });

  /// Lista de items transformables
  List<TransformableItem> get items => List.unmodifiable(_items);
  
  /// Item seleccionado actualmente
  TransformableItem? get selectedItem {
    if (_selectedItemId == null) return null;
    try {
      return _items.firstWhere((item) => item.id == _selectedItemId);
    } catch (e) {
      return null;
    }
  }
  
  /// Configuración de handles
  TransformHandlesConfig get handlesConfig => _handlesConfig;

  /// Agrega un item transformable
  void addItem(TransformableItem item) {
    _items.add(item);
    notifyListeners();
  }

  /// Elimina un item
  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    if (_selectedItemId == id) {
      _selectedItemId = null;
    }
    notifyListeners();
  }

  /// Actualiza un item existente
  void updateItem(TransformableItem item) {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index >= 0) {
      _items[index] = item;
      notifyListeners();
    }
  }

  /// Selecciona un item por ID
  void selectItem(String? id) {
    if (id == null) {
      _selectedItemId = null;
      // Deseleccionar todos
      for (int i = 0; i < _items.length; i++) {
        _items[i] = _items[i].copyWith(isSelected: false);
      }
      notifyListeners();
      return;
    }

    // Deseleccionar todos
    for (int i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(isSelected: false);
    }
    
    // Seleccionar el nuevo
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(isSelected: true);
      _selectedItemId = id;
    }
    notifyListeners();
  }

  /// Actualiza la transformación de un item (durante drag, sin commit)
  void updateTransform(String id, Transform2D transform) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      final updatedItem = _items[index].copyWith(transform: transform);
      _items[index] = updatedItem;
      onTransformChanged?.call(updatedItem);
      notifyListeners();
    }
  }

  /// Commitea la transformación de un item (al soltar, con commit undo)
  void commitTransform(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      onTransformCommitted?.call(_items[index]);
    }
  }

  /// Configura los handles
  void setHandlesConfig(TransformHandlesConfig config) {
    _handlesConfig = config;
    notifyListeners();
  }

  /// Limpia todos los items
  void clear() {
    _items.clear();
    _selectedItemId = null;
    notifyListeners();
  }
}
