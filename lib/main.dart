import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/theme_model.dart';
import 'themes/themes.dart';
import 'utils/env.dart';
import 'app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ensure Supabase is configured
  if (!Env.isConfigured) {
    debugPrint(
      'Warning: Supabase is not configured. Some features may not work.',
    );
  }

  // Initialize Supabase
  await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseAnonKey);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Initialize theme model
  final ThemeModel _themeModel = ThemeModel();

  @override
  void initState() {
    super.initState();
    // Listen to theme changes (add listener before initializing themes)
    _themeModel.addListener(_onThemeChanged);
    // Initialize with programming themes and load saved theme
    _initializeThemes();
  }

  Future<void> _initializeThemes() async {
    await _themeModel.initializeThemes(Themes.all);
  }

  @override
  void dispose() {
    _themeModel.removeListener(_onThemeChanged);
    _themeModel.dispose();
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  // Root widget of the application
  @override
  Widget build(BuildContext context) {
    return ThemeModelProvider(
      themeModel: _themeModel,
      child: MaterialApp.router(
        title: 'GitScribe',
        theme: _themeModel.theme,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

/// InheritedWidget to provide ThemeModel to the widget tree
class ThemeModelProvider extends InheritedWidget {
  final ThemeModel themeModel;

  const ThemeModelProvider({
    super.key,
    required this.themeModel,
    required super.child,
  });

  static ThemeModel of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<ThemeModelProvider>();
    if (provider == null) {
      throw Exception('ThemeModelProvider not found in widget tree');
    }
    return provider.themeModel;
  }

  @override
  bool updateShouldNotify(ThemeModelProvider oldWidget) {
    return themeModel != oldWidget.themeModel;
  }
}
