import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/theme_model.dart';
import 'themes/themes.dart';
import 'services/env.dart';
import 'services/ai_service.dart';
import 'app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file only if compile-time vars are not available
  if (Env.needsDotenv) {
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      // .env file not found - this is OK if using compile-time defines in release builds
      // The Env class will throw a helpful error if neither compile-time nor .env vars are available
    }
  }

  // Initialize Supabase
  await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseAnonKey);

  // Load saved AI provider configuration
  await AIService().loadSavedConfiguration();

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
