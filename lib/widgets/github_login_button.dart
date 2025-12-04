import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// A button widget for GitHub login
class GitHubLoginButton extends StatelessWidget {
  const GitHubLoginButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: const FaIcon(FontAwesomeIcons.github, size: 20),
      label: const Text('Log in with GitHub'),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }
}
