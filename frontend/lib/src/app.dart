import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/src/routing/app_router.dart';
import 'package:google_fonts/google_fonts.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // Core palette from CSS variables
  static const primary = Color(0xFF059669);
  static const accent = Color(0xFFf97316);
  static const background = Color(0xFFFAF8F5);
  static const muted = Color(0xFFF5F3F0);
  static const mutedForeground = Color(0xFF717182);
  static const foreground = Color(0xFF0A0A0B); // approx oklch(0.145 0 0)
  static const destructive = Color(0xFFD4183D);
  static const border = Color(0x14000000); // rgba(0,0,0,0.08)
  static const inputBackground = Color(0xFFF5F3F0);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    return MaterialApp.router(
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryTextTheme: GoogleFonts.robotoFlexTextTheme(),
        // ── Colour scheme ────────────────────────────────────────────
        colorScheme: const ColorScheme.light(
          primary: primary,
          onPrimary: Colors.white,
          secondary: accent,
          onSecondary: Colors.white,
          surface: Color(0xFFFFFFFF), // --card
          onSurface: foreground,
          surfaceContainerHighest: muted,
          onSurfaceVariant: mutedForeground,
          error: destructive,
          onError: Colors.white,
          outline: border,
        ),

        // ── Scaffold & canvas ─────────────────────────────────────────
        scaffoldBackgroundColor: background,
        canvasColor: background,
        dividerColor: border,

        // ── Typography (mirrors the CSS base layer) ───────────────────
        textTheme: const TextTheme(
          // h1 → text-2xl / medium
          headlineLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            height: 1.5,
            color: foreground,
          ),
          // h2 → text-xl / medium
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            height: 1.5,
            color: foreground,
          ),
          // h3 → text-lg / medium
          headlineSmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            height: 1.5,
            color: foreground,
          ),
          // h4 → text-base / medium
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.5,
            color: foreground,
          ),
          // label → text-base / medium
          labelLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.5,
            color: foreground,
          ),
          // body / input → text-base / normal
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.5,
            color: foreground,
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.5,
            color: foreground,
          ),
          bodySmall: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.5,
            color: mutedForeground,
          ),
        ),

        // ── Input fields ──────────────────────────────────────────────
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: inputBackground,
          hintStyle: const TextStyle(
            color: mutedForeground,
            fontWeight: FontWeight.w400,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), // --radius: 0.625rem
            borderSide: const BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: destructive),
          ),
        ),

        // ── Elevated button → primary ─────────────────────────────────
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: primary.withOpacity(0.5),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            elevation: 0,
          ),
        ),

        // ── Outlined button ───────────────────────────────────────────
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            side: const BorderSide(color: border),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),

        // ── Text button ───────────────────────────────────────────────
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primary,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),

        // ── FAB → accent ──────────────────────────────────────────────
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 2,
        ),

        // ── Card ──────────────────────────────────────────────────────
        cardTheme: CardThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: border),
          ),
          margin: EdgeInsets.zero,
        ),

        // ── App bar ───────────────────────────────────────────────────
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: foreground,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: foreground,
          ),
        ),

        // ── Chip ──────────────────────────────────────────────────────
        chipTheme: ChipThemeData(
          backgroundColor: muted,
          labelStyle: const TextStyle(
            color: foreground,
            fontWeight: FontWeight.w400,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: const BorderSide(color: border),
        ),

        // ── Switch ────────────────────────────────────────────────────
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? Colors.white
                : const Color(0xFFCBCED4),
          ),
          trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? primary
                : const Color(0xFFCBCED4),
          ),
        ),

        // ── Misc ──────────────────────────────────────────────────────
        unselectedWidgetColor: mutedForeground,
        splashColor: primary.withOpacity(0.08),
        highlightColor: primary.withOpacity(0.04),
      ),
    );
  }
}
