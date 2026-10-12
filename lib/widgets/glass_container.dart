import 'dart:ui';
import 'package:flutter/material.dart';

/// Ultra-Modern Frosted Glass Container inspired by dark luxury tactile design
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final Color? surfaceColor;
  final Color? borderColor;
  final double blur;
  final VoidCallback? onTap;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.borderRadius = 24.0,
    this.surfaceColor,
    this.borderColor,
    this.blur = 18.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultSurface = isDark
        ? const Color(0xFF131B2E).withValues(alpha: 0.65)
        : Colors.white.withValues(alpha: 0.85);

    final defaultBorder = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : const Color(0xFFCBD5E1).withValues(alpha: 0.6);

    final content = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: surfaceColor ?? defaultSurface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? defaultBorder,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          if (isDark)
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.03),
              blurRadius: 1,
              spreadRadius: 1,
              offset: const Offset(0, -1),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: padding,
              child: child,
            ),
          ),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }
    return content;
  }
}

/// Segmented Pill Control matching the "Warm / Neutral / Cold" capsule in reference design
class GlassPillSegmentedBar<T> extends StatelessWidget {
  final List<T> values;
  final List<String> labels;
  final List<IconData?> icons;
  final T selected;
  final ValueChanged<T> onSelected;

  const GlassPillSegmentedBar({
    super.key,
    required this.values,
    required this.labels,
    required this.icons,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.8) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(values.length, (index) {
          final val = values[index];
          final isSelected = val == selected;
          final icon = index < icons.length ? icons[index] : null;

          return GestureDetector(
            onTap: () => onSelected(val),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? const Color(0xFF1E293B) : Colors.white)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 14,
                      color: isSelected
                          ? (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7))
                          : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    labels[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? (isDark ? Colors.white : const Color(0xFF0F172A))
                          : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Glowing Pill Action Button (matching the vivid neon orange/cyan button in reference image)
class GlassPillButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;
  final Color? color;
  final Color? textColor;

  const GlassPillButton({
    super.key,
    required this.text,
    this.icon,
    required this.onPressed,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final defaultBg = color ?? const Color(0xFFFF6B2B); // High-contrast vivid orange
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: defaultBg,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: defaultBg.withValues(alpha: 0.45),
              blurRadius: 16,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: textColor ?? Colors.white),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: textColor ?? Colors.white,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
