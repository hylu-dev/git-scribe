import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../services/github_service.dart';
import '../services/ai_service.dart';
import '../services/branch_summary_service.dart';
import '../models/github_comparison.dart';
import '../widgets/navigation/app_header.dart';
import '../widgets/navigation/breadcrumbs.dart';
import '../widgets/expansion/commit_expansion_tile.dart';
import '../widgets/expansion/file_expansion_tile.dart';
import '../widgets/common/toast.dart';
import '../widgets/common/refresh_button.dart';

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

  @override
  void initState() {
    super.initState();
    _branchSummaryService = BranchSummaryService(_aiService);
    _loadComparison();
  }

  Future<void> _loadComparison({bool forceRefresh = false}) async {
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
      
      // Check if it's a token-related error
      if (errorMessage.contains('No GitHub access token') ||
          errorMessage.contains('Unauthorized') ||
          errorMessage.contains('sign in again')) {
        // Show toast and redirect to login
        if (mounted) {
          Toast.error(
            context,
            'Please sign in to access branch comparison',
          );
          // Redirect to login after a brief delay to allow toast to show
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              context.go('/login');
            }
          });
        }
        return;
      }
      
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

    // Check if we should use wide layout (tablet/desktop)
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideLayout = screenWidth >= 800;

    if (isWideLayout) {
      return _buildWideLayout();
    } else {
      return _buildMobileLayout();
    }
  }

  Widget _buildMobileLayout() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        0,
        0,
        0,
        80,
      ), // Extra bottom padding for FAB
      children: [
        _buildSummaryHeader(),
        const Divider(height: 1),
        _buildAISummarySection(),
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

  Widget _buildWideLayout() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        0,
        0,
        0,
        80,
      ), // Extra bottom padding for FAB
      child: Column(
        children: [
          // Summary header at top
          _buildSummaryHeader(),
          const Divider(height: 1),
          // Two-column layout: Commits on left, AI Summary and File Changes on right
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column: Commits (can expand wider)
                Expanded(
                  child: _comparison!.commits.isEmpty
                      ? const Center(child: Text('No commits found'))
                      : ListView.builder(
                          itemCount: _comparison!.commits.length,
                          itemBuilder: (context, index) {
                            final commit =
                                _comparison!.commits[_comparison!
                                        .commits
                                        .length -
                                    1 -
                                    index];
                            return _buildWideModeCommitItem(commit);
                          },
                        ),
                ),
                const VerticalDivider(width: 1),
                // Right column: AI Summary and File Changes
                SizedBox(
                  width: 800,
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader() {
    return Container(
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

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.2),
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
            leading: Icon(
              Icons.auto_awesome,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            title: Row(
              children: [
                Text(
                  'AI Summary',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () =>
                      _copyToClipboard(_aiSummary!, isMarkdown: false),
                  icon: const Icon(Icons.content_copy, size: 16),
                  label: const Text('Copy Text'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () =>
                      _copyToClipboard(_aiSummary!, isMarkdown: true),
                  icon: const Icon(Icons.code, size: 16),
                  label: const Text('Copy Markdown'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: MarkdownBody(
                  data: _aiSummary!,
                  styleSheet: MarkdownStyleSheet(
                    p: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    h1: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    h2: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    h3: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    strong: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    em: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    code: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                      color: Theme.of(context).colorScheme.onSurface,
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.5),
                    ),
                    codeblockDecoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    codeblockPadding: const EdgeInsets.all(12),
                    listBullet: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                    blockquote: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontStyle: FontStyle.italic,
                        ),
                    blockquoteDecoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 4,
                        ),
                      ),
                    ),
                    blockquotePadding: const EdgeInsets.only(left: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1),
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
            ? Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.3)
            : null,
        child: ListTile(
          leading: Icon(
            Icons.commit,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(
            commit.message.split('\n').first,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
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
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(date, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(width: 16),
                  Text(
                    commit.sha.substring(0, 7),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
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
          trailing: isSelected
              ? Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                )
              : const Icon(Icons.chevron_right),
        ),
      ),
    );
  }

  Widget _buildFileChangesSection() {
    if (_selectedCommit == null || _selectedCommit!.files.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Icon(Icons.code, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'File Changes',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
