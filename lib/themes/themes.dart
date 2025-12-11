import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/theme_model.dart';

/// Collection of classic programming themes inspired by popular code editors
class Themes {
  /// Flutter Default theme - Flutter's default Material 3 dark theme
  static AppTheme get flutterDefault => AppTheme(
    name: 'Default',
    description: 'Default Material 3 dark theme',
    theme: _buildFlutterDefault(),
  );

  /// Flutter Light theme - Flutter's default Material 3 light theme
  static AppTheme get flutterLight => AppTheme(
    name: 'Light',
    description: 'Default Material 3 light theme',
    theme: _buildFlutterLight(),
  );

  /// Gruvbox theme - Retro groove color scheme
  static AppTheme get gruvbox => AppTheme(
    name: 'Gruvbox',
    description: 'Retro groove color scheme',
    theme: _buildGruvbox(),
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

  /// Solarized Light theme - Light version of Solarized
  static AppTheme get solarizedLight => AppTheme(
    name: 'Solarized Light',
    description: 'Light version of Solarized palette',
    theme: _buildSolarizedLight(),
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

  /// Catppuccin Mocha theme - Warm dark theme
  static AppTheme get catppuccinMocha => AppTheme(
    name: 'Catppuccin Mocha',
    description: 'Warm dark theme with pastel colors',
    theme: _buildCatppuccinMocha(),
  );

  /// Catppuccin Latte theme - Warm light theme
  static AppTheme get catppuccinLatte => AppTheme(
    name: 'Catppuccin Latte',
    description: 'Warm light theme with pastel colors',
    theme: _buildCatppuccinLatte(),
  );

  /// Tokyo Night theme - Clean dark theme
  static AppTheme get tokyoNight => AppTheme(
    name: 'Tokyo Night',
    description: 'Clean dark theme with blue accents',
    theme: _buildTokyoNight(),
  );

  /// Ayu Dark theme - Modern dark theme
  static AppTheme get ayuDark => AppTheme(
    name: 'Ayu Dark',
    description: 'Modern dark theme with vibrant colors',
    theme: _buildAyuDark(),
  );

  /// Ayu Light theme - Modern light theme
  static AppTheme get ayuLight => AppTheme(
    name: 'Ayu Light',
    description: 'Modern light theme with vibrant colors',
    theme: _buildAyuLight(),
  );

  /// Tomorrow Night theme - Classic dark theme
  static AppTheme get tomorrowNight => AppTheme(
    name: 'Tomorrow Night',
    description: 'Classic dark theme with high contrast',
    theme: _buildTomorrowNight(),
  );

  /// PaperColor Dark theme - Minimalist dark theme
  static AppTheme get paperColorDark => AppTheme(
    name: 'PaperColor Dark',
    description: 'Minimalist dark theme',
    theme: _buildPaperColorDark(),
  );

  /// Everforest Dark theme - Soothing dark theme
  static AppTheme get everforestDark => AppTheme(
    name: 'Everforest Dark',
    description: 'Soothing dark theme with green tones',
    theme: _buildEverforestDark(),
  );

  /// Rose Pine theme - All natural pine theme
  static AppTheme get rosePine => AppTheme(
    name: 'Rosé Pine',
    description: 'All natural pine theme',
    theme: _buildRosePine(),
  );

  /// Get all programming themes in a logical order:
  /// 1. Material defaults
  /// 2. Popular editor/platform themes
  /// 3. Dark/light pairs grouped together
  /// 4. Other popular themes
  static List<AppTheme> get all => [
    // Material defaults
    flutterDefault,
    flutterLight,
    // Popular editor/platform themes
    vsCodeDark,
    githubDark,
    oneDark,
    // Very popular standalone themes
    dracula,
    nord,
    // Catppuccin (dark/light pair)
    catppuccinMocha,
    catppuccinLatte,
    // Solarized (dark/light pair)
    solarizedDark,
    solarizedLight,
    // Ayu (dark/light pair)
    ayuDark,
    ayuLight,
    // Other popular themes
    tokyoNight,
    gruvbox,
    monokai,
    tomorrowNight,
    everforestDark,
    rosePine,
    paperColorDark,
  ];

  // Flutter Default theme implementation
  static ThemeData _buildFlutterDefault() {
    final baseTheme = ThemeData.dark(useMaterial3: true);
    return baseTheme.copyWith(
      textTheme: GoogleFonts.firaCodeTextTheme(baseTheme.textTheme),
    );
  }

  // Flutter Light theme implementation
  static ThemeData _buildFlutterLight() {
    final baseTheme = ThemeData.light(useMaterial3: true);
    return baseTheme.copyWith(
      textTheme: GoogleFonts.firaCodeTextTheme(baseTheme.textTheme),
    );
  }

  // Gruvbox theme implementation - more accurate colors
  static ThemeData _buildGruvbox() {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF282828),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF458588), // Blue
        secondary: Color(0xFF98971A), // Green
        surface: Color(0xFF3C3836),
        error: Color(0xFFCC241D), // Red
        onPrimary: Color(0xFFEBDBB2), // Foreground
        onSecondary: Color(0xFF282828),
        onSurface: Color(0xFFEBDBB2),
        onError: Color(0xFFEBDBB2),
      ),
    );
    return baseTheme.copyWith(
      textTheme: GoogleFonts.firaCodeTextTheme(baseTheme.textTheme),
    );
  }

  // Monokai theme implementation - more accurate colors
  static ThemeData _buildMonokai() {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF272822),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF66D9EF), // Cyan
        secondary: Color(0xFFA6E22E), // Green
        surface: Color(0xFF3E3D32),
        error: Color(0xFFF92672), // Pink/Red
        onPrimary: Color(0xFF272822),
        onSecondary: Color(0xFF272822),
        onSurface: Color(0xFFF8F8F2), // Foreground
        onError: Color(0xFFF8F8F2),
      ),
    );
    return baseTheme.copyWith(
      textTheme: GoogleFonts.firaCodeTextTheme(baseTheme.textTheme),
    );
  }

  // Dracula theme implementation - more accurate colors
  static ThemeData _buildDracula() {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF282A36),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFBD93F9), // Purple
        secondary: Color(0xFF50FA7B), // Green
        surface: Color(0xFF44475A),
        error: Color(0xFFFF5555), // Red
        onPrimary: Color(0xFF282A36),
        onSecondary: Color(0xFF282A36),
        onSurface: Color(0xFFF8F8F2), // Foreground
        onError: Color(0xFFF8F8F2),
      ),
    );
    return baseTheme.copyWith(
      textTheme: GoogleFonts.firaCodeTextTheme(baseTheme.textTheme),
    );
  }

  // One Dark theme implementation - more accurate colors
  static ThemeData _buildOneDark() {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF282C34),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF61AFEF), // Blue
        secondary: Color(0xFF98C379), // Green
        surface: Color(0xFF353B45),
        error: Color(0xFFE06C75), // Red
        onPrimary: Color(0xFF282C34),
        onSecondary: Color(0xFF282C34),
        onSurface: Color(0xFFABB2BF), // Foreground
        onError: Color(0xFFABB2BF),
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

  // Solarized Light theme implementation
  static ThemeData _buildSolarizedLight() {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFFDF6E3),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF268BD2), // Blue
        secondary: Color(0xFF859900), // Green
        surface: Color(0xFFEEE8D5),
        error: Color(0xFFDC322F), // Red
        onPrimary: Color(0xFFFFFFFF),
        onSecondary: Color(0xFFFFFFFF),
        onSurface: Color(0xFF586E75), // Foreground
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

  // VS Code Dark+ theme implementation - more accurate colors
  static ThemeData _buildVSCodeDark() {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF1E1E1E),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF007ACC), // Blue
        secondary: Color(0xFF0E639C), // Darker blue
        surface: Color(0xFF252526),
        error: Color(0xFFF48771), // Orange-red
        onPrimary: Color(0xFFFFFFFF),
        onSecondary: Color(0xFFFFFFFF),
        onSurface: Color(0xFFD4D4D4), // Foreground
        onError: Color(0xFFFFFFFF),
      ),
    );
    return baseTheme.copyWith(
      textTheme: GoogleFonts.firaCodeTextTheme(baseTheme.textTheme),
    );
  }

  // Catppuccin Mocha theme implementation
  static ThemeData _buildCatppuccinMocha() {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF1E1E2E),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF89B4FA), // Blue
        secondary: Color(0xFFA6E3A1), // Green
        surface: Color(0xFF313244),
        error: Color(0xFFF38BA8), // Red
        onPrimary: Color(0xFF1E1E2E),
        onSecondary: Color(0xFF1E1E2E),
        onSurface: Color(0xFFCDD6F4), // Foreground
        onError: Color(0xFF1E1E2E),
      ),
    );
    return baseTheme.copyWith(
      textTheme: GoogleFonts.firaCodeTextTheme(baseTheme.textTheme),
    );
  }

  // Catppuccin Latte theme implementation
  static ThemeData _buildCatppuccinLatte() {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFEFF1F5),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF1E66F5), // Blue
        secondary: Color(0xFF40A02B), // Green
        surface: Color(0xFFDCE0E8),
        error: Color(0xFFD20F39), // Red
        onPrimary: Color(0xFFFFFFFF),
        onSecondary: Color(0xFFFFFFFF),
        onSurface: Color(0xFF4C4F69), // Foreground
        onError: Color(0xFFFFFFFF),
      ),
    );
    return baseTheme.copyWith(
      textTheme: GoogleFonts.firaCodeTextTheme(baseTheme.textTheme),
    );
  }

  // Tokyo Night theme implementation
  static ThemeData _buildTokyoNight() {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF1A1B26),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF7AA2F7), // Blue
        secondary: Color(0xFF9ECE6A), // Green
        surface: Color(0xFF24283B),
        error: Color(0xFFF7768E), // Red
        onPrimary: Color(0xFF1A1B26),
        onSecondary: Color(0xFF1A1B26),
        onSurface: Color(0xFFC0CAF5), // Foreground
        onError: Color(0xFF1A1B26),
      ),
    );
    return baseTheme.copyWith(
      textTheme: GoogleFonts.firaCodeTextTheme(baseTheme.textTheme),
    );
  }

  // Ayu Dark theme implementation
  static ThemeData _buildAyuDark() {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0F1419),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF39BAE6), // Cyan
        secondary: Color(0xFFAAD94C), // Green
        surface: Color(0xFF1C2325),
        error: Color(0xFFFF6B6B), // Red
        onPrimary: Color(0xFF0F1419),
        onSecondary: Color(0xFF0F1419),
        onSurface: Color(0xFFE6E1CF), // Foreground
        onError: Color(0xFF0F1419),
      ),
    );
    return baseTheme.copyWith(
      textTheme: GoogleFonts.firaCodeTextTheme(baseTheme.textTheme),
    );
  }

  // Ayu Light theme implementation
  static ThemeData _buildAyuLight() {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFFAFAFA),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF0099CC), // Blue
        secondary: Color(0xFF86B300), // Green
        surface: Color(0xFFF8F8F8),
        error: Color(0xFFFF3333), // Red
        onPrimary: Color(0xFFFFFFFF),
        onSecondary: Color(0xFFFFFFFF),
        onSurface: Color(0xFF5C6773), // Foreground
        onError: Color(0xFFFFFFFF),
      ),
    );
    return baseTheme.copyWith(
      textTheme: GoogleFonts.firaCodeTextTheme(baseTheme.textTheme),
    );
  }

  // Tomorrow Night theme implementation
  static ThemeData _buildTomorrowNight() {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF1D1F21),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF81A2BE), // Blue
        secondary: Color(0xFFB5BD68), // Yellow-green
        surface: Color(0xFF282A2E),
        error: Color(0xFFCC6666), // Red
        onPrimary: Color(0xFF1D1F21),
        onSecondary: Color(0xFF1D1F21),
        onSurface: Color(0xFFC5C8C6), // Foreground
        onError: Color(0xFF1D1F21),
      ),
    );
    return baseTheme.copyWith(
      textTheme: GoogleFonts.firaCodeTextTheme(baseTheme.textTheme),
    );
  }

  // PaperColor Dark theme implementation
  static ThemeData _buildPaperColorDark() {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF1C1C1C),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF0087D7), // Blue
        secondary: Color(0xFF00AF87), // Green
        surface: Color(0xFF262626),
        error: Color(0xFFD70000), // Red
        onPrimary: Color(0xFFFFFFFF),
        onSecondary: Color(0xFFFFFFFF),
        onSurface: Color(0xFFEEEEEE), // Foreground
        onError: Color(0xFFFFFFFF),
      ),
    );
    return baseTheme.copyWith(
      textTheme: GoogleFonts.firaCodeTextTheme(baseTheme.textTheme),
    );
  }

  // Everforest Dark theme implementation
  static ThemeData _buildEverforestDark() {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF2B3339),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF7FBBB3), // Teal
        secondary: Color(0xFFA7C080), // Green
        surface: Color(0xFF323C41),
        error: Color(0xFFE67E80), // Red
        onPrimary: Color(0xFF2B3339),
        onSecondary: Color(0xFF2B3339),
        onSurface: Color(0xFFD3C6AA), // Foreground
        onError: Color(0xFF2B3339),
      ),
    );
    return baseTheme.copyWith(
      textTheme: GoogleFonts.firaCodeTextTheme(baseTheme.textTheme),
    );
  }

  // Rosé Pine theme implementation
  static ThemeData _buildRosePine() {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF191724),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFEBBCBA), // Rose
        secondary: Color(0xFF9CCFD8), // Foam
        surface: Color(0xFF1F1D2E),
        error: Color(0xFFEB6F92), // Love
        onPrimary: Color(0xFF191724),
        onSecondary: Color(0xFF191724),
        onSurface: Color(0xFFE0DEF4), // Text
        onError: Color(0xFF191724),
      ),
    );
    return baseTheme.copyWith(
      textTheme: GoogleFonts.firaCodeTextTheme(baseTheme.textTheme),
    );
  }
}
