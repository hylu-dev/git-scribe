import 'package:flutter/material.dart';

/// Reusable toast notification utility
/// Matches the style of the existing success notifications in the app
class Toast {
  /// Show a success toast (green background, simple text)
  static void success(BuildContext context, String message) {
    if (!context.mounted) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.hideCurrentSnackBar();
    scaffoldMessenger.showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  /// Show an error toast (red background, simple text)
  static void error(BuildContext context, String message) {
    if (!context.mounted) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.hideCurrentSnackBar();
    scaffoldMessenger.showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  /// Show an info toast (theme surface color, simple text)
  static void info(BuildContext context, String message) {
    if (!context.mounted) return;
    final theme = Theme.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.hideCurrentSnackBar();
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
      ),
    );
  }
}
