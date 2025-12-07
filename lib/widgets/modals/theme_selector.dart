import 'package:flutter/material.dart';
import '../../models/theme_model.dart';
import '../../main.dart';

/// Widget for selecting themes via a bottom sheet
class ThemeSelector {
  /// Shows a bottom sheet with theme selection options
  static void show(BuildContext context) {
    ThemeModel themeModel;
    try {
      themeModel = ThemeModelProvider.of(context);
    } catch (e) {
      // If ThemeModelProvider is not available, show an error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Theme selection is not available')),
      );
      return;
    }

    final currentTheme = themeModel.currentTheme;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Select Theme',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: themeModel.themes.length,
                itemBuilder: (context, index) {
                  final theme = themeModel.themes[index];
                  final isSelected = theme.name == currentTheme.name;

                  return ListTile(
                    leading: Icon(
                      isSelected ? Icons.check_circle : Icons.circle_outlined,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    title: Text(theme.name),
                    subtitle: theme.description.isNotEmpty
                        ? Text(
                            theme.description,
                            style: Theme.of(context).textTheme.bodySmall,
                          )
                        : null,
                    selected: isSelected,
                    onTap: () {
                      themeModel.setTheme(theme);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
