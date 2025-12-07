import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/github_comparison.dart';
import 'file_expansion_tile.dart';

/// Widget that displays a commit as an expansion tile with nested file changes
class CommitExpansionTile extends StatelessWidget {
  final GitHubCommit commit;

  const CommitExpansionTile({
    super.key,
    required this.commit,
  });

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MMM d, y • h:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: Icon(
        Icons.commit,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        commit.message.split('\n').first,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.person,
                size: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 4),
              Text(
                commit.author,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.access_time,
                size: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 4),
              Text(
                _formatDate(commit.date),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 16),
              Text(
                commit.sha.substring(0, 7),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          if (commit.files.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '${commit.files.length} file${commit.files.length > 1 ? 's' : ''} changed',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
      children: [
        if (commit.files.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No file changes in this commit'),
          )
        else
          ...commit.files.map((file) => FileExpansionTile(file: file)),
      ],
    );
  }
}

