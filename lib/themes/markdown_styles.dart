import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

/// Utility class for creating markdown style sheets that match the app theme
class MarkdownStyles {
  /// Creates a markdown style sheet based on the current theme
  static MarkdownStyleSheet fromTheme(ThemeData theme) {
    final onSurface = theme.colorScheme.onSurface;
    final surfaceContainer = theme.colorScheme.surfaceContainerHighest;
    final textTheme = theme.textTheme;

    return MarkdownStyleSheet(
      p: textTheme.bodyMedium?.copyWith(color: onSurface),
      h1: textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: onSurface,
      ),
      h2: textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: onSurface,
      ),
      h3: textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: onSurface,
      ),
      strong: textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: onSurface,
      ),
      em: textTheme.bodyMedium?.copyWith(
        fontStyle: FontStyle.italic,
        color: onSurface,
      ),
      code: textTheme.bodyMedium?.copyWith(
        fontFamily: 'monospace',
        color: onSurface,
        backgroundColor: surfaceContainer.withValues(alpha: 0.5),
      ),
      codeblockDecoration: BoxDecoration(
        color: surfaceContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      codeblockPadding: const EdgeInsets.all(12),
      listBullet: textTheme.bodyMedium?.copyWith(color: onSurface),
      blockquote: textTheme.bodyMedium?.copyWith(
        color: onSurface,
        fontStyle: FontStyle.italic,
      ),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: theme.colorScheme.primary, width: 4),
        ),
      ),
      blockquotePadding: const EdgeInsets.only(left: 16),
    );
  }
}
