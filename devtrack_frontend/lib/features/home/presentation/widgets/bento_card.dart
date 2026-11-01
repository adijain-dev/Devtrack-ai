import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class BentoCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? heroTag;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? borderColor;
  final double borderRadius;
  final Gradient? gradient;

  const BentoCard({
    super.key,
    required this.child,
    this.onTap,
    this.heroTag,
    this.padding = const EdgeInsets.all(16.0),
    this.color,
    this.borderColor,
    this.borderRadius = 18.0,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        splashColor: AppColors.accent.withValues(alpha: 0.1),
        highlightColor: AppColors.accent.withValues(alpha: 0.05),
        child: Container(
          decoration: BoxDecoration(
            color: gradient == null ? (color ?? AppColors.surface) : null,
            gradient: gradient,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ?? AppColors.cardBorder,
              width: 1.0,
            ),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );

    if (heroTag != null) {
      return Hero(
        tag: heroTag!,
        child: Material(
          color: Colors.transparent,
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}
