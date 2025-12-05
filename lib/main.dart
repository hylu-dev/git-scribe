import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/theme_model.dart';
import 'themes/themes.dart';
import 'widgets/github_login_button.dart';
import 'services/env.dart';

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
    return MaterialApp(
      title: 'GitScribe',
      theme: _themeModel.theme,
      home: MyHomePage(title: 'GitScribe', themeModel: _themeModel),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.themeModel});

  final String title;
  final ThemeModel themeModel;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.title,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 24),
            GitHubLoginButton(
              onPressed: () {
                // TODO: Handle GitHub login
              },
            ),
          ],
        ),
      ),
    );
  }
}
