import 'package:flutter/material.dart';

/// Reusable refresh button widget
/// Maintains consistent size whether loading or not
class RefreshButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;
  final String tooltip;

  const RefreshButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    this.tooltip = 'Refresh',
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: isLoading ? null : onPressed,
      tooltip: tooltip,
      icon: SizedBox(
        width: 20,
        height: 20,
        child: isLoading
            ? const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : const Icon(Icons.refresh, size: 20),
      ),
      label: SizedBox(
        width: 80, // Fixed width to prevent size changes
        child: Text(
          isLoading ? 'Loading...' : 'Refresh',
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

