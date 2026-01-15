import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'dial_button.dart';

/// Panel expandido que aparece debajo del DialButton
/// Muestra opciones de acciones disponibles
class ActionDialExpanded extends StatelessWidget {
  final List<DialAction> actions;
  final VoidCallback? onClose;

  const ActionDialExpanded({
    super.key,
    required this.actions,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTokens.neutralDark.withOpacity(0.95),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTokens.neutralMedium,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: actions.map((action) {
                return DialButton(
                  label: action.label,
                  onTap: action.onTap,
                  isActive: action.isActive,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Modelo para una acción del dial
class DialAction {
  final String label;
  final VoidCallback? onTap;
  final bool isActive;

  DialAction({
    required this.label,
    this.onTap,
    this.isActive = false,
  });
}
