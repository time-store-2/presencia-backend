import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  final bool useSafeArea;

  const AppBackground({
    super.key,
    required this.child,
    this.useSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Déterminer la décoration de fond selon le thème
    BoxDecoration decoration;
    if (theme.brightness == Brightness.dark && theme.colorScheme.primary == const Color(0xFFC3DFD3)) {
      // Ethereal Serenity
      decoration = const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topLeft,
          radius: 1.5,
          colors: [Color(0xFF1D2E28), Color(0xFF111413)],
        ),
      );
    } else if (theme.colorScheme.primary == Colors.black && theme.colorScheme.surface == const Color(0xFFF9F9F9)) {
      // Aura Luxury
      decoration = const BoxDecoration(
        color: Color(0xFFF9F9F9),
      );
    } else {
      // Warm Community / Default
      decoration = BoxDecoration(
        color: theme.scaffoldBackgroundColor,
      );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: decoration,
      child: useSafeArea ? SafeArea(child: child) : child,
    );
  }
}
