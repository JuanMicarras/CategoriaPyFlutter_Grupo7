import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract final class AppTheme {
  // 1. Mantenemos tus colores exactos disponibles como constantes estáticas
  static const Color primaryColor = Color(0xFF764AB5);
  static const Color secondaryColor = Color(0xFFAF95DE);
  static const Color backgroundColor = Color(0xFFFAF8FF);
  static const Color textColor = Color(0xFF170F37);

  // 2. Creamos un esquema de FlexColorScheme con tus colores
  static const FlexSchemeColor _myCustomColors = FlexSchemeColor(
    primary: primaryColor,
    secondary: secondaryColor,
    appBarColor: primaryColor,
    error: Colors.redAccent,
  );

  // The FlexColorScheme defined light mode ThemeData.
  static ThemeData light = FlexThemeData.light(
    colors: _myCustomColors, // Usamos tu paleta en lugar de yellowM3
    scaffoldBackground: backgroundColor, // Forzamos tu fondo oscuro
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      useM2StyleDividerInM3: true,
      inputDecoratorIsFilled: true,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      alignedDropdown: true,
      navigationRailUseIndicator: true,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  );

  // The FlexColorScheme defined dark mode ThemeData.
  static ThemeData dark = FlexThemeData.dark(
    colors: _myCustomColors, // Usamos tu paleta
    scaffoldBackground: backgroundColor, // Forzamos tu fondo oscuro
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      blendOnColors: true,
      useM2StyleDividerInM3: true,
      inputDecoratorIsFilled: true,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      alignedDropdown: true,
      navigationRailUseIndicator: true,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  );
}