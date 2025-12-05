import 'package:flutter/material.dart';

/// Widget that displays a GitHub commit card
/// This is a placeholder structure for future commit cards
class CommitCard extends StatelessWidget {
  final String message;
  final String author;
  final String? sha;
  final DateTime? date;
  final VoidCallback? onTap;

  const CommitCard({
    super.key,
    required this.message,
    required this.author,
    this.sha,
    this.date,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(
          Icons.commit,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          message,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              author,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (sha != null) ...[
              const SizedBox(height: 4),
              Text(
                'SHA: ${sha!.substring(0, 7)}...',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (date != null) ...[
              const SizedBox(height: 4),
              Text(
                _formatDate(date!),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}

