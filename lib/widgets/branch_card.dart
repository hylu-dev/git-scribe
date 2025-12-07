import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/github_branch.dart';
import 'branch_actions_sheet.dart';

/// Widget that displays a GitHub branch card
class BranchCard extends StatelessWidget {
  final GitHubBranch branch;
  final String owner;
  final String repoName;

  const BranchCard({
    super.key,
    required this.branch,
    required this.owner,
    required this.repoName,
  });

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d, y').format(date);
    }
  }

  String _truncateMessage(String? message, int maxLength) {
    if (message == null || message.isEmpty) return '';
    if (message.length <= maxLength) return message;
    // Get first line and truncate
    final firstLine = message.split('\n').first;
    if (firstLine.length <= maxLength) return firstLine;
    return '${firstLine.substring(0, maxLength)}...';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () {
          BranchActionsSheet.show(context, branch, owner, repoName);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with branch name and protection status
              Row(
                children: [
                  Icon(
                    branch.isProtected ? Icons.lock : Icons.account_tree,
                    size: 20,
                    color: branch.isProtected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      branch.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (branch.isProtected)
                    Chip(
                      label: const Text('Protected'),
                      padding: EdgeInsets.zero,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Commit information
              if (branch.sha != null || branch.commitMessage != null) ...[
                if (branch.commitMessage != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.commit,
                        size: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _truncateMessage(branch.commitMessage, 60),
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    if (branch.sha != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.tag,
                            size: 14,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            branch.sha!.substring(0, 7),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                    if (branch.commitAuthor != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person,
                            size: 14,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            branch.commitAuthor!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    if (branch.commitDate != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(branch.commitDate),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
