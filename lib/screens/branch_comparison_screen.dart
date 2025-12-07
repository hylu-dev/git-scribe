import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/github_service.dart';
import '../models/github_comparison.dart';
import '../widgets/app_header.dart';
import '../widgets/breadcrumbs.dart';

/// Screen that displays branch comparison results
class BranchComparisonScreen extends StatefulWidget {
  final String owner;
  final String repoName;
  final String branchName;

  const BranchComparisonScreen({
    super.key,
    required this.owner,
    required this.repoName,
    required this.branchName,
  });

  @override
  State<BranchComparisonScreen> createState() => _BranchComparisonScreenState();
}

class _BranchComparisonScreenState extends State<BranchComparisonScreen> {
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

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MMM d, y • h:mm a').format(date);
  }

  String _formatComparisonText() {
    if (_comparison == null) return 'No comparison data available';

    final buffer = StringBuffer();

    // Header
    buffer.writeln('Branch Comparison');
    buffer.writeln('=' * 80);
    buffer.writeln('Base Branch: $_baseBranch');
    buffer.writeln('Head Branch: ${widget.branchName}');
    buffer.writeln('Status: ${_comparison!.status.toUpperCase()}');
    buffer.writeln('');

    // Summary
    buffer.writeln('Summary');
    buffer.writeln('-' * 80);
    buffer.writeln('Total Commits: ${_comparison!.totalCommits}');
    buffer.writeln('Ahead by: ${_comparison!.aheadBy} commits');
    buffer.writeln('Behind by: ${_comparison!.behindBy} commits');
    buffer.writeln('Files Changed: ${_comparison!.files.length}');
    buffer.writeln('');

    // Commits with their diffs
    if (_comparison!.commits.isNotEmpty) {
      buffer.writeln('Commits with Diffs (${_comparison!.commits.length})');
      buffer.writeln('=' * 80);

      for (var i = 0; i < _comparison!.commits.length; i++) {
        final commit = _comparison!.commits[i];
        buffer.writeln('\n\nCOMMIT ${i + 1}/${_comparison!.commits.length}');
        buffer.writeln('=' * 80);
        buffer.writeln('SHA: ${commit.sha.substring(0, 7)}');
        buffer.writeln('Author: ${commit.author}');
        if (commit.date != null) {
          buffer.writeln('Date: ${_formatDate(commit.date)}');
        }
        buffer.writeln('Message:');
        buffer.writeln(commit.message);
        if (commit.url != null) {
          buffer.writeln('URL: ${commit.url}');
        }

        // Files changed in this commit
        if (commit.files.isNotEmpty) {
          buffer.writeln(
            '\nFiles Changed in this Commit (${commit.files.length}):',
          );
          buffer.writeln('-' * 80);

          for (var j = 0; j < commit.files.length; j++) {
            final file = commit.files[j];
            buffer.writeln('\n[${j + 1}] ${file.filename}');
            buffer.writeln('Status: ${file.status.toUpperCase()}');
            buffer.writeln(
              'Changes: +${file.additions} / -${file.deletions} (${file.changes} total)',
            );

            if (file.patch != null && file.patch!.isNotEmpty) {
              buffer.writeln('\nCode Changes:');
              buffer.writeln('=' * 80);
              buffer.writeln(file.patch);
              buffer.writeln('=' * 80);
            } else if (file.status != 'removed') {
              // GitHub API doesn't include patches for very large files
              buffer.writeln(
                '\nNote: Code changes not available (file may be too large)',
              );
            }

            if (j < commit.files.length - 1) {
              buffer.writeln('\n${'-' * 40}');
            }
          }
        } else {
          buffer.writeln('\nNo file changes in this commit');
        }

        if (i < _comparison!.commits.length - 1) {
          buffer.writeln('\n\n${'=' * 80}');
        }
      }
    }

    return buffer.toString();
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
              BreadcrumbItem(label: widget.repoName, route: null),
              BreadcrumbItem(label: widget.branchName, route: null),
            ],
            trailingAction: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _isLoading ? null : _loadComparison,
              tooltip: 'Refresh',
            ),
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SelectableText(
        _formatComparisonText(),
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontFamily: 'monospace', fontSize: 12),
      ),
    );
  }
}
