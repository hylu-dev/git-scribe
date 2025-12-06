import 'package:flutter/material.dart';
import '../models/github_branch.dart';
import 'branch_actions_sheet.dart';

/// Widget that displays a GitHub branch card
class BranchCard extends StatelessWidget {
  final GitHubBranch branch;

  const BranchCard({super.key, required this.branch});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(
          branch.isProtected ? Icons.lock : Icons.account_tree,
          color: branch.isProtected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        ),
        title: Text(
          branch.name,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: branch.sha != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    'SHA: ${branch.sha!.substring(0, 7)}...',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              )
            : null,
        trailing: branch.isProtected
            ? Chip(
                label: const Text('Protected'),
                padding: EdgeInsets.zero,
                labelPadding: const EdgeInsets.symmetric(horizontal: 8),
              )
            : null,
        onTap: () {
          BranchActionsSheet.show(context, branch);
        },
      ),
    );
  }
}
