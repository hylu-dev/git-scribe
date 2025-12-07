import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Breadcrumb item
class BreadcrumbItem {
  final String label;
  final String? route;

  const BreadcrumbItem({required this.label, this.route});
}

/// Widget that displays breadcrumb navigation
class Breadcrumbs extends StatelessWidget {
  final List<BreadcrumbItem> items;

  const Breadcrumbs({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _buildBreadcrumbItem(context, items[i], i == items.length - 1),
            if (i < items.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildBreadcrumbItem(
    BuildContext context,
    BreadcrumbItem item,
    bool isLast,
  ) {
    final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: isLast
          ? Theme.of(context).colorScheme.onSurface
          : Theme.of(context).colorScheme.primary,
      fontWeight: isLast ? FontWeight.w500 : FontWeight.normal,
    );

    if (isLast || item.route == null) {
      return Text(item.label, style: textStyle);
    }

    return InkWell(
      onTap: () {
        if (item.route != null) {
          context.go(item.route!);
        }
      },
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(item.label, style: textStyle),
      ),
    );
  }
}
