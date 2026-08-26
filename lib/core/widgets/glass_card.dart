import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Border? border;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.blur = 15.0,
    this.opacity = 0.1,
    this.borderRadius,
    this.padding,
    this.border,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(20);

    Widget container = ClipRRect(
      borderRadius: effectiveBorderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor.withOpacity(opacity),
            borderRadius: effectiveBorderRadius,
            border: border ??
                Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1.0,
                ),
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: effectiveBorderRadius,
        child: container,
      );
    }

    return container;
  }
}
