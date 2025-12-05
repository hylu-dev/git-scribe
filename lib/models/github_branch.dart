/// Model representing a GitHub branch
class GitHubBranch {
  final String name;
  final bool isProtected;
  final String? sha;
  final String? commitUrl;

  GitHubBranch({
    required this.name,
    required this.isProtected,
    this.sha,
    this.commitUrl,
  });

  factory GitHubBranch.fromJson(Map<String, dynamic> json) {
    return GitHubBranch(
      name: json['name'] as String,
      isProtected: json['protected'] as bool? ?? false,
      sha: json['commit']?['sha'] as String?,
      commitUrl: json['commit']?['url'] as String?,
    );
  }
}
