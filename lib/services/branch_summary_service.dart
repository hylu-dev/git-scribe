import '../models/github_comparison.dart';
import '../models/ai_message.dart';
import 'ai_service.dart';
import 'cache_service.dart';

/// Service for generating AI-powered branch summaries
class BranchSummaryService {
  final AIService _aiService;
  final CacheService _cache = CacheService();

  BranchSummaryService(this._aiService);

  /// Generate an AI summary for a branch comparison
  /// If a cached summary exists, it will be returned immediately.
  /// Set forceRefresh to true to always generate a new summary.
  Future<String> generateSummary(
    GitHubComparison comparison, {
    bool forceRefresh = false,
  }) async {
    // Check cache first (unless forcing refresh)
    if (!forceRefresh) {
      final cacheKey = _getSummaryCacheKey(comparison);
      final cached = _cache.get<String>(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    if (!_aiService.isConfigured) {
      throw Exception(
        'AI service is not configured. Please configure an AI provider in Options.',
      );
    }

    // Format the comparison data
    final comparisonText = _formatComparisonForAI(comparison);

    // Create the prompt
    final prompt = _createPrompt(comparisonText);

    // Call AI service
    final response = await _aiService.chatCompletion(
      messages: [
        const AIMessage(
          role: 'system',
          content:
              'You are a helpful assistant that summarizes Git branch comparisons. '
              'Analyze both commit messages and code changes to provide insightful summaries. '
              'Focus on understanding the intent and impact of changes, not just listing them. '
              'Provide clear, concise summaries that help developers understand branch changes quickly.',
        ),
        AIMessage(role: 'user', content: prompt),
      ],
    );

    final summary = response.content;

    // Cache the summary (longer TTL since summaries don't change unless branch changes)
    final cacheKey = _getSummaryCacheKey(comparison);
    _cache.set(cacheKey, summary, ttl: const Duration(hours: 1));

    return summary;
  }

  /// Generate a cache key for a branch comparison summary
  String _getSummaryCacheKey(GitHubComparison comparison) {
    // Use base branch, head branch, and total commits as key
    // This ensures cache is invalidated if branch changes
    return 'summary:${comparison.baseBranch}:${comparison.headBranch}:${comparison.totalCommits}';
  }

  /// Format comparison data for AI processing
  String _formatComparisonForAI(GitHubComparison comparison) {
    final buffer = StringBuffer();

    buffer.writeln('Branch Comparison:');
    buffer.writeln('Base Branch: ${comparison.baseBranch}');
    buffer.writeln('Head Branch: ${comparison.headBranch}');
    buffer.writeln('Total Commits: ${comparison.totalCommits}');
    buffer.writeln('Files Changed: ${comparison.files.length}');
    buffer.writeln('');

    // Detailed commit information with file changes
    buffer.writeln('Commits:');
    for (var i = 0; i < comparison.commits.length; i++) {
      final commit = comparison.commits[i];
      buffer.writeln('\n--- Commit ${i + 1} ---');
      buffer.writeln('Message: ${commit.message}');
      buffer.writeln('Author: ${commit.author}');
      if (commit.date != null) {
        buffer.writeln('Date: ${commit.date}');
      }
      buffer.writeln('SHA: ${commit.sha.substring(0, 7)}');

      if (commit.files.isNotEmpty) {
        buffer.writeln('Files in this commit:');
        for (final file in commit.files) {
          buffer.writeln('  - ${file.filename} (${file.status})');
          buffer.writeln('    +${file.additions} -${file.deletions} lines');
          // Include patch preview for significant changes (smaller patches only)
          if (file.patch != null &&
              file.patch!.isNotEmpty &&
              file.patch!.length < 1500) {
            buffer.writeln('    Code preview:');
            // Include first 30 lines of patch for context
            final patchLines = file.patch!.split('\n');
            final previewLines = patchLines.take(30).join('\n');
            buffer.writeln('    $previewLines');
            if (patchLines.length > 30) {
              buffer.writeln('    ... (${patchLines.length - 30} more lines)');
            }
          }
        }
      }
    }

    // Overall file changes summary
    buffer.writeln('\n=== Overall File Changes Summary ===');
    final filesByType = <String, List<GitHubFileChange>>{};
    for (final file in comparison.files) {
      filesByType.putIfAbsent(file.status, () => []).add(file);
    }

    for (final entry in filesByType.entries) {
      buffer.writeln(
        '\n${entry.key.toUpperCase()} files (${entry.value.length}):',
      );
      for (final file in entry.value) {
        buffer.writeln('  - ${file.filename}');
        buffer.writeln('    +${file.additions} -${file.deletions} lines');
      }
    }

    // Include significant code changes (larger files or files with substantial changes)
    // Only include files that have code changes and are reasonably sized
    buffer.writeln('\n=== Significant Code Changes ===');
    final significantFiles = comparison.files
        .where(
          (f) =>
              (f.changes > 30 || f.additions > 20 || f.deletions > 20) &&
              f.patch != null &&
              f.patch!.isNotEmpty &&
              f.patch!.length < 3000,
        )
        .take(8)
        .toList();

    if (significantFiles.isNotEmpty) {
      for (final file in significantFiles) {
        buffer.writeln('\nFile: ${file.filename} (${file.status})');
        buffer.writeln('Changes: +${file.additions} -${file.deletions} lines');
        if (file.patch != null && file.patch!.isNotEmpty) {
          // Include patch preview for significant changes
          final patchLines = file.patch!.split('\n');
          final previewLines = patchLines.take(60).join('\n');
          buffer.writeln('Code preview:');
          buffer.writeln(previewLines);
          if (patchLines.length > 60) {
            buffer.writeln('... (${patchLines.length - 60} more lines)');
          }
        }
      }
    }

    return buffer.toString();
  }

  String _createPrompt(String comparisonText) {
    return '''
Produce a branch summary that EXACTLY follows the structure below. Do not add, remove, rename, or reorder sections.

# Title (REQUIRED)
- The first line MUST be a single markdown H1 title: `# ` + 3–8 descriptive words.
- This line must contain ONLY the title.

<blank line>

Summary
- After the title and one blank line, write a plain-text paragraph (1–2 sentences).
- No headings, lists, or code blocks.

<blank line>

## Key Changes
- Use the exact heading text `## Key Changes`.
- For each major change, create a third-level heading: `### <Change Title>`.
- Under each `###` heading, list sub-points using `- ` bullets.
- Each bullet should be 1–2 sentences describing what changed.
- Sub-bullets (optional) use two spaces + `- `.

Example:
# Add user authentication

Implements user sign-in so players can save progress and access protected endpoints.

## Key Changes

### Backend Authentication
- Added login and refresh-token endpoints.
- Implemented token expiry validation.
  - Fixed issue where refresh token wasn't persisted.

### Client Login UI
- Added login and signup screens.
- Improved error display for invalid credentials.

Formatting rules (strict):
1. First line = ONLY an H1 title.
2. One blank line → plain-text summary paragraph.
3. One blank line → `## Key Changes`.
4. Each main change = its own `###` heading.
5. Bullets under each `###` must use `- `.
6. Optional sub-bullets use `  - ` (two spaces).
7. No other headings, sections, metadata, or code fences.

Here is the comparison data:

$comparisonText
''';
  }
}
