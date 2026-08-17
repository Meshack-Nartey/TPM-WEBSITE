import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Two surfaces, one brand.
///
/// Members and the public get the light blue-white-gold experience; branch
/// leaders and the pastor's office cross into the gold-on-black work portal.
/// Every colour below comes straight off the TPM design board.
class TpmColors {
  const TpmColors._();

  // ---- Member / public (light) ----
  static const Color canvas = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color navy = Color(0xFF1E3A8A);
  static const Color blue = Color(0xFF3B82F6);
  static const Color blueDeep = Color(0xFF2563EB);
  static const Color ink = Color(0xFF1E293B);
  static const Color inkSoft = Color(0xFF334155);
  static const Color muted = Color(0xFF475569);
  static const Color subtle = Color(0xFF64748B);
  static const Color faint = Color(0xFF94A3B8);
  static const Color hairline = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);
  static const Color tintBlue = Color(0xFFDBEAFE);
  static const Color tintIndigo = Color(0xFFEEF2FF);
  static const Color tintViolet = Color(0xFFF3E8FF);
  static const Color tintAmber = Color(0xFFFEF3C7);
  static const Color tintGreen = Color(0xFFDCFCE7);
  static const Color slateWash = Color(0xFFF8FAFC);

  // ---- Brand gold ----
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldDeep = Color(0xFFB8941F);

  // ---- Portal / work mode (dark) ----
  static const Color night = Color(0xFF080808);
  static const Color nightSurface = Color(0xFF111111);
  static const Color nightRaised = Color(0xFF181818);
  static const Color nightCanvas = Color(0xFF0F1420);
  static const Color portalGold = Color(0xFFC9A84C);
  static const Color portalGoldDeep = Color(0xFFA07830);
  static const Color portalInk = Color(0xFFF0F0F0);

  // ---- Semantic ----
  static const Color success = Color(0xFF4ADE80);
  static const Color danger = Color(0xFFF87171);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF60A5FA);
  static const Color violet = Color(0xFF7C1D6F);
  static const Color green = Color(0xFF16A34A);
  static const Color deepNavy = Color(0xFF0B1220);

  // ---- Gradients ----
  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navy, blue],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gold, goldDeep],
  );

  static const LinearGradient portalGoldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [portalGold, portalGoldDeep],
  );

  /// Warm highlight dropped over navy artwork so gold reads through the blue.
  static RadialGradient goldGlow({double opacity = 0.35}) => RadialGradient(
        center: const Alignment(0.55, -0.5),
        radius: 0.9,
        colors: [gold.withValues(alpha: opacity), Colors.transparent],
      );
}

/// Shared elevation. The light surface uses a navy-tinted shadow rather than
/// neutral black so cards sit in the blue world instead of floating over it.
class TpmShadows {
  const TpmShadows._();

  static List<BoxShadow> card = [
    BoxShadow(
      color: TpmColors.navy.withValues(alpha: 0.07),
      blurRadius: 14,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> raised = [
    BoxShadow(
      color: TpmColors.navy.withValues(alpha: 0.08),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> feature = [
    BoxShadow(
      color: TpmColors.navy.withValues(alpha: 0.28),
      blurRadius: 30,
      offset: const Offset(0, 14),
    ),
  ];
}

/// Type scale. Playfair Display carries every heading and figure; Montserrat
/// carries body copy, labels and numbers-in-prose.
class TpmText {
  const TpmText._();

  static TextStyle display(
    double size, {
    Color color = TpmColors.ink,
    FontWeight weight = FontWeight.w700,
    double? height,
  }) =>
      GoogleFonts.playfairDisplay(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
      );

  static TextStyle body(
    double size, {
    Color color = TpmColors.subtle,
    FontWeight weight = FontWeight.w400,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.montserrat(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  /// The gold uppercase eyebrow that opens almost every section.
  static TextStyle eyebrow({
    Color color = TpmColors.goldDeep,
    double size = 10.5,
    double tracking = 2,
  }) =>
      GoogleFonts.montserrat(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: tracking,
      );
}

class TpmTheme {
  const TpmTheme._();

  /// Member and public surface.
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: TpmColors.canvas,
      colorScheme: ColorScheme.fromSeed(
        seedColor: TpmColors.navy,
        brightness: Brightness.light,
      ).copyWith(
        primary: TpmColors.navy,
        secondary: TpmColors.gold,
        surface: TpmColors.surface,
      ),
    );
    return base.copyWith(
      textTheme: GoogleFonts.montserratTextTheme(base.textTheme)
          .apply(bodyColor: TpmColors.ink, displayColor: TpmColors.ink),
      splashFactory: InkSparkle.splashFactory,
    );
  }

  /// Leader and administrator work portal.
  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: TpmColors.night,
      colorScheme: ColorScheme.fromSeed(
        seedColor: TpmColors.portalGold,
        brightness: Brightness.dark,
      ).copyWith(
        primary: TpmColors.portalGold,
        secondary: TpmColors.gold,
        surface: TpmColors.nightSurface,
      ),
    );
    return base.copyWith(
      textTheme: GoogleFonts.montserratTextTheme(base.textTheme)
          .apply(bodyColor: TpmColors.portalInk, displayColor: TpmColors.portalInk),
      splashFactory: InkSparkle.splashFactory,
    );
  }
}
