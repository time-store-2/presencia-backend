import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/themes/app_themes.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final design = theme.extension<AppDesignSystem>()!;
    final isEthereal = theme.brightness == Brightness.dark && 
                      theme.colorScheme.primary == const Color(0xFFC3DFD3);

    if (!isEthereal) {
      return Card(
        margin: margin,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(design.radiusDefault),
          child: Padding(
            padding: padding ?? EdgeInsets.all(design.spacingUnit * 2),
            child: child,
          ),
        ),
      );
    }

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(design.radiusDefault),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(design.radiusDefault),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Material(
            color: Colors.white.withOpacity(0.12),
            child: InkWell(
              onTap: onTap,
              child: Container(
                padding: padding ?? EdgeInsets.all(design.spacingUnit * 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(design.radiusDefault),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
