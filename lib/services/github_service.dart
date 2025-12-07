import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/github_repository.dart';
import '../models/github_branch.dart';
import '../models/github_comparison.dart';
import 'supabase_service.dart';
import 'cache_service.dart';

/// Service for interacting with GitHub API
class GitHubService {
  static const String _baseUrl = 'https://api.github.com';
  final CacheService _cache = CacheService();

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
  /// Results are cached for 5 minutes.
  Future<List<GitHubRepository>> getUserRepositories({
    String? sort = 'updated',
    String? direction = 'desc',
    int page = 1,
    int perPage = 10,
    bool forceRefresh = false,
  }) async {
    // Check cache first (only for first page)
    if (page == 1 && !forceRefresh) {
      final cacheKey = 'repos:$sort:$direction:$page:$perPage';
      final cached = _cache.get<List<GitHubRepository>>(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

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
        final repos = jsonList
            .map(
              (json) => GitHubRepository.fromJson(json as Map<String, dynamic>),
            )
            .toList();

        // Cache first page only
        if (page == 1) {
          final cacheKey = 'repos:$sort:$direction:$page:$perPage';
          _cache.set(cacheKey, repos, ttl: const Duration(minutes: 5));
        }

        return repos;
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
  /// Includes commit details (message, author, date) for each branch
  /// Results are cached for 5 minutes.
  Future<List<GitHubBranch>> getRepositoryBranches(
    String owner,
    String repo, {
    int perPage = 100,
    bool forceRefresh = false,
  }) async {
    // Check cache first
    if (!forceRefresh) {
      final cacheKey = 'branches:$owner:$repo:$perPage';
      final cached = _cache.get<List<GitHubBranch>>(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    final token = _getAccessToken();
    if (token == null) {
      throw Exception('No GitHub access token found. Please sign in again.');
    }

    try {
      // Fetch branches with commit details
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
        final branches = <GitHubBranch>[];

        // Fetch commit details for each branch in parallel
        final branchFutures = jsonList.map((branchJson) async {
          final branchData = branchJson as Map<String, dynamic>;
          final commitSha = branchData['commit']?['sha'] as String?;

          // If we have a commit SHA, fetch full commit details
          if (commitSha != null) {
            try {
              final commitResponse = await http.get(
                Uri.parse('$_baseUrl/repos/$owner/$repo/commits/$commitSha'),
                headers: {
                  'Authorization': 'Bearer $token',
                  'Accept': 'application/vnd.github.v3+json',
                  'User-Agent': 'GitScribe',
                },
              );

              if (commitResponse.statusCode == 200) {
                final commitData =
                    jsonDecode(commitResponse.body) as Map<String, dynamic>;
                // Merge commit details into branch data
                branchData['commit'] = {
                  ...branchData['commit'] as Map<String, dynamic>,
                  'commit': commitData['commit'],
                };
              }
            } catch (_) {
              // If commit fetch fails, continue with basic branch info
            }
          }

          return GitHubBranch.fromJson(branchData);
        });

        // Wait for all branches to be processed
        branches.addAll(await Future.wait(branchFutures));

        // Cache the results
        final cacheKey = 'branches:$owner:$repo:$perPage';
        _cache.set(cacheKey, branches, ttl: const Duration(minutes: 5));

        return branches;
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

  /// Compare two branches
  /// Compares headBranch against baseBranch (typically main/master)
  /// Results are cached for 5 minutes.
  Future<GitHubComparison> compareBranches(
    String owner,
    String repo,
    String baseBranch,
    String headBranch, {
    bool forceRefresh = false,
  }) async {
    // Check cache first
    if (!forceRefresh) {
      final cacheKey = 'comparison:$owner:$repo:$baseBranch:$headBranch';
      final cached = _cache.get<GitHubComparison>(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    final token = _getAccessToken();
    if (token == null) {
      throw Exception('No GitHub access token found. Please sign in again.');
    }

    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/repos/$owner/$repo/compare/$baseBranch...$headBranch',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'GitScribe',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        // Add branch names to the response for easier access
        json['base_branch'] = baseBranch;
        json['head_branch'] = headBranch;

        // Fetch individual commit diffs to get per-commit file changes
        final commitsList = json['commits'] as List<dynamic>? ?? [];
        final commitFutures = commitsList.map((commitJson) async {
          final commitData = commitJson as Map<String, dynamic>;
          final commitSha = commitData['sha'] as String?;

          if (commitSha != null) {
            try {
              // Fetch full commit details including file changes
              final commitResponse = await http.get(
                Uri.parse('$_baseUrl/repos/$owner/$repo/commits/$commitSha'),
                headers: {
                  'Authorization': 'Bearer $token',
                  'Accept': 'application/vnd.github.v3+json',
                  'User-Agent': 'GitScribe',
                },
              );

              if (commitResponse.statusCode == 200) {
                final commitDetails =
                    jsonDecode(commitResponse.body) as Map<String, dynamic>;
                // Merge file changes into commit data
                commitData['files'] = commitDetails['files'] ?? [];
              }
            } catch (_) {
              // If commit fetch fails, continue without file details
            }
          }

          return commitData;
        });

        // Wait for all commits to be processed
        final updatedCommits = await Future.wait(commitFutures);
        json['commits'] = updatedCommits;

        final comparison = GitHubComparison.fromJson(json);

        // Cache the results
        final cacheKey = 'comparison:$owner:$repo:$baseBranch:$headBranch';
        _cache.set(cacheKey, comparison, ttl: const Duration(minutes: 5));

        return comparison;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please sign in again.');
      } else if (response.statusCode == 404) {
        throw Exception('Repository or branch not found.');
      } else {
        throw Exception(
          'Failed to compare branches: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error comparing branches: $e');
    }
  }

  /// Get the default branch for a repository (usually 'main' or 'master')
  Future<String> getDefaultBranch(String owner, String repo) async {
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
        return json['default_branch'] as String? ?? 'main';
      } else {
        // Fallback to common defaults
        return 'main';
      }
    } catch (_) {
      // Fallback to common defaults
      return 'main';
    }
  }
}
