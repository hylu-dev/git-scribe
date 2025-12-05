import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/theme_model.dart';
import 'themes/themes.dart';
import 'services/env.dart';
import 'app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: '.env');

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
    // Initialize with programming themes (this will auto-select first theme)
    _themeModel.initializeThemes(Themes.all);
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
    return MaterialApp.router(
      title: 'GitScribe',
      theme: _themeModel.theme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
