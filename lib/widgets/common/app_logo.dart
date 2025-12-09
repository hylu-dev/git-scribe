import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Widget that displays the app logo, automatically selecting
/// the appropriate variant based on the current theme brightness
class AppLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final bool useTransparent;

  const AppLogo({
    super.key,
    this.width,
    this.height,
    this.useTransparent = true,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    String assetPath;
    if (useTransparent) {
      assetPath = isDark
          ? 'assets/icons/logo_light_transparent.svg'
          : 'assets/icons/logo_dark_transparent.svg';
    } else {
      assetPath = isDark
          ? 'assets/icons/logo_light.svg'
          : 'assets/icons/logo_dark.svg';
    }

    return SvgPicture.asset(
      assetPath,
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }
}
