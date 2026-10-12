import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

const EdgeInsets kPagePadding = EdgeInsets.all(16);

enum AppThemeType { auraLuxury, etherealSerenity, warmCommunity }

class StatusColors extends ThemeExtension<StatusColors> {
  final Color presentBg;
  final Color presentText;
  final Color absentBg;
  final Color absentText;
  final Color lateBg;
  final Color lateText;
  final Color excusedBg;
  final Color excusedText;

  StatusColors({
    required this.presentBg,
    required this.presentText,
    required this.absentBg,
    required this.absentText,
    required this.lateBg,
    required this.lateText,
    required this.excusedBg,
    required this.excusedText,
  });

  @override
  StatusColors copyWith({
    Color? presentBg,
    Color? presentText,
    Color? absentBg,
    Color? absentText,
    Color? lateBg,
    Color? lateText,
    Color? excusedBg,
    Color? excusedText,
  }) {
    return StatusColors(
      presentBg: presentBg ?? this.presentBg,
      presentText: presentText ?? this.presentText,
      absentBg: absentBg ?? this.absentBg,
      absentText: absentText ?? this.absentText,
      lateBg: lateBg ?? this.lateBg,
      lateText: lateText ?? this.lateText,
      excusedBg: excusedBg ?? this.excusedBg,
      excusedText: excusedText ?? this.excusedText,
    );
  }

  @override
  StatusColors lerp(ThemeExtension<StatusColors>? other, double t) {
    if (other is! StatusColors) return this;
    return StatusColors(
      presentBg: Color.lerp(presentBg, other.presentBg, t)!,
      presentText: Color.lerp(presentText, other.presentText, t)!,
      absentBg: Color.lerp(absentBg, other.absentBg, t)!,
      absentText: Color.lerp(absentText, other.absentText, t)!,
      lateBg: Color.lerp(lateBg, other.lateBg, t)!,
      lateText: Color.lerp(lateText, other.lateText, t)!,
      excusedBg: Color.lerp(excusedBg, other.excusedBg, t)!,
      excusedText: Color.lerp(excusedText, other.excusedText, t)!,
    );
  }
}

class AppDesignSystem extends ThemeExtension<AppDesignSystem> {
  final double radiusSm;
  final double radiusDefault;
  final double radiusMd;
  final double radiusLg;
  final double radiusXl;
  final double spacingUnit;

  AppDesignSystem({
    required this.radiusSm,
    required this.radiusDefault,
    required this.radiusMd,
    required this.radiusLg,
    required this.radiusXl,
    required this.spacingUnit,
  });

  @override
  AppDesignSystem copyWith({
    double? radiusSm,
    double? radiusDefault,
    double? radiusMd,
    double? radiusLg,
    double? radiusXl,
    double? spacingUnit,
  }) {
    return AppDesignSystem(
      radiusSm: radiusSm ?? this.radiusSm,
      radiusDefault: radiusDefault ?? this.radiusDefault,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
      radiusXl: radiusXl ?? this.radiusXl,
      spacingUnit: spacingUnit ?? this.spacingUnit,
    );
  }

  static double _lerpDouble(double a, double b, double t) => a + (b - a) * t;

  @override
  AppDesignSystem lerp(ThemeExtension<AppDesignSystem>? other, double t) {
    if (other is! AppDesignSystem) return this;
    return AppDesignSystem(
      radiusSm: _lerpDouble(radiusSm, other.radiusSm, t),
      radiusDefault: _lerpDouble(radiusDefault, other.radiusDefault, t),
      radiusMd: _lerpDouble(radiusMd, other.radiusMd, t),
      radiusLg: _lerpDouble(radiusLg, other.radiusLg, t),
      radiusXl: _lerpDouble(radiusXl, other.radiusXl, t),
      spacingUnit: _lerpDouble(spacingUnit, other.spacingUnit, t),
    );
  }
}

class AppThemes {
  static ThemeData auraLuxury() {
    final base = ThemeData.light(useMaterial3: true);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.black,
      primary: const Color(0xFF000000),
      onPrimary: const Color(0xFFFFFFFF),
      surface: const Color(0xFFF9F9F9),
      onSurface: const Color(0xFF1B1B1B),
      surfaceContainer: const Color(0xFFEEEEEE),
      surfaceContainerLow: const Color(0xFFF3F3F3),
      surfaceContainerHighest: const Color(0xFFE2E2E2),
      onSurfaceVariant: const Color(0xFF4C4546),
      outline: const Color(0xFF7E7576),
      outlineVariant: const Color(0xFFCFC4C5),
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        centerTitle: false,
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: colorScheme.onSurface, 
          fontSize: 24, 
          fontWeight: FontWeight.bold
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ).copyWith(
        displayLarge: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700, color: colorScheme.onSurface),
        headlineLarge: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
        headlineMedium: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
        titleLarge: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: colorScheme.onSurface),
        titleMedium: GoogleFonts.manrope(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
        bodyLarge: GoogleFonts.manrope(color: colorScheme.onSurface),
        bodyMedium: GoogleFonts.manrope(color: colorScheme.onSurface),
        labelLarge: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: colorScheme.primary,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return const IconThemeData(color: Colors.white);
          return IconThemeData(color: colorScheme.onSurfaceVariant);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.bold, color: colorScheme.primary);
          }
          return GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w500, color: colorScheme.onSurfaceVariant);
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.primary, width: 2)),
        contentPadding: const EdgeInsets.all(20),
        labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
      ),
      extensions: [
        AppDesignSystem(radiusSm: 8, radiusDefault: 16, radiusMd: 24, radiusLg: 32, radiusXl: 48, spacingUnit: 8),
        StatusColors(
          presentBg: const Color(0xFFEAF5EF), presentText: const Color(0xFF2D7A56),
          absentBg: const Color(0xFFFDECEA), absentText: const Color(0xFFC0392B),
          lateBg: const Color(0xFFFEF3C7), lateText: const Color(0xFFD97706),
          excusedBg: const Color(0xFFF0EBF8), excusedText: const Color(0xFF6B4CAE),
        ),
      ],
    );
  }

  static ThemeData etherealSerenity() {
    final base = ThemeData.dark(useMaterial3: true);
    final colorScheme = const ColorScheme.dark(
      primary: Color(0xFFC3DFD3),
      onPrimary: Color(0xFF1D352D),
      surface: Color(0xFF111413),
      onSurface: Color(0xFFE1E3E1),
      surfaceContainer: Color(0xFF1D201F),
      onSurfaceVariant: Color(0xFFC2C8C4),
      outline: Color(0xFF8C928E),
      primaryContainer: Color(0xFF395148),
      onPrimaryContainer: Color(0xFFC3DFD3),
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(color: colorScheme.onSurface, fontSize: 24, fontWeight: FontWeight.bold),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ).copyWith(
        titleLarge: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
        labelLarge: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: colorScheme.primary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primary,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return IconThemeData(color: colorScheme.onPrimary);
          return IconThemeData(color: colorScheme.primary);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: colorScheme.primary);
          }
          return GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: colorScheme.onSurfaceVariant);
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.2))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.primary, width: 2)),
        contentPadding: const EdgeInsets.all(20),
        labelStyle: TextStyle(color: colorScheme.primary.withOpacity(0.8)),
      ),
      extensions: [
        AppDesignSystem(radiusSm: 4, radiusDefault: 8, radiusMd: 12, radiusLg: 16, radiusXl: 24, spacingUnit: 8),
        StatusColors(
          presentBg: const Color(0xFFC3DFD3).withOpacity(0.2), presentText: const Color(0xFFC3DFD3),
          absentBg: const Color(0xFFFFB4AB).withOpacity(0.2), absentText: const Color(0xFFFFB4AB),
          lateBg: const Color(0xFFFEF3C7).withOpacity(0.2), lateText: const Color(0xFFFEF3C7),
          excusedBg: const Color(0xFFA0CFCC).withOpacity(0.2), excusedText: const Color(0xFFA0CFCC),
        ),
      ],
    );
  }

  static ThemeData warmCommunity() {
    final base = ThemeData.light(useMaterial3: true);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFA13A15),
      primary: const Color(0xFFA13A15),
      onPrimary: const Color(0xFFFFFFFF),
      surface: const Color(0xFFFFF8F6),
      onSurface: const Color(0xFF221A16),
      onSurfaceVariant: const Color(0xFF57423B),
      surfaceContainer: const Color(0xFFFCEAE3),
      surfaceContainerLow: const Color(0xFFFFF1EB),
      surfaceContainerHighest: const Color(0xFFF0DFD8),
      outline: const Color(0xFF8B716A),
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFFAF7F5),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(color: colorScheme.onSurface, fontSize: 24, fontWeight: FontWeight.bold),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ).copyWith(
        headlineMedium: GoogleFonts.inter(fontWeight: FontWeight.w700, color: colorScheme.primary),
        titleLarge: GoogleFonts.inter(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
        titleMedium: GoogleFonts.inter(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primary.withOpacity(0.1),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
           if (states.contains(WidgetState.selected)) return GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: colorScheme.primary);
           return GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: colorScheme.onSurfaceVariant);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
           if (states.contains(WidgetState.selected)) return IconThemeData(color: colorScheme.primary, size: 26);
           return IconThemeData(color: colorScheme.outline, size: 24);
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEDE3DE))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEDE3DE))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colorScheme.primary, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
      ),
      extensions: [
        AppDesignSystem(radiusSm: 4, radiusDefault: 12, radiusMd: 16, radiusLg: 24, radiusXl: 32, spacingUnit: 4),
        StatusColors(
          presentBg: const Color(0xFFEAF5EF), presentText: const Color(0xFF2D7A56),
          absentBg: const Color(0xFFFDECEA), absentText: const Color(0xFFC0392B),
          lateBg: const Color(0xFFFEF3C7), lateText: const Color(0xFFD97706),
          excusedBg: const Color(0xFFF0EBF8), excusedText: const Color(0xFF6B4CAE),
        ),
      ],
    );
  }
}
