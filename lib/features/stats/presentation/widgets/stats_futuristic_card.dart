import 'dart:ui';

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Carte avec coins arrondis, bordure légère et option flou type « glass ».
class StatsFuturisticCard extends StatelessWidget {
  const StatsFuturisticCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.useBlur = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool useBlur;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;

    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: ext.border.withAlpha(180)),
      color: theme.colorScheme.surface.withAlpha(242),
      boxShadow: [
        BoxShadow(
          color: theme.colorScheme.primary.withAlpha(18),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );

    final inner = Container(
      padding: padding,
      decoration: decoration,
      child: child,
    );

    if (!useBlur) {
      return inner;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: inner,
      ),
    );
  }
}
