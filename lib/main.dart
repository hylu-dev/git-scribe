import 'package:flutter/material.dart';
import 'models/theme_model.dart';
import 'themes/themes.dart';

void main() {
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

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title, required this.themeModel});

  final String title;
  final ThemeModel themeModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                // Button action
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
