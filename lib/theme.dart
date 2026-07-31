import 'package:flutter/material.dart';

/// Colores corporativos de Contribia + paleta de apoyo Material 3.
class ContribiaColors {
  static const azulOscuro = Color(0xFF0A1F44);
  static const azulMedio = Color(0xFF14315E);
  static const celeste = Color(0xFF29B6F6);
  static const verde = Color(0xFF34C759);
  static const blanco = Color(0xFFFFFFFF);
  static const rojoRec = Color(0xFFFF3B30);
  static const amarillo = Color(0xFFFFB020);

  // Fondos y superficies (claro / oscuro)
  static const fondoClaro = Color(0xFFF3F6FA);
  static const fondoOscuro = Color(0xFF0B1220);
  static const superficieOscura = Color(0xFF141E33);
  static const bordeOscuro = Color(0xFF223055);
  static const bordeClaro = Color(0xFFE3E8F0);
}

ThemeData buildContribiaTheme({required bool dark}) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: ContribiaColors.azulOscuro,
    brightness: dark ? Brightness.dark : Brightness.light,
    primary: ContribiaColors.azulOscuro,
    secondary: ContribiaColors.celeste,
    tertiary: ContribiaColors.verde,
    surface: dark ? ContribiaColors.superficieOscura : ContribiaColors.blanco,
    error: ContribiaColors.rojoRec,
  );

  final baseTextTheme = (dark ? ThemeData.dark() : ThemeData.light()).textTheme;
  final textTheme = baseTextTheme.copyWith(
    titleLarge: baseTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.3),
    titleMedium: baseTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    bodyLarge: baseTextTheme.bodyLarge?.copyWith(height: 1.45),
    bodyMedium: baseTextTheme.bodyMedium?.copyWith(height: 1.45),
    labelLarge: baseTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: dark ? Brightness.dark : Brightness.light,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: dark ? ContribiaColors.fondoOscuro : ContribiaColors.fondoClaro,
    textTheme: textTheme,
    fontFamily: 'Roboto',
    splashFactory: InkRipple.splashFactory,
    visualDensity: VisualDensity.adaptivePlatformDensity,

    appBarTheme: AppBarTheme(
      backgroundColor: dark ? ContribiaColors.fondoOscuro : ContribiaColors.fondoClaro,
      foregroundColor: dark ? ContribiaColors.blanco : ContribiaColors.azulOscuro,
      elevation: 0,
      scrolledUnderElevation: 1,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: dark ? ContribiaColors.blanco : ContribiaColors.azulOscuro,
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2,
      ),
      iconTheme: IconThemeData(color: dark ? ContribiaColors.blanco : ContribiaColors.azulOscuro),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ContribiaColors.azulOscuro,
        foregroundColor: Colors.white,
        disabledBackgroundColor: ContribiaColors.azulOscuro.withOpacity(0.4),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        elevation: 0,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: dark ? ContribiaColors.celeste : ContribiaColors.azulOscuro,
        side: BorderSide(color: dark ? ContribiaColors.bordeOscuro : ContribiaColors.bordeClaro, width: 1.4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: ContribiaColors.celeste,
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),

    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        backgroundColor: dark ? ContribiaColors.superficieOscura : Colors.white,
        foregroundColor: dark ? ContribiaColors.blanco : ContribiaColors.azulOscuro,
        shape: const CircleBorder(),
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: ContribiaColors.azulOscuro,
      foregroundColor: Colors.white,
      elevation: 3,
      extendedTextStyle: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(18))),
    ),

    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: dark ? ContribiaColors.bordeOscuro : ContribiaColors.bordeClaro),
      ),
      color: dark ? ContribiaColors.superficieOscura : ContribiaColors.blanco,
      clipBehavior: Clip.antiAlias,
    ),

    chipTheme: ChipThemeData(
      backgroundColor: dark ? ContribiaColors.bordeOscuro.withOpacity(0.4) : ContribiaColors.azulOscuro.withOpacity(0.06),
      labelStyle: TextStyle(
        color: dark ? ContribiaColors.blanco : ContribiaColors.azulOscuro,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      border: InputBorder.none,
      hintStyle: TextStyle(color: dark ? Colors.white38 : Colors.black38),
    ),

    dividerTheme: DividerThemeData(
      color: dark ? ContribiaColors.bordeOscuro : ContribiaColors.bordeClaro,
      thickness: 1,
      space: 1,
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? Colors.white : null,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? ContribiaColors.celeste : null,
      ),
    ),

    sliderTheme: const SliderThemeData(
      activeTrackColor: ContribiaColors.celeste,
      thumbColor: ContribiaColors.celeste,
      overlayColor: Color(0x2229B6F6),
      trackHeight: 3,
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: ContribiaColors.azulOscuro,
      contentTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),

    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: dark ? ContribiaColors.superficieOscura : ContribiaColors.blanco,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      modalElevation: 8,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: dark ? ContribiaColors.superficieOscura : ContribiaColors.blanco,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}

/// Helper para pintar íconos dentro de un contenedor circular con tinte de
/// marca, usado en tarjetas y encabezados para dar un look más pulido.
class BrandIconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const BrandIconBadge({
    super.key,
    required this.icon,
    this.color = ContribiaColors.celeste,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: color, size: size * 0.52),
    );
  }
}
