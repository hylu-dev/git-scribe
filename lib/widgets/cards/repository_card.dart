import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/github_repository.dart';

/// Widget that displays a GitHub repository card
class RepositoryCard extends StatelessWidget {
  final GitHubRepository repo;
  final VoidCallback? onTap;

  const RepositoryCard({super.key, required this.repo, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(
          repo.isPrivate ? Icons.lock : Icons.code,
          color: repo.isPrivate
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        title: Text(
          repo.fullName,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (repo.description != null && repo.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                repo.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                if (repo.language != null) ...[
                  Icon(
                    Icons.circle,
                    size: 12,
                    color: _getLanguageColor(repo.language!),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    repo.language!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                ],
                Icon(
                  Icons.star_border,
                  size: 16,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  repo.stars.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.call_split,
                  size: 16,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  repo.forks.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        onTap:
            onTap ??
            () {
              // Navigate to repository branches screen
              final parts = repo.fullName.split('/');
              if (parts.length == 2) {
                context.goNamed(
                  'repository-branches',
                  pathParameters: {'owner': parts[0], 'name': parts[1]},
                );
              }
            },
      ),
    );
  }

  Color _getLanguageColor(String language) {
    // Simple color mapping for common languages
    final colors = {
      'Dart': Colors.blue,
      'JavaScript': Colors.yellow,
      'TypeScript': Colors.blue,
      'Python': Colors.green,
      'Java': Colors.orange,
      'C++': Colors.pink,
      'C': Colors.grey,
      'Go': Colors.cyan,
      'Rust': Colors.orange,
      'Swift': Colors.orange,
      'Kotlin': Colors.purple,
    };
    return colors[language] ?? Colors.grey;
  }
}
