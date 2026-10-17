import 'package:flutter/material.dart';

/// Reusable application logo widget.
/// Displays the custom Bicycle Maintenance Log logo with customizable size,
/// rounded corners, background, and optional border styling.
class AppLogo extends StatelessWidget {
  final double size;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final BoxFit fit;

  const AppLogo({
    super.key,
    this.size = 40.0,
    this.borderRadius = 10.0,
    this.backgroundColor = Colors.white,
    this.borderColor,
    this.borderWidth = 1.0,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 4,
            offset: Offset(0, 1.5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          'assets/images/app_logo.png',
          width: size,
          height: size,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.directions_bike_rounded,
              size: size * 0.65,
              color: const Color(0xFF009688),
            );
          },
        ),
      ),
    );
  }
}
