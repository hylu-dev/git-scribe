import 'package:flutter/material.dart';

/// ThemeModel manages the current theme state of the application
class ThemeModel extends ChangeNotifier {
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

  /// Set the current theme
  void setTheme(AppTheme theme) {
    if (_currentTheme != theme) {
      _currentTheme = theme;
      notifyListeners();
    }
  }

  /// Get the theme data
  ThemeData get theme => _currentTheme.theme;

  /// Initialize themes from a collection
  void initializeThemes(List<AppTheme> themes) {
    _themes.clear();
    _themes.addAll(themes);
    if (_themes.isNotEmpty && _currentTheme.name == 'Default') {
      _currentTheme = _themes.first;
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
