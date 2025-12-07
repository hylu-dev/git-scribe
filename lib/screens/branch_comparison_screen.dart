import 'package:flutter/material.dart';
import '../services/github_service.dart';
import '../models/github_comparison.dart';
import '../widgets/navigation/app_header.dart';
import '../widgets/navigation/breadcrumbs.dart';
import '../widgets/expansion/commit_expansion_tile.dart';

/// Screen that displays branch overview with commits and file changes
class BranchOverviewScreen extends StatefulWidget {
  final String owner;
  final String repoName;
  final String branchName;

  const BranchOverviewScreen({
    super.key,
    required this.owner,
    required this.repoName,
    required this.branchName,
  });

  @override
  State<BranchOverviewScreen> createState() => _BranchOverviewScreenState();
}

class _BranchOverviewScreenState extends State<BranchOverviewScreen> {
  final GitHubService _githubService = GitHubService();
  GitHubComparison? _comparison;
  bool _isLoading = true;
  String? _errorMessage;
  String? _baseBranch;

  @override
  void initState() {
    super.initState();
    _loadComparison();
  }

  Future<void> _loadComparison() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get default branch first
      final defaultBranch = await _githubService.getDefaultBranch(
        widget.owner,
        widget.repoName,
      );
      _baseBranch = defaultBranch;

      // Compare branches
      final comparison = await _githubService.compareBranches(
        widget.owner,
        widget.repoName,
        defaultBranch,
        widget.branchName,
      );

      setState(() {
        _comparison = comparison;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          AppHeader(
            breadcrumbs: [
              const BreadcrumbItem(label: 'Repositories', route: '/home'),
              BreadcrumbItem(
                label: widget.repoName,
                route: '/repo/${widget.owner}/${widget.repoName}',
              ),
              BreadcrumbItem(label: widget.branchName, route: null),
            ],
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading comparison',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadComparison,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_comparison == null) {
      return const Center(child: Text('No comparison data available'));
    }

    return ListView(
      children: [
        // Summary header
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Branch Overview',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Base: $_baseBranch → Head: ${widget.branchName}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _buildSummaryChip(
                    'Status',
                    _comparison!.status.toUpperCase(),
                  ),
                  _buildSummaryChip('Commits', '${_comparison!.totalCommits}'),
                  _buildSummaryChip('Ahead', '${_comparison!.aheadBy}'),
                  _buildSummaryChip('Behind', '${_comparison!.behindBy}'),
                  _buildSummaryChip('Files', '${_comparison!.files.length}'),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Commits list with nested files
        if (_comparison!.commits.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: Text('No commits found')),
          )
        else
          ..._comparison!.commits.reversed.map(
            (commit) => CommitExpansionTile(commit: commit),
          ),
      ],
    );
  }

  Widget _buildSummaryChip(String label, String value) {
    return Chip(
      label: Text('$label: $value'),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
