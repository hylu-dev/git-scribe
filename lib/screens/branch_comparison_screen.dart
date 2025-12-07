import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart' as github_theme;
import 'package:flutter_highlight/themes/monokai.dart' as monokai_theme;
import 'package:flutter_highlight/themes/gruvbox-dark.dart'
    as gruvbox_dark_theme;
import 'package:flutter_highlight/themes/gruvbox-light.dart'
    as gruvbox_light_theme;
import '../services/github_service.dart';
import '../models/github_comparison.dart';
import '../widgets/app_header.dart';
import '../widgets/breadcrumbs.dart';
import '../widgets/commit_card.dart';
import '../main.dart';

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
  int? _selectedCommitIndex;

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

    return Row(
      children: [
        // Commit list
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary header
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Comparison Summary',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
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
                        _buildSummaryChip(
                          'Commits',
                          '${_comparison!.totalCommits}',
                        ),
                        _buildSummaryChip('Ahead', '${_comparison!.aheadBy}'),
                        _buildSummaryChip('Behind', '${_comparison!.behindBy}'),
                        _buildSummaryChip(
                          'Files',
                          '${_comparison!.files.length}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Commits list
              Expanded(
                child: _comparison!.commits.isEmpty
                    ? const Center(child: Text('No commits found'))
                    : ListView.builder(
                        itemCount: _comparison!.commits.length,
                        padding: const EdgeInsets.all(8),
                        itemBuilder: (context, index) {
                          final commit = _comparison!.commits[index];
                          return CommitCard(
                            commit: commit,
                            isSelected: _selectedCommitIndex == index,
                            onTap: () {
                              setState(() {
                                _selectedCommitIndex =
                                    _selectedCommitIndex == index
                                    ? null
                                    : index;
                              });
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        // Diff view
        Expanded(
          flex: 3,
          child: _selectedCommitIndex != null
              ? _buildDiffView(_comparison!.commits[_selectedCommitIndex!])
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.code,
                        size: 64,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Select a commit to view code changes',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
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

  Widget _buildDiffView(GitHubCommit commit) {
    if (commit.files.isEmpty) {
      return const Center(child: Text('No file changes in this commit'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Commit header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                commit.message.split('\n').first,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    commit.author,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(commit.date),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    commit.sha.substring(0, 7),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Files and diffs
        Expanded(
          child: ListView.builder(
            itemCount: commit.files.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final file = commit.files[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ExpansionTile(
                  leading: Icon(
                    _getFileStatusIcon(file.status),
                    color: _getFileStatusColor(file.status),
                  ),
                  title: Text(
                    file.filename,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      if (file.additions > 0)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.add,
                              size: 14,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '+${file.additions}',
                              style: const TextStyle(color: Colors.green),
                            ),
                          ],
                        ),
                      if (file.additions > 0 && file.deletions > 0)
                        const SizedBox(width: 16),
                      if (file.deletions > 0)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.remove,
                              size: 14,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '-${file.deletions}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      const SizedBox(width: 16),
                      Text(
                        file.status.toUpperCase(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  children: [
                    if (file.patch != null && file.patch!.isNotEmpty)
                      Container(
                        width: double.infinity,
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        child: SingleChildScrollView(
                          child: HighlightView(
                            file.patch!,
                            language: _detectLanguage(file.filename),
                            theme: _getHighlightTheme(context),
                            padding: const EdgeInsets.all(16),
                            textStyle: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                            ),
                          ),
                        ),
                      )
                    else if (file.status != 'removed')
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Code changes not available (file may be too large)',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                              ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _getFileStatusIcon(String status) {
    switch (status) {
      case 'added':
        return Icons.add_circle;
      case 'removed':
        return Icons.remove_circle;
      case 'renamed':
        return Icons.drive_file_rename_outline;
      default:
        return Icons.edit;
    }
  }

  Color _getFileStatusColor(String status) {
    switch (status) {
      case 'added':
        return Colors.green;
      case 'removed':
        return Colors.red;
      case 'renamed':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  /// Detect programming language from filename
  String _detectLanguage(String filename) {
    final extension = filename.split('.').last.toLowerCase();
    final languageMap = {
      'dart': 'dart',
      'js': 'javascript',
      'jsx': 'javascript',
      'ts': 'typescript',
      'tsx': 'typescript',
      'py': 'python',
      'java': 'java',
      'kt': 'kotlin',
      'swift': 'swift',
      'go': 'go',
      'rs': 'rust',
      'cpp': 'cpp',
      'cxx': 'cpp',
      'cc': 'cpp',
      'c': 'c',
      'h': 'c',
      'hpp': 'cpp',
      'cs': 'csharp',
      'php': 'php',
      'rb': 'ruby',
      'sh': 'bash',
      'bash': 'bash',
      'zsh': 'bash',
      'yaml': 'yaml',
      'yml': 'yaml',
      'json': 'json',
      'xml': 'xml',
      'html': 'html',
      'css': 'css',
      'scss': 'scss',
      'sass': 'sass',
      'md': 'markdown',
      'sql': 'sql',
      'dockerfile': 'dockerfile',
      'makefile': 'makefile',
    };
    return languageMap[extension] ?? 'diff';
  }

  /// Get appropriate highlight theme based on app theme
  Map<String, TextStyle> _getHighlightTheme(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final themeModel = ThemeModelProvider.of(context);
    final themeName = themeModel.currentTheme.name.toLowerCase();

    // Use gruvbox themes if gruvbox is selected
    if (themeName.contains('gruvbox')) {
      return brightness == Brightness.dark
          ? gruvbox_dark_theme.gruvboxDarkTheme
          : gruvbox_light_theme.gruvboxLightTheme;
    }

    // Default to GitHub theme for light, Monokai for dark
    return brightness == Brightness.dark
        ? monokai_theme.monokaiTheme
        : github_theme.githubTheme;
  }
}
