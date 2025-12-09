import 'package:flutter/material.dart';
import '../../models/theme_model.dart';
import '../../main.dart';
import '../common/toast.dart';

/// Widget for selecting themes via a bottom sheet with hover preview
class ThemeSelector {
  /// Shows a bottom sheet with theme selection options
  static void show(BuildContext context) {
    ThemeModel themeModel;
    try {
      themeModel = ThemeModelProvider.of(context);
    } catch (e) {
      // If ThemeModelProvider is not available, show an error
      Toast.error(context, 'Theme selection is not available');
      return;
    }

    final originalTheme = themeModel.currentTheme;

    showModalBottomSheet(
      context: context,
      builder: (context) => _ThemeSelectorContent(
        themeModel: themeModel,
        originalTheme: originalTheme,
      ),
    ).then((_) {
      // If modal was dismissed without selecting, revert to original theme
      // (only if current theme is different from original, meaning user was previewing)
      if (themeModel.currentTheme.name != originalTheme.name) {
        themeModel.previewTheme(originalTheme);
      }
    });
  }
}

/// Stateful widget for theme selector with hover preview
class _ThemeSelectorContent extends StatefulWidget {
  final ThemeModel themeModel;
  final AppTheme originalTheme;

  const _ThemeSelectorContent({
    required this.themeModel,
    required this.originalTheme,
  });

  @override
  State<_ThemeSelectorContent> createState() => _ThemeSelectorContentState();
}

class _ThemeSelectorContentState extends State<_ThemeSelectorContent> {
  bool _themeCommitted = false;
  AppTheme? _hoveredTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              itemCount: widget.themeModel.themes.length,
              itemBuilder: (context, index) {
                final theme = widget.themeModel.themes[index];
                final isCurrentlySelected =
                    theme.name == widget.originalTheme.name;

                return MouseRegion(
                  onEnter: (_) {
                    setState(() {
                      _hoveredTheme = theme;
                    });
                    // Temporarily preview the theme on hover
                    widget.themeModel.previewTheme(theme);
                  },
                  onExit: (_) {
                    setState(() {
                      _hoveredTheme = null;
                    });
                    // Revert to original theme if not committed
                    // If moving to another item, its onEnter will fire immediately
                    if (!_themeCommitted) {
                      widget.themeModel.previewTheme(widget.originalTheme);
                    }
                  },
                  child: ListTile(
                    leading: Icon(
                      isCurrentlySelected
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      color: isCurrentlySelected
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
                    selected: isCurrentlySelected,
                    onTap: () {
                      // Commit the theme selection
                      _themeCommitted = true;
                      widget.themeModel.setTheme(theme);
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
