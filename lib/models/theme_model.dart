import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ThemeModel manages the current theme state of the application
class ThemeModel extends ChangeNotifier {
  static const String _themePreferenceKey = 'selected_theme_name';

  ThemeModel() {
    // _currentTheme is already initialized with a default theme
  }

  // Available themes collection
  final List<AppTheme> _themes = [];

  // Current theme
  AppTheme _currentTheme = AppTheme(
    name: 'Default',
    theme: ThemeData.dark(useMaterial3: true),
  );

  /// Get the current theme
  AppTheme get currentTheme => _currentTheme;

  /// Get all available themes
  List<AppTheme> get themes => List.unmodifiable(_themes);

  /// Set the current theme and save it to preferences
  Future<void> setTheme(AppTheme theme) async {
    if (_currentTheme != theme) {
      _currentTheme = theme;
      notifyListeners();

      // Save theme name to preferences
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_themePreferenceKey, theme.name);
      } catch (e) {
        // Silently fail if preferences can't be saved
        debugPrint('Failed to save theme preference: $e');
      }
    }
  }

  /// Temporarily preview a theme without saving to preferences
  void previewTheme(AppTheme theme) {
    if (_currentTheme != theme) {
      _currentTheme = theme;
      notifyListeners();
    }
  }

  /// Get the theme data
  ThemeData get theme => _currentTheme.theme;

  /// Initialize themes from a collection and load saved theme
  Future<void> initializeThemes(List<AppTheme> themes) async {
    _themes.clear();
    _themes.addAll(themes);

    // Try to load saved theme
    String? savedThemeName;
    try {
      final prefs = await SharedPreferences.getInstance();
      savedThemeName = prefs.getString(_themePreferenceKey);
    } catch (e) {
      debugPrint('Failed to load theme preference: $e');
    }

    // Find and set the saved theme, or default to first theme
    if (_themes.isNotEmpty) {
      if (savedThemeName != null) {
        final savedTheme = _themes.firstWhere(
          (theme) => theme.name == savedThemeName,
          orElse: () => _themes.first,
        );
        _currentTheme = savedTheme;
      } else {
        // No saved theme, use first theme
        _currentTheme = _themes.first;
      }
      notifyListeners();
    }
  }
}

/// Represents a single theme
class AppTheme {
  final String name;
  final String description;
  final ThemeData theme;

  const AppTheme({
    required this.name,
    this.description = '',
    required this.theme,
  });
}
