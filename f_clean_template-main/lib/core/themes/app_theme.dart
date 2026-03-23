import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract final class AppTheme {
  // 1. Mantenemos tus colores exactos disponibles como constantes estáticas
  static const Color primaryColor = Color(0xFF764AB5);
  static const Color primaryColor100 = Color(0xFF8761BE);
  static const Color primaryColor200 = Color(0xFF9877C8);
  static const Color primaryColor300 = Color(0xFFA98ED1);
  static const Color primaryColor400 = Color(0xFFBBA5DA);
  static const Color primaryColor500 = Color(0xFFCCBBE3);
  static const Color primaryColor600 = Color(0xFFDDD2ED);
  static const Color primaryColor700 = Color(0xFFEEE8F6);

  static const Color popupColor100 = Color(0xFFBF94FF);
  static const Color popupColor200 = Color(0xFFC8A3FF);
  static const Color popupColor300 = Color(0xFFD1B3FF);
  static const Color popupColor400 = Color(0xFFDBC2FF);
  static const Color popupColor500 = Color(0xFFE4D1FF);
  static const Color popupColor600 = Color(0xFFEDE1FF);
  static const Color popupColor700 = Color(0xFFF6F0FF);

  static const Color secondaryColor = Color(0xFFAF95DE);
  static const Color secondaryColor100 = Color(0xFFB9A2E2);
  static const Color secondaryColor200 = Color(0xFFC3B0E6);
  static const Color secondaryColor300 = Color(0xFFCDBDEA);
  static const Color secondaryColor400 = Color(0xFFD7CAEF);
  static const Color secondaryColor500 = Color(0xFFE1D7F3);
  static const Color secondaryColor600 = Color(0xFFEBE5F7);
  static const Color secondaryColor700 = Color(0xFFF5F0FF);

  static const Color backgroundColor = Color(0xFFFAF8FF);
  
  static const Color textColor = Color(0xFF170F37);
  static const Color textColorLight = Color(0xFF764AB5);
  static const Color textColorDark = Color(0xFFFFFFFF);

  static const Color grayColor100 = Color(0xFFCBCED5);
  static const Color grayColor200 = Color(0xFFD2D5D8);
  static const Color grayColor300 = Color(0xFFDADCE1);
  static const Color grayColor400 = Color(0xFFE1E3E7);
  static const Color grayColor500 = Color(0xFFE9EAED);
  static const Color grayColor600 = Color(0xFFF0F1F3);
  static const Color grayColor700 = Color(0xFFF7F8F9);
  
  static const Color darkBackground = Color(0xFF0F0B1F);
  static const Color darkSurface = Color(0xFF1A1433);
  static const Color darkCard = Color(0xFF241C45);

  static const Color darkPrimary = Color(0xFF8761BE);
  static const Color darkPrimaryLight = Color(0xFFA98ED1);
  static const Color darkPrimarySoft = Color(0xFFCCBBE3);

  static const Color darkSecondary = Color(0xFFAF95DE);

  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB9B4D0);
  static const Color darkTextMuted = Color(0xFF8E8AA8);

  static const Color darkInputBackground = Color(0xFF1F1838);
  static const Color darkBorder = Color(0xFF3A3260);

  // 2. Creamos un esquema de FlexColorScheme con tus colores
  static const FlexSchemeColor _myCustomColors = FlexSchemeColor(
    primary: primaryColor,
    secondary: secondaryColor,
    appBarColor: primaryColor,
    error: Colors.redAccent,
  );

  static const FlexSchemeColor _myDarkColors = FlexSchemeColor(
    primary: darkPrimaryLight,
    secondary: darkSecondary,
    appBarColor: darkSurface,
    error: Colors.redAccent,
  );

  // The FlexColorScheme defined light mode ThemeData.
  static ThemeData light = FlexThemeData.light(
    colors: _myCustomColors, // Usamos tu paleta en lugar de yellowM3
    scaffoldBackground: backgroundColor,
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
    colors: _myDarkColors, // Usamos tu paleta
    scaffoldBackground: darkBackground, // Forzamos tu fondo oscuro
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
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: darkTextPrimary),
      bodyMedium: TextStyle(color: darkTextPrimary),
    ),
  );

  // 3. Definimos la tipografía
  // Heading
  static const TextStyle h1 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 32,
    fontWeight: FontWeight.w800, // ExtraBold
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 28,
    fontWeight: FontWeight.w700, // Bold
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 24,
    fontWeight: FontWeight.w700, // Bold
  );

  static const TextStyle h4 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 20,
    fontWeight: FontWeight.w700, // Bold
  );

  static const TextStyle h5 = TextStyle(
    fontFamily: 'Inter',
    fontSize: 18,
    fontWeight: FontWeight.w700, // Bold
  );

  // Body
  static const TextStyle bodyXL = TextStyle(
    fontFamily: 'Inter',
    fontSize: 18,
    fontWeight: FontWeight.w400, // Regular
  );

  static const TextStyle bodyL = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w400, // Regular
  );

  static const TextStyle bodyM = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w400, // Regular
  );

  static const TextStyle bodyS = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w400, // Regular
  );

  static const TextStyle bodyXS = TextStyle(
    fontFamily: 'Inter',
    fontSize: 10,
    fontWeight: FontWeight.w500, // Medium
  );

  // Button
  static const TextStyle buttonL = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w600, // SemiBold
  );

  static const TextStyle buttonM = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w600, // SemiBold
  );

  static const TextStyle buttonS = TextStyle(
    fontFamily: 'Inter',
    fontSize: 10,
    fontWeight: FontWeight.w600, // SemiBold
  );

  // CAPTION
  static const TextStyle caption = TextStyle(
    fontFamily: 'Inter',
    fontSize: 10,
    fontWeight: FontWeight.w500, // Medium
  );

}