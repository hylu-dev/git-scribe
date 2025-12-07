/// Model representing a GitHub branch comparison
class GitHubComparison {
  final String baseBranch;
  final String headBranch;
  final String status; // 'ahead', 'behind', 'identical', 'diverged'
  final int aheadBy;
  final int behindBy;
  final int totalCommits;
  final List<GitHubCommit> commits;
  final List<GitHubFileChange> files;

  GitHubComparison({
    required this.baseBranch,
    required this.headBranch,
    required this.status,
    required this.aheadBy,
    required this.behindBy,
    required this.totalCommits,
    required this.commits,
    required this.files,
  });

  factory GitHubComparison.fromJson(Map<String, dynamic> json) {
    final commitsList = json['commits'] as List<dynamic>? ?? [];
    final filesList = json['files'] as List<dynamic>? ?? [];

    return GitHubComparison(
      baseBranch: json['base_branch'] as String? ?? '',
      headBranch: json['head_branch'] as String? ?? '',
      status: json['status'] as String? ?? 'unknown',
      aheadBy: json['ahead_by'] as int? ?? 0,
      behindBy: json['behind_by'] as int? ?? 0,
      totalCommits: json['total_commits'] as int? ?? 0,
      commits: commitsList
          .map((c) => GitHubCommit.fromJson(c as Map<String, dynamic>))
          .toList(),
      files: filesList
          .map((f) => GitHubFileChange.fromJson(f as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Model representing a GitHub commit in a comparison
class GitHubCommit {
  final String sha;
  final String message;
  final String author;
  final DateTime? date;
  final String? url;
  final List<GitHubFileChange> files; // Files changed in this commit

  GitHubCommit({
    required this.sha,
    required this.message,
    required this.author,
    this.date,
    this.url,
    this.files = const [],
  });

  factory GitHubCommit.fromJson(Map<String, dynamic> json) {
    final filesList = json['files'] as List<dynamic>? ?? [];
    return GitHubCommit(
      sha: json['sha'] as String? ?? '',
      message: json['commit']?['message'] as String? ?? '',
      author: json['commit']?['author']?['name'] as String? ?? '',
      date: json['commit']?['author']?['date'] != null
          ? DateTime.tryParse(json['commit']?['author']?['date'] as String)
          : null,
      url: json['html_url'] as String?,
      files: filesList
          .map((f) => GitHubFileChange.fromJson(f as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Model representing a file change in a comparison
class GitHubFileChange {
  final String filename;
  final String status; // 'added', 'removed', 'modified', 'renamed'
  final int additions;
  final int deletions;
  final int changes;
  final String? patch;

  GitHubFileChange({
    required this.filename,
    required this.status,
    required this.additions,
    required this.deletions,
    required this.changes,
    this.patch,
  });

  factory GitHubFileChange.fromJson(Map<String, dynamic> json) {
    return GitHubFileChange(
      filename: json['filename'] as String? ?? '',
      status: json['status'] as String? ?? 'modified',
      additions: json['additions'] as int? ?? 0,
      deletions: json['deletions'] as int? ?? 0,
      changes: json['changes'] as int? ?? 0,
      patch: json['patch'] as String?,
    );
  }
}
