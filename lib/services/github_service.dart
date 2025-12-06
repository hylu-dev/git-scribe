import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/github_repository.dart';
import '../models/github_branch.dart';
import 'supabase_service.dart';

/// Service for interacting with GitHub API
class GitHubService {
  static const String _baseUrl = 'https://api.github.com';

  /// Get the GitHub access token from Supabase session
  String? _getAccessToken() {
    final session = SupabaseService.client.auth.currentSession;
    // The provider token is stored in the session
    // For GitHub, it's typically in the provider_token field
    return session?.providerToken;
  }

  /// Fetch repositories for the authenticated user (paginated)
  /// Returns a list of repositories sorted by most recently updated.
  /// Uses `visibility=all` to fetch all repositories the user can see.
  Future<List<GitHubRepository>> getUserRepositories({
    String? sort = 'updated',
    String? direction = 'desc',
    int page = 1,
    int perPage = 10,
  }) async {
    final token = _getAccessToken();
    if (token == null) {
      throw Exception('No GitHub access token found. Please sign in again.');
    }

    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/user/repos?sort=$sort&direction=$direction&per_page=$perPage&page=$page&visibility=all',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'GitScribe',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList
            .map(
              (json) => GitHubRepository.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please sign in again.');
      } else {
        throw Exception(
          'Failed to fetch repositories: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error fetching repositories: $e');
    }
  }

  /// Fetch a specific repository by owner and name
  Future<GitHubRepository> getRepository(String owner, String repo) async {
    final token = _getAccessToken();
    if (token == null) {
      throw Exception('No GitHub access token found. Please sign in again.');
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/repos/$owner/$repo'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'GitScribe',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return GitHubRepository.fromJson(json);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please sign in again.');
      } else if (response.statusCode == 404) {
        throw Exception('Repository not found.');
      } else {
        throw Exception(
          'Failed to fetch repository: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error fetching repository: $e');
    }
  }

  /// Fetch all branches for a repository
  /// Returns a list of branches for the given owner and repository
  Future<List<GitHubBranch>> getRepositoryBranches(
    String owner,
    String repo, {
    int perPage = 100,
  }) async {
    final token = _getAccessToken();
    if (token == null) {
      throw Exception('No GitHub access token found. Please sign in again.');
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/repos/$owner/$repo/branches?per_page=$perPage'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'GitScribe',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList
            .map((json) => GitHubBranch.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please sign in again.');
      } else if (response.statusCode == 404) {
        throw Exception('Repository not found.');
      } else {
        throw Exception(
          'Failed to fetch branches: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error fetching branches: $e');
    }
  }
}
