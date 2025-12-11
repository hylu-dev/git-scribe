import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import '../services/github_service.dart';
import '../services/ai_service.dart';
import '../services/branch_summary_service.dart';
import '../services/github_access_guard.dart';
import '../models/github_comparison.dart';
import '../widgets/navigation/app_header.dart';
import '../widgets/navigation/breadcrumbs.dart';
import '../widgets/expansion/commit_expansion_tile.dart';
import '../widgets/expansion/file_expansion_tile.dart';
import '../widgets/common/toast.dart';
import '../widgets/common/refresh_button.dart';
import '../themes/markdown_styles.dart';

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
  final AIService _aiService = AIService();
  late final BranchSummaryService _branchSummaryService;
  GitHubComparison? _comparison;
  bool _isLoading = true;
  String? _errorMessage;
  String? _baseBranch;
  bool _isGeneratingSummary = false;
  String? _aiSummary;
  bool _isSummaryExpanded = false;
  GitHubCommit? _selectedCommit; // Selected commit in wide mode

  // Layout constants
  static const double _wideLayoutBreakpoint = 800.0;
  static const double _fabBottomPadding = 80.0;
  static const double _rightColumnMinWidth = 300.0;
  static const double _rightColumnMaxWidthRatio = 1.7;

  @override
  void initState() {
    super.initState();
    _branchSummaryService = BranchSummaryService(_aiService);
    _loadComparison();
  }

  Future<void> _loadComparison({bool forceRefresh = false}) async {
    if (!await GitHubAccessGuard.ensureAccess(context, mounted: mounted)) {
      return;
    }

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

      // Compare branches (uses cache if available)
      final comparison = await _githubService.compareBranches(
        widget.owner,
        widget.repoName,
        defaultBranch,
        widget.branchName,
        forceRefresh: forceRefresh,
      );

      setState(() {
        _comparison = comparison;
        _isLoading = false;
      });

      // Load cached summary if available (but don't auto-expand)
      _loadCachedSummary();
    } catch (e) {
      final errorMessage = e.toString();

      // For other errors, show the error message as before
      setState(() {
        _errorMessage = errorMessage;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCachedSummary() async {
    if (_comparison == null) return;

    try {
      // Try to get cached summary (won't generate new one)
      final cachedSummary = await _branchSummaryService.generateSummary(
        _comparison!,
        forceRefresh: false,
      );
      if (mounted) {
        setState(() {
          _aiSummary = cachedSummary;
          // Don't auto-expand cached summaries
          _isSummaryExpanded = false;
        });
      }
    } catch (_) {
      // No cached summary available, that's fine
      // User can click generate to create one
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: RefreshButton(
        isLoading: _isLoading,
        onPressed: () => _loadComparison(forceRefresh: true),
        tooltip: 'Refresh comparison',
      ),
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
      return _buildErrorState();
    }

    if (_comparison == null) {
      return const Center(child: Text('No comparison data available'));
    }

    final isWideLayout =
        MediaQuery.of(context).size.width >= _wideLayoutBreakpoint;
    return isWideLayout ? _buildWideLayout() : _buildMobileLayout();
  }

  Widget _buildErrorState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text('Error loading comparison', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
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

  Widget _buildMobileLayout() {
    return ListView(
      padding: const EdgeInsets.only(bottom: _fabBottomPadding),
      children: [
        _buildSummaryHeader(),
        const Divider(height: 1),
        _buildAISummarySection(),
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

  Widget _buildWideLayout() {
    return Padding(
      padding: const EdgeInsets.only(bottom: _fabBottomPadding),
      child: Column(
        children: [
          _buildSummaryHeader(),
          const Divider(height: 1),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildCommitsList()),
                const VerticalDivider(width: 1),
                _buildRightColumn(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommitsList() {
    if (_comparison!.commits.isEmpty) {
      return const Center(child: Text('No commits found'));
    }

    final commits = _comparison!.commits.reversed.toList();
    return ListView.builder(
      itemCount: commits.length,
      itemBuilder: (context, index) => _buildWideModeCommitItem(commits[index]),
    );
  }

  Widget _buildRightColumn() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final maxWidth = screenWidth / _rightColumnMaxWidthRatio;
        final width = maxWidth.clamp(_rightColumnMinWidth, maxWidth);

        return SizedBox(
          width: width,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAISummarySection(showDivider: false),
                if (_selectedCommit != null) ...[
                  const SizedBox(height: 24),
                  _buildFileChangesSection(),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryHeader() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Branch Overview',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Base: $_baseBranch → Head: ${widget.branchName}',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildSummaryChip('Status', _comparison!.status.toUpperCase()),
              _buildSummaryChip('Commits', '${_comparison!.totalCommits}'),
              _buildSummaryChip('Ahead', '${_comparison!.aheadBy}'),
              _buildSummaryChip('Behind', '${_comparison!.behindBy}'),
              _buildSummaryChip('Files', '${_comparison!.files.length}'),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _isGeneratingSummary ? null : _generateAISummary,
            icon: _isGeneratingSummary
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(
              _isGeneratingSummary ? 'Generating...' : 'Generate AI Summary',
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAISummarySection({bool showDivider = true}) {
    if (_aiSummary == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: ExpansionTile(
            initiallyExpanded: _isSummaryExpanded,
            onExpansionChanged: (expanded) {
              setState(() {
                _isSummaryExpanded = expanded;
              });
            },
            shape: const RoundedRectangleBorder(side: BorderSide.none),
            collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
            leading: Icon(
              Icons.auto_awesome,
              color: theme.colorScheme.onSurface,
            ),
            title: LayoutBuilder(
              builder: (context, constraints) {
                final showLabels = constraints.maxWidth > 400;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'AI Summary',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildCopyButton(
                          label: 'Copy Text',
                          icon: Icons.content_copy,
                          onPressed: () =>
                              _copyToClipboard(_aiSummary!, isMarkdown: false),
                          showLabel: showLabels,
                        ),
                        const SizedBox(width: 8),
                        _buildCopyButton(
                          label: 'Copy Markdown',
                          icon: Icons.code,
                          onPressed: () =>
                              _copyToClipboard(_aiSummary!, isMarkdown: true),
                          showLabel: showLabels,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: MarkdownBody(
                  data: _aiSummary!,
                  styleSheet: MarkdownStyles.fromTheme(theme),
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }

  Widget _buildCopyButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    bool showLabel = true,
  }) {
    if (showLabel) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          minimumSize: const Size(0, 32),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );
    } else {
      return Tooltip(
        message: label,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.all(12),
            minimumSize: const Size(32, 32),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Icon(icon, size: 16),
        ),
      );
    }
  }

  Widget _buildSummaryChip(String label, String value) {
    return Chip(
      label: Text('$label: $value'),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Future<void> _generateAISummary() async {
    if (_comparison == null) return;

    setState(() {
      _isGeneratingSummary = true;
      _aiSummary = null;
    });

    try {
      // Always generate a new summary when button is clicked
      final summary = await _branchSummaryService.generateSummary(
        _comparison!,
        forceRefresh: true,
      );
      if (mounted) {
        setState(() {
          _aiSummary = summary;
          _isGeneratingSummary = false;
          // Auto-expand when generating a new summary
          _isSummaryExpanded = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGeneratingSummary = false;
        });
        Toast.error(context, e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  Widget _buildWideModeCommitItem(GitHubCommit commit) {
    final theme = Theme.of(context);
    final isSelected = _selectedCommit?.sha == commit.sha;
    final date = commit.date != null
        ? DateFormat('MMM d, y • h:mm a').format(commit.date!)
        : '';

    return InkWell(
      onTap: () {
        setState(() {
          _selectedCommit = isSelected ? null : commit;
        });
      },
      child: Container(
        color: isSelected
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : null,
        child: ListTile(
          leading: Icon(Icons.commit, color: theme.colorScheme.primary),
          title: Text(
            commit.message.split('\n').first,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: _buildCommitSubtitle(commit, date, theme),
          trailing: isSelected
              ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
              : const Icon(Icons.chevron_right),
        ),
      ),
    );
  }

  Widget _buildCommitSubtitle(
    GitHubCommit commit,
    String date,
    ThemeData theme,
  ) {
    final mutedColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final textStyle = theme.textTheme.bodySmall;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.person, size: 14, color: mutedColor),
            const SizedBox(width: 4),
            Text(commit.author, style: textStyle),
            const SizedBox(width: 16),
            Icon(Icons.access_time, size: 14, color: mutedColor),
            const SizedBox(width: 4),
            Text(date, style: textStyle),
            const SizedBox(width: 16),
            Text(
              commit.sha.substring(0, 7),
              style: textStyle?.copyWith(fontFamily: 'monospace'),
            ),
          ],
        ),
        if (commit.files.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            '${commit.files.length} file${commit.files.length > 1 ? 's' : ''} changed',
            style: textStyle,
          ),
        ],
      ],
    );
  }

  Widget _buildFileChangesSection() {
    if (_selectedCommit == null || _selectedCommit!.files.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Icon(Icons.code, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'File Changes',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ..._selectedCommit!.files.map((file) => FileExpansionTile(file: file)),
      ],
    );
  }

  Future<void> _copyToClipboard(String text, {required bool isMarkdown}) async {
    String contentToCopy = text;

    if (!isMarkdown) {
      // Strip markdown formatting to get plain text
      contentToCopy = _stripMarkdown(text);
    }

    await Clipboard.setData(ClipboardData(text: contentToCopy));
    if (mounted) {
      Toast.success(
        context,
        isMarkdown
            ? 'Markdown copied to clipboard'
            : 'Text copied to clipboard',
      );
    }
  }

  String _stripMarkdown(String markdown) {
    // Remove markdown headers
    String text = markdown.replaceAll(
      RegExp(r'^#{1,6}\s+', multiLine: true),
      '',
    );
    // Remove bold/italic
    text = text.replaceAll(RegExp(r'\*\*([^*]+)\*\*', multiLine: true), r'$1');
    text = text.replaceAll(RegExp(r'\*([^*]+)\*', multiLine: true), r'$1');
    text = text.replaceAll(RegExp(r'__([^_]+)__', multiLine: true), r'$1');
    text = text.replaceAll(RegExp(r'_([^_]+)_', multiLine: true), r'$1');
    // Remove code blocks
    text = text.replaceAll(RegExp(r'```[\s\S]*?```', multiLine: true), '');
    // Remove inline code
    text = text.replaceAll(RegExp(r'`([^`]+)`', multiLine: true), r'$1');
    // Remove links but keep text
    text = text.replaceAll(
      RegExp(r'\[([^\]]+)\]\([^\)]+\)', multiLine: true),
      r'$1',
    );
    // Remove images
    text = text.replaceAll(
      RegExp(r'!\[([^\]]*)\]\([^\)]+\)', multiLine: true),
      '',
    );
    // Remove list markers
    text = text.replaceAll(RegExp(r'^[\s]*[-*+]\s+', multiLine: true), '');
    text = text.replaceAll(RegExp(r'^[\s]*\d+\.\s+', multiLine: true), '');
    // Remove blockquotes
    text = text.replaceAll(RegExp(r'^>\s+', multiLine: true), '');
    // Clean up multiple newlines
    text = text.replaceAll(RegExp(r'\n{3,}', multiLine: true), '\n\n');
    // Trim whitespace
    return text.trim();
  }
}
