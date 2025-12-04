import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/theme_model.dart';

/// Collection of classic programming themes inspired by popular code editors
class Themes {
  /// Flutter Default theme - Flutter's default Material 3 dark theme
  static AppTheme get flutterDefault => AppTheme(
    name: 'Default',
    description: 'Flutter\'s default Material 3 dark theme',
    theme: _buildFlutterDefault(),
  );

  /// Monokai theme - Classic dark theme with vibrant colors
  static AppTheme get monokai => AppTheme(
    name: 'Monokai',
    description: 'Classic dark theme with vibrant colors',
    theme: _buildMonokai(),
  );

  /// Dracula theme - Dark theme with purple and pink accents
  static AppTheme get dracula => AppTheme(
    name: 'Dracula',
    description: 'Dark theme with purple and pink accents',
    theme: _buildDracula(),
  );

  /// One Dark theme - Atom's popular dark theme
  static AppTheme get oneDark => AppTheme(
    name: 'One Dark',
    description: 'Atom\'s popular dark theme',
    theme: _buildOneDark(),
  );

  /// Solarized Dark theme - Carefully designed color palette
  static AppTheme get solarizedDark => AppTheme(
    name: 'Solarized Dark',
    description: 'Carefully designed color palette',
    theme: _buildSolarizedDark(),
  );

  /// Nord theme - Arctic, north-bluish color palette
  static AppTheme get nord => AppTheme(
    name: 'Nord',
    description: 'Arctic, north-bluish color palette',
    theme: _buildNord(),
  );

  /// GitHub Dark theme - GitHub's dark theme
  static AppTheme get githubDark => AppTheme(
    name: 'GitHub Dark',
    description: 'GitHub\'s dark theme',
    theme: _buildGitHubDark(),
  );

  /// VS Code Dark+ theme - Default VS Code dark theme
  static AppTheme get vsCodeDark => AppTheme(
    name: 'VS Code Dark+',
    description: 'Default VS Code dark theme',
    theme: _buildVSCodeDark(),
  );

  /// Get all programming themes
  static List<AppTheme> get all => [
    flutterDefault,
    monokai,
    dracula,
    oneDark,
    solarizedDark,
    nord,
    githubDark,
    vsCodeDark,
  ];

  // Flutter Default theme implementation
  static ThemeData _buildFlutterDefault() {
    final baseTheme = ThemeData.dark(useMaterial3: true);
    return baseTheme.copyWith(
      textTheme: GoogleFonts.firaCodeTextTheme(baseTheme.textTheme),
    );
  }

  // Monokai theme implementation
  static ThemeData _buildMonokai() {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF272822),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF66D9EF),
        secondary: Color(0xFFA6E22E),
        surface: Color(0xFF3E3D32),
        error: Color(0xFFF92672),
        onPrimary: Color(0xFF272822),
        onSecondary: Color(0xFF272822),
        onSurface: Color(0xFFF8F8F2),
        onError: Color(0xFFFFFFFF),
      ),
    );
    return baseTheme.copyWith(
      textTheme: GoogleFonts.firaCodeTextTheme(baseTheme.textTheme),
    );
  }

  // Dracula theme implementation
  static ThemeData _buildDracula() {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF282A36),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFBD93F9),
        secondary: Color(0xFF50FA7B),
        surface: Color(0xFF44475A),
        error: Color(0xFFFF5555),
        onPrimary: Color(0xFFF8F8F2),
        onSecondary: Color(0xFF282A36),
        onSurface: Color(0xFFF8F8F2),
        onError: Color(0xFFFFFFFF),
      ),
    );
    return baseTheme.copyWith(
      textTheme: GoogleFonts.firaCodeTextTheme(baseTheme.textTheme),
    );
  }

  // One Dark theme implementation
  static ThemeData _buildOneDark() {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF282C34),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF61AFEF),
        secondary: Color(0xFF98C379),
        surface: Color(0xFF353B45),
        error: Color(0xFFE06C75),
        onPrimary: Color(0xFFABB2BF),
        onSecondary: Color(0xFF282C34),
        onSurface: Color(0xFFABB2BF),
        onError: Color(0xFFFFFFFF),
      ),
    );
    return baseTheme.copyWith(
      textTheme: GoogleFonts.firaCodeTextTheme(baseTheme.textTheme),
    );
  }

  // Solarized Dark theme implementation
  static ThemeData _buildSolarizedDark() {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF002B36),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF268BD2),
        secondary: Color(0xFF859900),
        surface: Color(0xFF073642),
        error: Color(0xFFDC322F),
        onPrimary: Color(0xFFFDF6E3),
        onSecondary: Color(0xFF002B36),
        onSurface: Color(0xFF839496),
        onError: Color(0xFFFFFFFF),
      ),
    );
    return baseTheme.copyWith(
      textTheme: GoogleFonts.firaCodeTextTheme(baseTheme.textTheme),
    );
  }

  // Nord theme implementation
  static ThemeData _buildNord() {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF2E3440),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF5E81AC),
        secondary: Color(0xFFA3BE8C),
        surface: Color(0xFF3B4252),
        error: Color(0xFFBF616A),
        onPrimary: Color(0xFFECEFF4),
        onSecondary: Color(0xFF2E3440),
        onSurface: Color(0xFFD8DEE9),
        onError: Color(0xFFFFFFFF),
      ),
    );
    return baseTheme.copyWith(
      textTheme: GoogleFonts.firaCodeTextTheme(baseTheme.textTheme),
    );
  }

  // GitHub Dark theme implementation
  static ThemeData _buildGitHubDark() {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0D1117),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF58A6FF),
        secondary: Color(0xFF3FB950),
        surface: Color(0xFF161B22),
        error: Color(0xFFF85149),
        onPrimary: Color(0xFF0D1117),
        onSecondary: Color(0xFF0D1117),
        onSurface: Color(0xFFC9D1D9),
        onError: Color(0xFFFFFFFF),
      ),
    );
    return baseTheme.copyWith(
      textTheme: GoogleFonts.firaCodeTextTheme(baseTheme.textTheme),
    );
  }

  // VS Code Dark+ theme implementation
  static ThemeData _buildVSCodeDark() {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF1E1E1E),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF007ACC),
        secondary: Color(0xFF0E639C),
        surface: Color(0xFF252526),
        error: Color(0xFFF48771),
        onPrimary: Color(0xFFFFFFFF),
        onSecondary: Color(0xFFFFFFFF),
        onSurface: Color(0xFFCCCCCC),
        onError: Color(0xFFFFFFFF),
      ),
    );
    return baseTheme.copyWith(
      textTheme: GoogleFonts.firaCodeTextTheme(baseTheme.textTheme),
    );
  }
}
