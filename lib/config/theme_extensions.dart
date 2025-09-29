import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Extension methods for easier access to theme colors
extension ThemeExtensions on BuildContext {
  /// Get the current color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Get brand colors
  BrandColors get brandColors => AppTheme.getBrandColors(this);

  /// Common color getters for frequently used colors
  Color get primaryColor => colorScheme.primary;
  Color get onPrimary => colorScheme.onPrimary;
  Color get surface => colorScheme.surface;
  Color get onSurface => colorScheme.onSurface;
  Color get background => colorScheme.surface;
  Color get onBackground => colorScheme.onSurface;

  /// Brand specific colors
  Color get successGreen => brandColors.successGreen;
  Color get warningOrange => brandColors.warningOrange;
  Color get focusBlue => brandColors.focusBlue;
  Color get sentenceGray => brandColors.sentenceGray;
  Color get statusBackground => brandColors.statusBackground;
  Color get previewBorder => brandColors.previewBorder;
  Color get highlightOverlay => brandColors.highlightOverlay;
}
