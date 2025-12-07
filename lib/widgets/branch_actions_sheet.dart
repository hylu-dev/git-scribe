import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/github_branch.dart';

/// Bottom sheet for branch actions
class BranchActionsSheet {
  /// Shows a bottom sheet with branch action options
  static void show(
    BuildContext context,
    GitHubBranch branch,
    String owner,
    String repoName,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Branch Actions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    branch.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.summarize),
              title: const Text('Summarize'),
              subtitle: const Text('Compare branch with default branch'),
              onTap: () {
                Navigator.pop(context);
                context.goNamed(
                  'branch-comparison',
                  pathParameters: {
                    'owner': owner,
                    'name': repoName,
                    'branch': branch.name,
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.compare_arrows),
              title: const Text('Pull Request'),
              subtitle: const Text('Create or view pull request for this branch'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement pull request functionality
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

