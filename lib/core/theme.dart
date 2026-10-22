import 'package:flutter/material.dart';

/// Design tokens from the brand book «AI Ijodkor brend kitobi»
/// (tokens.json) and the approved screen mockups. Widgets use these —
/// never raw colors or sizes.

/// Color tokens for one theme. Read with `context.colors`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.surfacePage,
    required this.surfaceCard,
    required this.surfaceMuted,
    required this.border,
    required this.ink,
    required this.inkMuted,
    required this.inkSoft,
    required this.brand,
    required this.brandStrong,
    required this.brandTint,
    required this.brandDeep,
    required this.onBrand,
    required this.inverse,
    required this.onInverse,
    required this.trackSky,
    required this.trackGrape,
    required this.trackMoss,
    required this.success,
    required this.danger,
  });

  /// surface-page — app background.
  final Color surfacePage;

  /// surface-card — cards, panels, sheets.
  final Color surfaceCard;

  /// surface-muted — subtle sections, hints, progress tracks.
  final Color surfaceMuted;

  /// border — card borders, dividers, idle input outline.
  final Color border;

  /// ink — primary text.
  final Color ink;

  /// ink-muted — secondary text, captions, placeholders.
  final Color inkMuted;

  /// Body text on muted panels (mockups: #5C5140).
  final Color inkSoft;

  /// brand-500 — the single accent: primary buttons, active states.
  final Color brand;

  /// Accent-colored text/icons on light surfaces (links; mockups: #8A5A0B).
  final Color brandStrong;

  /// Light accent fill: nav indicator, icon badges (mockups: #FDF2E2).
  final Color brandTint;

  /// Text on brandTint (mockups: #614418).
  final Color brandDeep;

  /// on-brand — text/icons on a brand fill.
  final Color onBrand;

  /// Dark fill for secondary buttons and the points pill (ink #241C10).
  final Color inverse;

  /// Text on [inverse].
  final Color onInverse;

  /// Track colors — only to mark the three learning directions.
  final Color trackSky; // AI & Creative
  final Color trackGrape; // Code & Technology
  final Color trackMoss; // Digital Start

  final Color success;
  final Color danger;

  static const light = AppColors(
    surfacePage: Color(0xFFFFFCF6),
    surfaceCard: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFF7F0E2),
    border: Color(0xFFECE1CB),
    ink: Color(0xFF241C10),
    inkMuted: Color(0xFF7C6F58),
    inkSoft: Color(0xFF5C5140),
    brand: Color(0xFFF2A93B),
    brandStrong: Color(0xFF8A5A0B),
    brandTint: Color(0xFFFDF2E2),
    brandDeep: Color(0xFF614418),
    onBrand: Color(0xFF241C10),
    inverse: Color(0xFF241C10),
    onInverse: Color(0xFFFFFCF6),
    trackSky: Color(0xFF2F7FC9),
    trackGrape: Color(0xFF8858B0),
    trackMoss: Color(0xFF3C6E58),
    success: Color(0xFF2F7D4F),
    danger: Color(0xFFC4432E),
  );

  /// Dark values from tokens.json; the mockup-only shades (inkSoft,
  /// brandTint, brandDeep, inverse) are their dark-theme counterparts.
  static const dark = AppColors(
    surfacePage: Color(0xFF171310),
    surfaceCard: Color(0xFF211B14),
    surfaceMuted: Color(0xFF2A2318),
    border: Color(0xFF3B3122),
    ink: Color(0xFFF6EFE1),
    inkMuted: Color(0xFFAC9D82),
    inkSoft: Color(0xFFCFC2A8),
    brand: Color(0xFFF2A93B),
    brandStrong: Color(0xFFFFC569),
    brandTint: Color(0xFF3A2C16),
    brandDeep: Color(0xFFFFD9A0),
    onBrand: Color(0xFF241C10),
    inverse: Color(0xFFF6EFE1),
    onInverse: Color(0xFF241C10),
    trackSky: Color(0xFF6AA9E0),
    trackGrape: Color(0xFFB48ED8),
    trackMoss: Color(0xFF74A88F),
    success: Color(0xFF74C08F),
    danger: Color(0xFFE2836F),
  );

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(AppColors? other, double t) =>
      t < 0.5 || other == null ? this : other;
}

/// Spacing scale (space-1 … space-12).
abstract final class AppSpace {
  static const s1 = 4.0;
  static const s2 = 8.0;
  static const s3 = 12.0;
  static const s4 = 16.0;
  static const s5 = 20.0;
  static const s6 = 24.0;
  static const s8 = 32.0;
  static const s12 = 48.0;

  // In-between steps the mockups use.
  /// Label → field, icon → text in a pill.
  static const labelGap = 6.0;

  /// Gap between small tiles in a row.
  static const tileGap = 10.0;

  /// Compact card padding / vertical row padding.
  static const card = 14.0;

  /// Padding of highlighted panels (quiz card).
  static const panel = 18.0;

  /// Gap between sections on the student home.
  static const section = 22.0;

  /// Login: logo block and form offsets.
  static const s11 = 44.0;
  static const s14 = 56.0;
}

/// Corner radii (radius-sm/md/lg/pill).
abstract final class AppRadius {
  static const sm = 8.0;
  static const md = 14.0;
  static const lg = 20.0;
  static const pill = 999.0;

  /// Small icon tiles inside cards (mockups: 12).
  static const tile = 12.0;
}

/// Fixed control sizes.
abstract final class AppSize {
  /// Minimum touch target.
  static const touch = 44.0;
  static const buttonTall = 56.0;
  static const button = 52.0;
  static const input = 56.0;
  static const iconSm = 16.0;
  static const iconMd = 18.0;
  static const icon = 22.0;
  static const iconLg = 24.0;
  static const iconXl = 26.0;
  static const iconBtn = 20.0;
  static const iconHero = 30.0;
  static const iconEmpty = 32.0;
  static const emptyBadge = 72.0;
  static const iconTile = 44.0;
  static const avatar = 48.0;
  static const avatarLg = 56.0;
  static const logoBadgeSm = 44.0;
  static const eventDot = 8.0;
  static const avatarBorder = 2.0;
  static const pillHeight = 40.0;
  static const segmentHeight = 36.0;
  static const dot = 10.0;
  static const stepBadge = 26.0;
  static const rankBadge = 36.0;
  static const playButton = 72.0;
  static const mediaPanel = 196.0;
  static const gamePanel = 220.0;
  static const listRow = 64.0;
  static const statTile = 76.0;
  static const progressBar = 8.0;
  static const progressBarLg = 12.0;
  static const progressThin = 3.0;
  static const borderInput = 1.5;

  /// Max width of single-column forms on tablets.
  static const formMaxWidth = 440.0;

  /// Max width of centered empty/error messages.
  static const messageMaxWidth = 420.0;
}

/// Colours for lesson diagrams. The imported SVGs keep the variable names of
/// the original lesson pages (var(--ink), var(--moss), …); they are replaced
/// with these brand-book values (light theme — diagrams sit on a white card
/// in both themes, like a picture). Same table as the platform's
/// DIAGRAM_COLORS; track colours stay track colours.
abstract final class AppDiagram {
  static const colors = <String, String>{
    'card': '#FFFFFF',
    'paper': '#FFFCF6',
    'sand': '#F7F0E2',
    'rule': '#ECE1CB',
    'ink': '#241C10',
    'ink-soft': '#7C6F58',
    'amber': '#F2A93B',
    'amber-ink': '#835B20',
    'moss': '#3C6E58',
    'sky': '#2F7FC9',
    'sky-ink': '#1F5C93',
    'grape': '#8858B0',
    'grape-ink': '#6A3F8C',
    'code-bg': '#241C10',
    'code-fg': '#F7F0E2',
  };

  /// The card behind a diagram (brand card white).
  static const background = Color(0xFFFFFFFF);
}

/// Font families.
abstract final class AppFonts {
  static const display = 'Baloo 2';
  static const sans = 'Manrope';
  static const mono = 'JetBrains Mono';
}

/// Text styles from tokens.json plus the sizes the mockups use. Colors come
/// from the theme (DefaultTextStyle) unless a widget sets one from tokens.
abstract final class AppText {
  static const displayLg = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 32,
    height: 38 / 32,
    fontWeight: FontWeight.w700,
  );
  static const displayMd = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 28,
    height: 32 / 28,
    fontWeight: FontWeight.w700,
  );
  static const amount = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 32,
    height: 36 / 32,
    fontWeight: FontWeight.w700,
  );
  static const displaySm = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 24,
    height: 28 / 24,
    fontWeight: FontWeight.w700,
  );
  static const heading = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 22,
    height: 26 / 22,
    fontWeight: FontWeight.w700,
  );
  static const bodyLg = TextStyle(
    fontFamily: AppFonts.sans,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w500,
  );
  static const body = TextStyle(
    fontFamily: AppFonts.sans,
    fontSize: 15,
    height: 23 / 15,
    fontWeight: FontWeight.w400,
  );
  static const bodyStrong = TextStyle(
    fontFamily: AppFonts.sans,
    fontSize: 15,
    height: 20 / 15,
    fontWeight: FontWeight.w800,
  );
  static const statValue = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 26,
    height: 30 / 26,
    fontWeight: FontWeight.w700,
  );
  static const titleSm = TextStyle(
    fontFamily: AppFonts.sans,
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w800,
  );
  static const label = TextStyle(
    fontFamily: AppFonts.sans,
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w700,
  );
  static const labelLg = TextStyle(
    fontFamily: AppFonts.sans,
    fontSize: 14,
    height: 18 / 14,
    fontWeight: FontWeight.w700,
  );
  static const eventLine = TextStyle(
    fontFamily: AppFonts.sans,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w500,
  );
  static const metric = TextStyle(
    fontFamily: AppFonts.sans,
    fontSize: 15,
    height: 20 / 15,
    fontWeight: FontWeight.w600,
  );
  static const caption = TextStyle(
    fontFamily: AppFonts.sans,
    fontSize: 13,
    height: 19 / 13,
    fontWeight: FontWeight.w600,
  );
  static const chip = TextStyle(
    fontFamily: AppFonts.sans,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w800,
  );
  static const overline = TextStyle(
    fontFamily: AppFonts.sans,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w800,
    letterSpacing: 1,
  );
  static const button = TextStyle(
    fontFamily: AppFonts.sans,
    fontSize: 16,
    fontWeight: FontWeight.w800,
  );
  static const buttonLg = TextStyle(
    fontFamily: AppFonts.sans,
    fontSize: 17,
    fontWeight: FontWeight.w800,
  );
  static const input = TextStyle(
    fontFamily: AppFonts.sans,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
  static const code = TextStyle(
    fontFamily: AppFonts.mono,
    fontSize: 13,
    height: 20 / 13,
    fontWeight: FontWeight.w400,
  );
}

extension AppThemeContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}

class AppTheme {
  const AppTheme._();

  static ThemeData light() => _build(AppColors.light, Brightness.light);

  static ThemeData dark() => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors c, Brightness brightness) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.brand,
      onPrimary: c.onBrand,
      primaryContainer: c.brandTint,
      onPrimaryContainer: c.brandDeep,
      secondary: c.inverse,
      onSecondary: c.onInverse,
      error: c.danger,
      onError: c.surfaceCard,
      surface: c.surfacePage,
      onSurface: c.ink,
      onSurfaceVariant: c.inkMuted,
      surfaceContainerLowest: c.surfaceCard,
      surfaceContainerLow: c.surfaceCard,
      surfaceContainer: c.surfaceMuted,
      surfaceContainerHigh: c.surfaceMuted,
      surfaceContainerHighest: c.surfaceMuted,
      outline: c.border,
      outlineVariant: c.border,
      shadow: c.ink,
      inverseSurface: c.inverse,
      onInverseSurface: c.onInverse,
    );
    final roundedMd = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    );
    OutlineInputBorder inputBorder(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: color, width: AppSize.borderInput),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      extensions: [c],
      fontFamily: AppFonts.sans,
      scaffoldBackgroundColor: c.surfacePage,
      canvasColor: c.surfacePage,
      dividerColor: c.border,
      splashFactory: InkSparkle.splashFactory,
      textTheme: TextTheme(
        displaySmall: AppText.displayLg.copyWith(color: c.ink),
        headlineMedium: AppText.displayMd.copyWith(color: c.ink),
        headlineSmall: AppText.displaySm.copyWith(color: c.ink),
        titleLarge: AppText.heading.copyWith(color: c.ink),
        titleMedium: AppText.bodyStrong.copyWith(color: c.ink),
        bodyLarge: AppText.bodyLg.copyWith(color: c.ink),
        bodyMedium: AppText.body.copyWith(color: c.ink),
        bodySmall: AppText.caption.copyWith(color: c.inkMuted),
        labelLarge: AppText.label.copyWith(color: c.ink),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.surfacePage,
        foregroundColor: c.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppText.displaySm.copyWith(color: c.ink),
      ),
      cardTheme: CardThemeData(
        color: c.surfaceCard,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: c.border),
        ),
      ),
      dividerTheme: DividerThemeData(color: c.surfaceMuted, thickness: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.brand,
          foregroundColor: c.onBrand,
          disabledBackgroundColor: c.surfaceMuted,
          disabledForegroundColor: c.inkMuted,
          minimumSize: const Size.fromHeight(AppSize.buttonTall),
          textStyle: AppText.buttonLg,
          shape: roundedMd,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.ink,
          minimumSize: const Size.fromHeight(AppSize.button),
          textStyle: AppText.button,
          side: BorderSide(color: c.ink, width: AppSize.borderInput),
          shape: roundedMd,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.brandStrong,
          minimumSize: const Size(AppSize.touch, AppSize.touch),
          textStyle: AppText.label.copyWith(fontSize: 14),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: c.ink,
          minimumSize: const Size(AppSize.touch, AppSize.touch),
        ),
      ),
      iconTheme: IconThemeData(color: c.ink, size: AppSize.icon),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceCard,
        hintStyle: AppText.input.copyWith(color: c.inkMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpace.s4,
          vertical: AppSpace.s4,
        ),
        border: inputBorder(c.border),
        enabledBorder: inputBorder(c.border),
        focusedBorder: inputBorder(c.brand),
        errorBorder: inputBorder(c.danger),
        focusedErrorBorder: inputBorder(c.danger),
        disabledBorder: inputBorder(c.surfaceMuted),
        errorStyle: AppText.caption.copyWith(color: c.danger),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: c.ink,
        selectionColor: c.brand.withValues(alpha: 0.35),
        selectionHandleColor: c.brand,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.brand,
        linearTrackColor: c.surfaceMuted,
        circularTrackColor: c.surfaceMuted,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surfaceCard,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 72,
        indicatorColor: c.brandTint,
        indicatorShape: const StadiumBorder(),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => AppText.caption.copyWith(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w800
                : FontWeight.w700,
            color: states.contains(WidgetState.selected) ? c.ink : c.inkMuted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: AppSize.icon,
            color: states.contains(WidgetState.selected) ? c.ink : c.inkMuted,
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surfaceCard,
        surfaceTintColor: Colors.transparent,
        dragHandleColor: c.border,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.inverse,
        contentTextStyle: AppText.body.copyWith(color: c.onInverse),
        behavior: SnackBarBehavior.floating,
        shape: roundedMd,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.brand,
        foregroundColor: c.onBrand,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        extendedTextStyle: AppText.button,
        shape: roundedMd,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: AppText.input.copyWith(color: c.ink),
      ),
    );
  }
}
