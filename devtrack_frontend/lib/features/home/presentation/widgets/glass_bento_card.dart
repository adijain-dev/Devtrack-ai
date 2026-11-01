import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class GlassBentoCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? heroTag;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color glowColor;

  const GlassBentoCard({
    super.key,
    required this.child,
    this.onTap,
    this.heroTag,
    this.padding = const EdgeInsets.all(16.0),
    this.borderRadius = 18.0,
    this.glowColor = AppColors.accent,
  });

  @override
  Widget build(BuildContext context) {
    final innerContent = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            // Semi-translucent dark surface with a subtle indigo/violet hue
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                glowColor.withValues(alpha: 0.14),
                AppColors.surface.withValues(alpha: 0.75),
              ],
            ),
            // Faint gradient border for glass touch
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.14),
              width: 1.0,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(borderRadius),
              splashColor: glowColor.withValues(alpha: 0.15),
              highlightColor: glowColor.withValues(alpha: 0.08),
              child: Padding(
                padding: padding,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );

    if (heroTag != null) {
      return Hero(
        tag: heroTag!,
        child: Material(
          color: Colors.transparent,
          child: innerContent,
        ),
      );
    }

    return innerContent;
  }
}
