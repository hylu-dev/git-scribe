/// Model representing a GitHub branch
class GitHubBranch {
  final String name;
  final bool isProtected;
  final String? sha;
  final String? commitUrl;
  final String? commitMessage;
  final String? commitAuthor;
  final DateTime? commitDate;

  GitHubBranch({
    required this.name,
    required this.isProtected,
    this.sha,
    this.commitUrl,
    this.commitMessage,
    this.commitAuthor,
    this.commitDate,
  });

  factory GitHubBranch.fromJson(Map<String, dynamic> json) {
    return GitHubBranch(
      name: json['name'] as String,
      isProtected: json['protected'] as bool? ?? false,
      sha: json['commit']?['sha'] as String?,
      commitUrl: json['commit']?['url'] as String?,
      commitMessage: json['commit']?['commit']?['message'] as String?,
      commitAuthor: json['commit']?['commit']?['author']?['name'] as String?,
      commitDate: json['commit']?['commit']?['author']?['date'] != null
          ? DateTime.tryParse(
              json['commit']?['commit']?['author']?['date'] as String,
            )
          : null,
    );
  }
}
