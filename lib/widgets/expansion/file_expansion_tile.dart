import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart' as github_theme;
import 'package:flutter_highlight/themes/monokai.dart' as monokai_theme;
import 'package:flutter_highlight/themes/gruvbox-dark.dart'
    as gruvbox_dark_theme;
import 'package:flutter_highlight/themes/gruvbox-light.dart'
    as gruvbox_light_theme;
import 'package:google_fonts/google_fonts.dart';
import '../../models/github_comparison.dart';
import '../../main.dart';

/// Widget that displays a file change as an expansion tile with code diff
class FileExpansionTile extends StatelessWidget {
  final GitHubFileChange file;

  const FileExpansionTile({super.key, required this.file});

  IconData _getFileStatusIcon(String status) {
    switch (status) {
      case 'added':
        return Icons.add_circle;
      case 'removed':
        return Icons.remove_circle;
      case 'renamed':
        return Icons.drive_file_rename_outline;
      default:
        return Icons.edit;
    }
  }

  Color _getFileStatusColor(String status) {
    switch (status) {
      case 'added':
        return Colors.green;
      case 'removed':
        return Colors.red;
      case 'renamed':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  /// Detect programming language from filename
  String _detectLanguage(String filename) {
    final extension = filename.split('.').last.toLowerCase();
    final languageMap = {
      'dart': 'dart',
      'js': 'javascript',
      'jsx': 'javascript',
      'ts': 'typescript',
      'tsx': 'typescript',
      'py': 'python',
      'java': 'java',
      'kt': 'kotlin',
      'swift': 'swift',
      'go': 'go',
      'rs': 'rust',
      'cpp': 'cpp',
      'cxx': 'cpp',
      'cc': 'cpp',
      'c': 'c',
      'h': 'c',
      'hpp': 'cpp',
      'cs': 'csharp',
      'php': 'php',
      'rb': 'ruby',
      'sh': 'bash',
      'bash': 'bash',
      'zsh': 'bash',
      'yaml': 'yaml',
      'yml': 'yaml',
      'json': 'json',
      'xml': 'xml',
      'html': 'html',
      'css': 'css',
      'scss': 'scss',
      'sass': 'sass',
      'md': 'markdown',
      'sql': 'sql',
      'dockerfile': 'dockerfile',
      'makefile': 'makefile',
    };
    return languageMap[extension] ?? 'diff';
  }

  /// Get appropriate highlight theme based on app theme
  Map<String, TextStyle> _getHighlightTheme(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final themeModel = ThemeModelProvider.of(context);
    final themeName = themeModel.currentTheme.name.toLowerCase();

    // Use gruvbox themes if gruvbox is selected
    if (themeName.contains('gruvbox')) {
      return brightness == Brightness.dark
          ? gruvbox_dark_theme.gruvboxDarkTheme
          : gruvbox_light_theme.gruvboxLightTheme;
    }

    // Default to GitHub theme for light, Monokai for dark
    return brightness == Brightness.dark
        ? monokai_theme.monokaiTheme
        : github_theme.githubTheme;
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: Icon(
        _getFileStatusIcon(file.status),
        color: _getFileStatusColor(file.status),
        size: 20,
      ),
      title: Text(
        file.filename,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Row(
        children: [
          if (file.additions > 0)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add, size: 14, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  '+${file.additions}',
                  style: const TextStyle(color: Colors.green),
                ),
              ],
            ),
          if (file.additions > 0 && file.deletions > 0)
            const SizedBox(width: 16),
          if (file.deletions > 0)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.remove, size: 14, color: Colors.red),
                const SizedBox(width: 4),
                Text(
                  '-${file.deletions}',
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          const SizedBox(width: 16),
          Text(
            file.status.toUpperCase(),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      children: [
        if (file.patch != null && file.patch!.isNotEmpty)
          Container(
            width: double.infinity,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: SingleChildScrollView(
              child: HighlightView(
                file.patch!,
                language: _detectLanguage(file.filename),
                theme: _getHighlightTheme(context),
                padding: const EdgeInsets.all(16),
                textStyle: GoogleFonts.firaCode(fontSize: 14),
              ),
            ),
          )
        else if (file.status != 'removed')
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Code changes not available (file may be too large)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
      ],
    );
  }
}
