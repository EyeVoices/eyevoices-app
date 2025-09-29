import 'package:flutter/material.dart';

/// Custom theme extension for brand-specific colors
class BrandColors extends ThemeExtension<BrandColors> {
  const BrandColors({
    required this.successGreen,
    required this.warningOrange,
    required this.focusBlue,
    required this.sentenceGray,
    required this.statusBackground,
    required this.previewBorder,
    required this.highlightOverlay,
  });

  final Color successGreen;
  final Color warningOrange;
  final Color focusBlue;
  final Color sentenceGray;
  final Color statusBackground;
  final Color previewBorder;
  final Color highlightOverlay;

  @override
  BrandColors copyWith({
    Color? successGreen,
    Color? warningOrange,
    Color? focusBlue,
    Color? sentenceGray,
    Color? statusBackground,
    Color? previewBorder,
    Color? highlightOverlay,
  }) {
    return BrandColors(
      successGreen: successGreen ?? this.successGreen,
      warningOrange: warningOrange ?? this.warningOrange,
      focusBlue: focusBlue ?? this.focusBlue,
      sentenceGray: sentenceGray ?? this.sentenceGray,
      statusBackground: statusBackground ?? this.statusBackground,
      previewBorder: previewBorder ?? this.previewBorder,
      highlightOverlay: highlightOverlay ?? this.highlightOverlay,
    );
  }

  @override
  BrandColors lerp(ThemeExtension<BrandColors>? other, double t) {
    if (other is! BrandColors) {
      return this;
    }
    return BrandColors(
      successGreen: Color.lerp(successGreen, other.successGreen, t)!,
      warningOrange: Color.lerp(warningOrange, other.warningOrange, t)!,
      focusBlue: Color.lerp(focusBlue, other.focusBlue, t)!,
      sentenceGray: Color.lerp(sentenceGray, other.sentenceGray, t)!,
      statusBackground: Color.lerp(
        statusBackground,
        other.statusBackground,
        t,
      )!,
      previewBorder: Color.lerp(previewBorder, other.previewBorder, t)!,
      highlightOverlay: Color.lerp(
        highlightOverlay,
        other.highlightOverlay,
        t,
      )!,
    );
  }

  static const light = BrandColors(
    successGreen: Color(0xFF4CAF50),
    warningOrange: Color(0xFFFF9800),
    focusBlue: Color(0xFF2196F3),
    sentenceGray: Color(0xFF757575),
    statusBackground: Color(0xFFF5F5F5),
    previewBorder: Color(0xFFE0E0E0),
    highlightOverlay: Color(0x33000000),
  );

  static const dark = BrandColors(
    successGreen: Color(0xFF66BB6A),
    warningOrange: Color(0xFFFFB74D),
    focusBlue: Color(0xFF42A5F5),
    sentenceGray: Color(0xFFBDBDBD),
    statusBackground: Color(0xFF1E1E1E),
    previewBorder: Color(0xFF424242),
    highlightOverlay: Color(0x33FFFFFF),
  );
}

/// App theme configuration
class AppTheme {
  AppTheme._();

  /// Primary seed color for the color scheme
  static const Color primarySeedColor = Color(0xFF6A1B9A); // Purple

  /// Light theme configuration
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primarySeedColor,
      brightness: Brightness.light,
      surface: Colors.white,
      onSurface: const Color(0xFF212121),
    ),
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF212121),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
      ),
    ),
    cardTheme: const CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      surfaceTintColor: Colors.transparent,
    ),
    extensions: const <ThemeExtension<dynamic>>[BrandColors.light],
  );

  /// Dark theme configuration
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primarySeedColor,
      brightness: Brightness.dark,
      surface: const Color(0xFF0A0A0A),
      onSurface: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFF0A0A0A),
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0A0A0A),
      foregroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
      ),
    ),
    cardTheme: const CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      surfaceTintColor: Colors.transparent,
    ),
    extensions: const <ThemeExtension<dynamic>>[BrandColors.dark],
  );

  /// Helper method to get brand colors from context
  static BrandColors getBrandColors(BuildContext context) {
    return Theme.of(context).extension<BrandColors>() ?? BrandColors.light;
  }
}
