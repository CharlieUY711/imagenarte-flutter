import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Barra superior naranja de 25px de altura
class ToolbarOrange extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? trailing;

  const ToolbarOrange({
    super.key,
    this.leading,
    this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppTokens.toolbarHeight,
      color: AppTokens.accentOrange,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (leading != null) leading!,
          if (title != null) Expanded(child: title!),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
