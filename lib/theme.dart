import 'package:flutter/material.dart';

/// Colores corporativos de Contribia.
class ContribiaColors {
  static const azulOscuro = Color(0xFF0A1F44);
  static const celeste = Color(0xFF29B6F6);
  static const blanco = Color(0xFFFFFFFF);
  static const rojoRec = Color(0xFFFF3B30);
}

ThemeData buildContribiaTheme({required bool dark}) {
  final base = dark ? ThemeData.dark() : ThemeData.light();
  return base.copyWith(
    primaryColor: ContribiaColors.azulOscuro,
    colorScheme: base.colorScheme.copyWith(
      primary: ContribiaColors.azulOscuro,
      secondary: ContribiaColors.celeste,
    ),
    scaffoldBackgroundColor: dark ? const Color(0xFF0B1220) : const Color(0xFFF5F7FA),
    appBarTheme: AppBarTheme(
      backgroundColor: dark ? const Color(0xFF131C31) : ContribiaColors.blanco,
      foregroundColor: dark ? ContribiaColors.blanco : ContribiaColors.azulOscuro,
      elevation: 0,
      centerTitle: false,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ContribiaColors.azulOscuro,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: dark ? const Color(0xFF223055) : const Color(0xFFE4E8EE)),
      ),
      color: dark ? const Color(0xFF131C31) : ContribiaColors.blanco,
    ),
    useMaterial3: true,
  );
}
