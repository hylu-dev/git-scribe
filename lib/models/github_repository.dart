/// Model representing a GitHub repository
class GitHubRepository {
  final int id;
  final String name;
  final String fullName;
  final String? description;
  final bool isPrivate;
  final bool isFork;
  final String? language;
  final int stars;
  final int forks;
  final String htmlUrl;
  final DateTime updatedAt;
  final String ownerLogin;
  final String? ownerAvatarUrl;

  GitHubRepository({
    required this.id,
    required this.name,
    required this.fullName,
    this.description,
    required this.isPrivate,
    required this.isFork,
    this.language,
    required this.stars,
    required this.forks,
    required this.htmlUrl,
    required this.updatedAt,
    required this.ownerLogin,
    this.ownerAvatarUrl,
  });

  factory GitHubRepository.fromJson(Map<String, dynamic> json) {
    return GitHubRepository(
      id: json['id'] as int,
      name: json['name'] as String,
      fullName: json['full_name'] as String,
      description: json['description'] as String?,
      isPrivate: json['private'] as bool,
      isFork: json['fork'] as bool,
      language: json['language'] as String?,
      stars: json['stargazers_count'] as int? ?? 0,
      forks: json['forks_count'] as int? ?? 0,
      htmlUrl: json['html_url'] as String,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      ownerLogin: json['owner']?['login'] as String? ?? '',
      ownerAvatarUrl: json['owner']?['avatar_url'] as String?,
    );
  }
}
